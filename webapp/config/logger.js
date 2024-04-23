import winston from "winston";
import { format } from "winston";
import dotenv from 'dotenv';
//import Json from "sequelize";

dotenv.config();

const logger = winston.createLogger({
  level: "debug",
  format: format.combine(
    format.timestamp(),
    format.json()
  ),
  transports: [
    new winston.transports.File({
      filename:  process.env.LOG_FILE_PATH,
    }),
  ],
});

export default logger;
