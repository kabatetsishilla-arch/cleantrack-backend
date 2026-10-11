const pool = require("../config/db");

const FREQUENCIES = ["weekly", "biweekly", "monthly"];

const parseDate = (value) => {
  const match = /^(\d{4})-(\d{2})-(\d{2})$/.exec(value || "");
  if (!match) return null;
  const date = new Date(Number(match[1]), Number(match[2]) - 1, Number(match[3]), 12, 0, 0);
  return Number.isNaN(date.getTime()) ? null : date;
};

const toSqlDate = (date) => {
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, "0");
  const day = String(date.getDate()).padStart(2, "0");
  return `${year}-${month}-${day}`;
};

const addStep = (date, frequency, amount = 1) => {
  const next = new Date(date);
  if (frequency === "weekly") next.setDate(next.getDate() + 7 * amount);
  else if (frequency === "biweekly") next.setDate(next.getDate() + 14 * amount);
  else next.setMonth(next.getMonth() + amount);
  return next;
};

const todayString = () => toSqlDate(new Date());

const generatePickups = async (schedule, startDate, count = 4) => {
  const cursor = parseDate(startDate);
  for (let i = 0; i < count; i += 1) {
    const occurrence = addStep(cursor, schedule.frequency, i);
    await pool.query(
      `INSERT INTO pickup_requests
       (customer_id, location_id, waste_category_id, description, urgency, estimated_bin_level, requested_at)
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [
        schedule.user_id,
        schedule.location_id,
        schedule.waste_category_id,
        `Scheduled pickup (schedule #${schedule.id}, occurrence ${toSqlDate(occurrence)})`,
        schedule.urgency,
        80,
        `${toSqlDate(occurrence)} 08:00:00`
      ]
    );
  }
  return addStep(cursor, schedule.frequency, count);
};

const validateAndResolve = async (body, userId) => {
  const { location_id, waste_category_id, frequency, start_date, urgency = "normal" } = body;

  if (!location_id || !waste_category_id || !frequency || !start_date) {
    return { error: "Location, waste type, frequency, and start date are required" };
  }
  if (!FREQUENCIES.includes(frequency)) {
    return { error: "Frequency must be weekly, biweekly, or monthly" };
  }
  if (!["normal", "urgent"].includes(urgency)) {
    return { error: "Urgency must be normal or urgent" };
  }

  const start = parseDate(start_date);
  if (!start) return { error: "Start date must be a valid YYYY-MM-DD date" };
  if (toSqlDate(start) < todayString()) {
    return { error: "Start date cannot be in the past" };
  }

  const [locations] = await pool.query(
    "SELECT id FROM customer_locations WHERE id = ? AND user_id = ?",
    [location_id, userId]
  );
  if (!locations.length) {
    return { error: "You can only create schedules for your own locations" };
  }

  const [categories] = await pool.query(
    "SELECT id FROM waste_categories WHERE id = ? AND status = 'active'",
    [waste_category_id]
  );
  if (!categories.length) {
    return { error: "Waste type not found or not active" };
  }

  return { values: { location_id, waste_category_id, frequency, start_date: toSqlDate(start), urgency } };
};

const createSchedule = async (req, res) => {
  try {
    const checked = await validateAndResolve(req.body, req.user.id);
    if (checked.error) return res.status(400).json({ message: checked.error });
    const { location_id, waste_category_id, frequency, start_date, urgency } = checked.values;

    const [result] = await pool.query(
      `INSERT INTO pickup_schedules
       (user_id, location_id, waste_category_id, frequency, start_date, next_run_date, urgency, status)
       VALUES (?, ?, ?, ?, ?, ?, ?, 'active')`,
      [req.user.id, location_id, waste_category_id, frequency, start_date, start_date, urgency]
    );

    const schedule = {
      id: result.insertId,
      user_id: req.user.id,
      location_id,
      waste_category_id,
      frequency,
      urgency
    };
    const nextRun = await generatePickups(schedule, start_date, 4);

    await pool.query("UPDATE pickup_schedules SET next_run_date = ? WHERE id = ?", [
      toSqlDate(nextRun),
      schedule.id
    ]);

    res.status(201).json({
      message: "Schedule created and next 4 pickups generated",
      id: schedule.id
    });
  } catch (error) {
    res.status(500).json({ message: "Could not create schedule", error: error.message });
  }
};

