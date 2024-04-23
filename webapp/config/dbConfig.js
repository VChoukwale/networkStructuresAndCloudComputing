import { Sequelize } from 'sequelize';
import dotenv from 'dotenv';
import mysql2 from 'mysql2/promise';

// Load environment variables from .env file
dotenv.config();

const sequelize = new Sequelize({
  dialect: 'mysql',
  host: process.env.HOST,
  username: process.env.DB_USERNAME,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
});

export const createDatabaseIfNotExist = async () => {
  try {
      await sequelize.authenticate();
      console.log('Connected successfully to db');
  } catch (error) {
    const connection = mysql2.createPool({
      host: process.env.HOST,
      user: process.env.DB_USERNAME,
      password: process.env.DB_PASSWORD,
  });

  try {
      await connection.query(`CREATE DATABASE IF NOT EXISTS ${process.env.DB_NAME}`);
      console.log(`Database ${process.env.DB_NAME} created`);
  } catch (error) {
      console.error('Error in creating db');
  } finally {
      await connection.end();
  }
  }
};

export default sequelize;
