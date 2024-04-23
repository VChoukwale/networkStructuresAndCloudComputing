import bcrypt from "bcrypt";
import User from "../models/userModel.js";
import logger from "../config/logger.js";
import { cloudFunction } from "../config/pubSub.js";
import dotenv from "dotenv";

dotenv.config();

const createUser = async (req, res) => {
  try {
    const { email, password, firstName, lastName } = req.body;

    logger.debug("Received user data");

    const existingEmail = await User.findOne({ where: { username: email } });
    if (existingEmail) {
      logger.error("User creation failed: User already exists.");
      console.log("Same user already exists.");
      return res.status(400).json({
        error:
          "User with the same email already exists. Please use another email",
      });
    }
    // console.log(password)
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    const user = await User.create({
      username: email,
      password: hashedPassword,
      firstName,
      lastName,
      tokenExpiry: new Date().getTime() + (2 * 60 * 1000),
    });

    const { password: _, ...userData } = user.toJSON();
    if (process.env.ENV !== "dev"){
      await cloudFunction(
        JSON.stringify(userData),
        "assignment-4-414719",
        "verify_email",
        "eSub"
      );
      console.log(userData);

    }
    

    // Generate verification link
    const verificationLink = `http://vaishc.me:8080/v2/user/verify/${userData.token}`;
    console.log("Verification Link: ", verificationLink);
    // Send verification email with the link
    //await sendVerificationEmail(userData.email, verificationLink); // Implement your email sending logic here

    user.account_updated = new Date();
    await user.save();

    const response = {
      id: user.id,
      firstName: user.firstName,
      lastName: user.lastName,
      username: user.username,
      account_created: user.account_created,
      account_updated: user.account_updated,
      token_expiry: user.tokenExpiry,
      statusVerification: user.statusVerification,
      emailStatusVerification: user.emailStatusVerification,
    };

    res.status(201).json(response);
    logger.info("User created successfully"); // Logging of user creation success
  } catch (error) {
    logger.error("Error creating user", { error: error.message }); // Logging of user creation error
    console.log("1 Internal Server Error", error);
    res.status(500).json({ error: "Internal Server Error" });
  }
};

const updateUser = async (req, res) => {
  try {
    const { firstName, lastName, password } = req.body;

    logger.debug("Initiating user update operation");

    const validFields = ["firstName", "lastName", "password"];
    const invalidFields = Object.keys(req.body).filter(
      (field) => !validFields.includes(field)
    );
    if (invalidFields.length > 0) {
      logger.warning("Invalid fields provided for update");
      return res.status(400).end();
    }

    const authHeader = req.headers.authorization;
    console.log("Authorization Header:", authHeader);
    if (!authHeader || !authHeader.startsWith("Basic ")) {
      return res.status(401).json({ error: "Unauthorized" });
    }

    // Extract credentials from the Authorization header
    const base64Credentials = authHeader.split(" ")[1];
    const credentials = Buffer.from(base64Credentials, "base64").toString(
      "utf-8"
    );
    console.log("Decoded Credentials:", credentials);

    const [username, passwordFound] = credentials.split(":");

    // Find the user by username
    const user = await User.findOne({ where: { username } });
    if (!user) {
      logger.error("User authentication failed: User not found");
      return res.status(404).json({ error: "User not found" });
    }
    console.log("Found user!!:", username);
    console.log("User status verification:", user.statusVerification);
    console.log(
      "Credentials used for authentication:",
      username,
      passwordFound
    );

    // Check if the user is verified
    if (!user.statusVerification && process.env.ENV !== "dev") {
      console.log(process.env.ENV);
      console.log("User not verified!!");
      logger.error("User not verified");
      return res.status(403).json({ error: "User is not verified correctly" });
    }

    console.log("Username:", username);
    console.log("Password:", passwordFound);
    let hashedPassword;
    if (password) {
      hashedPassword = await bcrypt.hash(password, 10);
    }

    const updatedUserData = await User.update(
      {
        firstName,
        lastName,
        password: hashedPassword,
        account_updated: new Date(),
      },
      {
        where: { username: username },
        returning: true,
      }
    );

    logger.info("User updated successfully"); // Log user update success
    res.status(204).json();
  } catch (error) {
    logger.error("Error updating user", { error: error.message }); // Logging user update error
    res.status(500).send("Internal Server Error");
  }
};

