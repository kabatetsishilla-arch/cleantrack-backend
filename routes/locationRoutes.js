const express = require("express");
const {
  createLocation,
  getMyLocations,
  getLocationById,
  updateLocation,
  deleteLocation,
  toggleFavourite
} = require("../controllers/locationController");
const { protect } = require("../middleware/authMiddleware");
const { allowRoles } = require("../middleware/roleMiddleware");

const router = express.Router();

router.use(protect, allowRoles("customer"));

router.post("/", createLocation);
router.get("/my-locations", getMyLocations);
router.get("/:id", getLocationById);
router.put("/:id/favourite", toggleFavourite);
router.put("/:id", updateLocation);
router.delete("/:id", deleteLocation);

module.exports = router;
