const express = require("express");
const {
  createDriverRating,
  getMyRatings,
  getDriverSummary,
  getRatingForPickup
} = require("../controllers/driverRatingController");
const { protect } = require("../middleware/authMiddleware");
const { allowRoles } = require("../middleware/roleMiddleware");

const router = express.Router();

router.post("/", protect, allowRoles("customer"), createDriverRating);
router.get("/my", protect, allowRoles("customer"), getMyRatings);
router.get("/summary", protect, allowRoles("manager", "admin"), getDriverSummary);
router.get("/pickup/:pickupId", protect, allowRoles("customer"), getRatingForPickup);

module.exports = router;