const getMySchedules = async (req, res) => {
  const [schedules] = await pool.query(
    `SELECT ps.*, cl.location_name, cl.district, wc.name AS waste_type,
            (SELECT COUNT(*) FROM pickup_requests pr
              WHERE pr.customer_id = ps.user_id
                AND pr.location_id = ps.location_id
                AND pr.waste_category_id = ps.waste_category_id
                AND pr.status = 'pending'
                AND pr.requested_at >= CURDATE()
                AND pr.description LIKE CONCAT('Scheduled pickup (schedule #', ps.id, ',%')
            ) AS upcoming_pickups
     FROM pickup_schedules ps
     JOIN customer_locations cl ON cl.id = ps.location_id
     JOIN waste_categories wc ON wc.id = ps.waste_category_id
     WHERE ps.user_id = ?
     ORDER BY ps.created_at DESC`,
    [req.user.id]
  );
  res.json(schedules);
};

const updateSchedule = async (req, res) => {
  try {
    const [existing] = await pool.query(
      "SELECT * FROM pickup_schedules WHERE id = ? AND user_id = ?",
      [req.params.id, req.user.id]
    );
    if (!existing.length) return res.status(404).json({ message: "Schedule not found" });

    const checked = await validateAndResolve({ ...req.body, location_id: req.body.location_id || existing[0].location_id }, req.user.id);
    if (checked.error) return res.status(400).json({ message: checked.error });
    const { location_id, waste_category_id, frequency, start_date, urgency } = checked.values;

    await pool.query(
      `UPDATE pickup_schedules
       SET location_id = ?, waste_category_id = ?, frequency = ?, start_date = ?, urgency = ?
       WHERE id = ? AND user_id = ?`,
      [location_id, waste_category_id, frequency, start_date, urgency, req.params.id, req.user.id]
    );

    res.json({ message: "Schedule updated" });
  } catch (error) {
    res.status(500).json({ message: "Could not update schedule", error: error.message });
  }
};

const setPaused = (paused) => async (req, res) => {
  try {
    const [existing] = await pool.query(
      "SELECT * FROM pickup_schedules WHERE id = ? AND user_id = ?",
      [req.params.id, req.user.id]
    );
    if (!existing.length) return res.status(404).json({ message: "Schedule not found" });

    const status = paused ? "paused" : "active";
    await pool.query("UPDATE pickup_schedules SET status = ? WHERE id = ?", [status, req.params.id]);

    let generated = 0;
    if (!paused) {
      // On resume, refill the next batch of pickups if none are still waiting.
      const [upcoming] = await pool.query(
        `SELECT COUNT(*) AS cnt FROM pickup_requests
         WHERE customer_id = ? AND status = 'pending' AND requested_at >= CURDATE()
           AND description LIKE CONCAT('Scheduled pickup (schedule #', ?, ',%')`,
        [existing[0].user_id, req.params.id]
      );
      if (upcoming[0].cnt === 0) {
        const nextRun = await generatePickups(existing[0], existing[0].next_run_date, 4);
        await pool.query("UPDATE pickup_schedules SET next_run_date = ? WHERE id = ?", [
          toSqlDate(nextRun),
          req.params.id
        ]);
        generated = 4;
      }
    }

    res.json({
      message: paused ? "Schedule paused" : `Schedule resumed${generated ? " and 4 pickups generated" : ""}`
    });
  } catch (error) {
    res.status(500).json({ message: "Could not update schedule status", error: error.message });
  }
};

const deleteSchedule = async (req, res) => {
  const [result] = await pool.query(
    "DELETE FROM pickup_schedules WHERE id = ? AND user_id = ?",
    [req.params.id, req.user.id]
  );
  if (!result.affectedRows) return res.status(404).json({ message: "Schedule not found" });
  res.json({ message: "Schedule deleted" });
};

module.exports = {
  createSchedule,
  getMySchedules,
  updateSchedule,
  pauseSchedule: setPaused(true),
  resumeSchedule: setPaused(false),
  deleteSchedule
};
