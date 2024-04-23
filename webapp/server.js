import express from "express";
import bodyParser from "body-parser";
import sequelize from "./config/dbConfig.js";
import userRoutes from "./routes/userRoute.js";
import healthCheckRoute from "./routes/healthCheckRoute.js";
import {createDatabaseIfNotExist} from "./config/dbConfig.js";
import logger from "./config/logger.js";

const setupServer = async () => {
  const app = express();

  app.use(bodyParser.json());

  app.use(async (req, res, next) => {
    req.db = { User: sequelize.models.User };
    next();
  });

  app.use("/healthz", healthCheckRoute);
  app.use("/v2/user", userRoutes);    

  await createDatabaseIfNotExist();
  
  try {
    await sequelize.sync({ force: true }); // Drop previously existing tables
    //console.log("Database synced successfully");
    logger.info("Database synced successfully");

    return app;
  } catch (error) {
    //console.error("Error syncing database:", error);
    logger.error("Error syncing database:");
    process.exit(1);
  }
};

export { setupServer };