const getUser = async (req, res) => {
  try {
    const authHeader = req.headers.authorization;
    console.log("Authorization Header:", authHeader);
    if (!authHeader || !authHeader.startsWith("Basic ")) {
      return res.status(401).json({ error: "Unauthorized" });
    }

    // Extract credentials from the Authorization header
    const base64Credentials = authHeader.split(" ")[1];
    const credentials = Buffer.from(base64Credentials, "base64").toString(
      "utf-8"
    );
    console.log("Decoded Credentials:", credentials);

    const [username, password] = credentials.split(":");
    console.log("Username:", username);
    console.log("Password:", password);
    logger.debug("Performing user authentication");

    // Find the user by username
    const user = await User.findOne({ where: { username } });
    if (!user) {
      logger.error("User authentication failed: User not found");
      return res.status(404).json({ error: "User not found" });
    }
    //console.log(user)
    if (!user.statusVerification && process.env.ENV !== "dev") {
      logger.error("User not verified");
      console.log("User not verified");
      return res
        .status(403)
        .header("Cache-Control", "no-cache, no-store, must-revalidate")
        .json({ error: "User is not verified" });
    }
    // Compare the provided password with the hashed password stored in the database
    console.log("Retrieved Hashed Password:", user.password);
    console.log("Provided Password:", password);
    const isPasswordValid = bcrypt.compareSync(password, user.password);
    console.log("Password Comparison Result:", isPasswordValid);
    if (!isPasswordValid) {
      return res.status(401).json({ error: "Invalid username or password" });
    }
    logger.info("User retrieved successfully");
    // If authentication succeeds, return the user details
    const response = {
      id: user.id,
      firstName: user.firstName,
      lastName: user.lastName,
      username: user.username,
      account_created: user.account_created,
      account_updated: user.account_updated,
      statusVerification: user.statusVerification,
      emailStatusVerification: user.emailStatusVerification,
    };

    res.status(200).json(response);
  } catch (error) {
    logger.error("Error fetching user", { error: error.message }); // Logging user retrieval error
    res.status(500).json({ error: "Internal Server Error" });
  }
};

const verifyUser = async (req, res) => {
  try {
    let token = req.params.token;
    if (!token) {
      throw new Error("Token is Not Found");
    }
    let user;
    if (process.env.ENV !== "dev") {

      user = await User.findOne({ where: { token } });
    }else{
      user = await User.findOne({ where: { username: "vaishnavi@example.com" } });
    }
    if (!user) {
      throw new Error("User is not verified");
    }
    let time = new Date().getTime();
    if (time > user.tokenExpiry && process.env.ENV !== "dev") {
      return res.status(401).json({ error: "Token has expired" });
    }

    user.statusVerification = true;
    await user.save();

    console.log("User verified successfully");
    logger.info("User verified successfully");
    res.status(200).json({ message: "User verified successfully" });
  } catch (error) {
    console.error("Error verifying user:", error);
    logger.error("Error verifying user:", { error: error.message });
    res.status(401).json({ error: "Verification Link Has Expired!!" });
  }
};

const checkHealth = (req, res) => {
  try {
    logger.debug("Performing health check");
    if (req.method != "GET") {
      res.set("Pragma", "no-cache");
      res.set("X-Content-Type-Options", "nosniff");
      res.set("Cache-Control", "no-cache, no-store, must-revalidate");
      res.status(405).send();
      return;
    }

    if (
      Object.keys(req.body).length > 0 ||
      (JSON.stringify(req._body) && typeof req._body !== "{}")
    ) {
      logger.error("Payload present, returning 400 Bad Request", {
        error: error.message,
      });

      res.set("Pragma", "no-cache");
      res.set("X-Content-Type-Options", "nosniff");
      res.set("Cache-Control", "no-cache, no-store, must-revalidate");
      res.status(400).send();
      return;
    }

    if (Object.keys(req.query).length !== 0) {
      logger.error("Query parameters present, returning 400 Bad Request", {
        error: error.message,
      });

      res.set("Pragma", "no-cache");
      res.set("X-Content-Type-Options", "nosniff");
      res.set("Cache-Control", "no-cache, no-store, must-revalidate");
      res.status(400).send();
      return;
    }

    req.db
      .authenticate()
      .then(() => {
        logger.info("MySQL connection successful, returning 200 OK");
        console.log("MySQL connection successful!!!");

        res.set("Pragma", "no-cache");
        res.set("X-Content-Type-Options", "nosniff");
        res.set("Cache-Control", "no-cache, no-store, must-revalidate");
        res.status(200).send();
      })
      .catch((error) => {
        logger.error("MySQL connection unsuccessful:", {
          error: error.message,
        });
        res.set("Pragma", "no-cache");
        res.set("X-Content-Type-Options", "nosniff");
        res.set("Cache-Control", "no-cache, no-store, must-revalidate");
        res.status(503).send();

        logger.critical(
          "Critical: MySQL connection unsuccessful during health check",
          { error: error.message }
        );
      });
  } catch (error) {
    logger.error("Exception occurred during health check:", {
      error: error.message,
    });
    console.error(
      "Exception occurred, returning 503 Service Unavailable:",
      error
    );
    res.set("Pragma", "no-cache");
    res.set("X-Content-Type-Options", "nosniff");
    res.set("Cache-Control", "no-cache, no-store, must-revalidate");
    res.status(503).send();
  }
};

export default {
  createUser,
  updateUser,
  getUser,
  verifyUser,
  checkHealth,
};
