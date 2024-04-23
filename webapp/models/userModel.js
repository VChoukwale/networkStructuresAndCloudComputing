import { DataTypes } from "sequelize";
// import bcrypt from "bcrypt";
import sequelize from "../config/dbConfig.js";

const User = sequelize.define(
  "User",
  {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
      allowNull: false,
    },
    firstName: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    lastName: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    username: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true,
      validate: {
        isEmail: true,
      },
    },
    password: {
      type: DataTypes.STRING,
      allowNull: false
    },
    token:{
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      allowNull: false,
      field: "token", 
    },
    tokenExpiry:{
      type: DataTypes.DATE,
      field: "tokenExpiry",
    },
    statusVerification:{
      type: DataTypes.BOOLEAN,
      defaultValue: false,
      allowNull: false,
      field: "statusVerification",
    },
    // emailStatusVerification:{
    //   type: DataTypes.BOOLEAN,
    //   defaultValue: false,
    //   allowNull: false,
    //   field: "emailStatusVerification",
    // },
    account_created: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW,
      readonly: true,
      allowNull: false,
    },
    account_updated: {
      type: DataTypes.DATE,
    },
  },
  {
    tableName: "User",
    timestamps: false,
  }
);

export default User;
