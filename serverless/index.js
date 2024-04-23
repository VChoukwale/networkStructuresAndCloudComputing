import functions from "@google-cloud/functions-framework";
import Mailgun from "mailgun.js";
import formData from "form-data";
import mysql from "mysql2/promise";
import dotenv from "dotenv";

dotenv.config();

console.log("New Mailgun.");
//const formData = require('form-data');
//const Mailgun = require('mailgun.js');
const mailgun = new Mailgun(formData);
const mg = mailgun.client({ username: "api", key: process.env.API_KEY });

console.log("check helloPubSub");
functions.cloudEvent("helloPubSub", (cloudEvent) => {
  const base64name = cloudEvent.data.message.data;
  let userDetails = base64name
    ? Buffer.from(base64name, "base64").toString()
    : {};
  console.log("Test Json");
  userDetails = JSON.parse(userDetails);
  console.log("Check JSON");

  mg.messages
    .create(process.env.DOMAIN, {
      from: "Service Team <mailgun@email.vaishc.me>",
      to: [userDetails.username],
      subject: "Verify Your Email",
      text: `Hello, ${userDetails.first_name},
        Thank you for signing up! Please complete verification for your account! `,
      html: `
      <p>Hello ${userDetails.first_name}</p>
      <p>
        Thank you for signing up! Please verify your account by clicking the link
        below:
      </p>
      <a href="https://vaishc.me/v1/user/verify/${userDetails.token}"
        >Click here</a
      >
      <h4>IMP: The Link Will Get Expired in 2 Minutes!</h4>
      `,
    })
    .then(async (message) => {
      console.log("Email Sent Successfully");

      await updateDatabase(
        process.env.HOST,
        process.env.DB_USERNAME,
        process.env.DB_PASSWORD,
        process.env.DB_NAME,
        userDetails.id
      );
    })
    .catch((error) => {
      console.log("Failed! Verification Mail Failed to Send! ", error)
    });

  console.log("Failed Email Verification")
});

const updateDatabase = async (
  HOST,
  DB_USERNAME,
  DB_PASSWORD,
  DATABASE,
  userID
) => {
  try {
    const connection = await mysql.createConnection({
      host: HOST,
      user: DB_USERNAME,
      password: DB_PASSWORD,
    })
    const test = true

    await connection.query(
      `UPDATE ${DATABASE}.Users SET verification_email_status = ${test} WHERE id = ${userID}`
      )
  } catch (error) {
    console.log("Failed Update to Database ", error)
  }
};
