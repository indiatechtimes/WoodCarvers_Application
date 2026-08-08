import 'dotenv/config';
import app from './app.js';
import connectDB from './db/index.js';
import { seedDatabase } from './utils/seed.js';

const PORT = Number(process.env.PORT || 8001);

const start = async () => {
  await connectDB();
  await seedDatabase();
  app.listen(PORT, '0.0.0.0', () => {
    console.log(`Bamboo Decor API listening on http://0.0.0.0:${PORT}`);
  });
};

start().catch((err) => {
  console.error('Fatal startup error', err);
  process.exit(1);
});
