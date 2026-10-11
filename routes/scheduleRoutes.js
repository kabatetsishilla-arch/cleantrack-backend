const express = require("express");
const {
  createSchedule,
  getMySchedules,
  updateSchedule,
  pauseSchedule,
  resumeSchedule,
  deleteSchedule
} = require("../controllers/scheduleController");
const { protect } = require("../middleware/authMiddleware");
const { allowRoles } = require("../middleware/roleMiddleware");

const router = express.Router();

router.use(protect, allowRoles("customer"));

router.post("/", createSchedule);
router.get("/my-schedules", getMySchedules);
router.put("/:id/pause", pauseSchedule);
router.put("/:id/resume", resumeSchedule);
router.put("/:id", updateSchedule);
router.delete("/:id", deleteSchedule);

module.exports = router;
