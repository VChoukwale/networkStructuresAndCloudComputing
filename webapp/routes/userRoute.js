import express from "express";
import { body, validationResult } from "express-validator";
import userController from "../controllers/userController.js";
import basicAuth from "../middleware/healthCheckAuth.js";

const router = express.Router();

// Disable body-parser for empty string
router.use(express.text({ type: "*/*" }));

// Validation middleware
const validateCreateUser = [
  body("email").isEmail().normalizeEmail(),
  body("password").isLength({ min: 8 }),
  // Add validation for other fields
  (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }
    next();
  },
];

// Middleware to block unverified users
// const blockUnverifiedUsers = (req, res, next) => {
   // Check if user is verified
//   if (!req.user.emailStatusVerification) {
//     return res
//       .status(404)
//       .json({ error: "User not found or account not verified" });
//   }
//   next();
// };

router.post("/", validateCreateUser, userController.createUser);
router.get("/self", userController.getUser);
router.get("/verify/:token", userController.verifyUser);
router.put("/self", basicAuth, userController.updateUser);

// router.post("/", validateCreateUser, userController.createUser);
// router.get("/self", blockUnverifiedUsers, userController.getUser);
// router.put("/self", basicAuth, blockUnverifiedUsers, userController.updateUser);

export default router;