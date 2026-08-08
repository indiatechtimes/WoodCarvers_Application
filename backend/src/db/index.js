import mongoose from 'mongoose';
import { DB_NAME } from '../constants.js';
import dotenv from "dotenv";
dotenv.config({
  path: "../.env",
});

const connectDB = async () => {
  const uri = process.env.MONGO_URL;
  if (!uri) throw new Error('MONGO_URL is not set');
  await mongoose.connect(uri, { dbName: DB_NAME });
  console.log(`MongoDB connected to db: ${DB_NAME}`);
};

export default connectDB;
