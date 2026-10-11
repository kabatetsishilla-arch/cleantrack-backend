const pool = require("../config/db");

const createDriverRating = async (req, res) => {
  try {
    const { pickup_request_id, rating, comment } = req.body;
    const ratingValue = Number(rating);

    if (!pickup_request_id) {
      return res.status(400).json({ message: "Pickup request is required" });
    }
    if (!Number.isInteger(ratingValue) || ratingValue < 1 || ratingValue > 5) {
      return res.status(400).json({ message: "Rating must be a whole number between 1 and 5" });
    }

    // Only the customer who requested the pickup may rate, and only after collection.
    const [pickups] = await pool.query(
      `SELECT pr.id, pa.driver_id
       FROM pickup_requests pr
       JOIN pickup_assignments pa ON pa.pickup_request_id = pr.id
       WHERE pr.id = ? AND pr.customer_id = ? AND pr.status = 'collected'`,
      [pickup_request_id, req.user.id]
    );
    if (!pickups.length) {
      return res.status(403).json({
        message: "You can only rate drivers for your own pickups once they are collected"
      });
    }

    const [existing] = await pool.query(
      "SELECT id FROM driver_ratings WHERE pickup_request_id = ?",
      [pickup_request_id]
    );
    if (existing.length) {
      return res.status(409).json({ message: "You have already rated the driver for this pickup" });
    }

    const [result] = await pool.query(
      "INSERT INTO driver_ratings (pickup_request_id, customer_id, driver_id, rating, comment) VALUES (?, ?, ?, ?, ?)",
      [pickup_request_id, req.user.id, pickups[0].driver_id, ratingValue, comment || null]
    );

    res.status(201).json({ message: "Driver rating saved", id: result.insertId });
  } catch (error) {
    res.status(500).json({ message: "Could not save driver rating", error: error.message });
  }
};

const getMyRatings = async (req, res) => {
  const [ratings] = await pool.query(
    `SELECT dr.*, u.full_name AS driver_name, cl.location_name
     FROM driver_ratings dr
     JOIN users u ON u.id = dr.driver_id
     JOIN pickup_requests pr ON pr.id = dr.pickup_request_id
     JOIN customer_locations cl ON cl.id = pr.location_id
     WHERE dr.customer_id = ?
     ORDER BY dr.created_at DESC`,
    [req.user.id]
  );
  res.json(ratings);
};

const getDriverSummary = async (req, res) => {
  const [summary] = await pool.query(
    `SELECT u.id AS driver_id, u.full_name AS driver_name,
            COUNT(dr.id) AS total_ratings,
            COALESCE(ROUND(AVG(dr.rating), 2), 0) AS average_rating
     FROM users u
     LEFT JOIN driver_ratings dr ON dr.driver_id = u.id
     WHERE u.role = 'driver' AND u.status = 'active'
     GROUP BY u.id, u.full_name
     ORDER BY average_rating DESC, total_ratings DESC`
  );

  const [recent] = await pool.query(
    `SELECT dr.rating, dr.comment, dr.created_at,
            cu.full_name AS customer_name, du.full_name AS driver_name, cl.location_name
     FROM driver_ratings dr
     JOIN users cu ON cu.id = dr.customer_id
     JOIN users du ON du.id = dr.driver_id
     JOIN pickup_requests pr ON pr.id = dr.pickup_request_id
     JOIN customer_locations cl ON cl.id = pr.location_id
     ORDER BY dr.created_at DESC
     LIMIT 20`
  );

  res.json({ summary, recent });
};

const getRatingForPickup = async (req, res) => {
  const [ratings] = await pool.query(
    `SELECT dr.*, u.full_name AS driver_name
     FROM driver_ratings dr
     JOIN users u ON u.id = dr.driver_id
     WHERE dr.pickup_request_id = ? AND dr.customer_id = ?`,
    [req.params.pickupId, req.user.id]
  );
  if (!ratings.length) return res.status(404).json({ message: "No rating found for this pickup" });
  res.json(ratings[0]);
};

module.exports = { createDriverRating, getMyRatings, getDriverSummary, getRatingForPickup };
