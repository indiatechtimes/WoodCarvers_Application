import 'dotenv/config';
import mongoose from 'mongoose';
import User from '../src/models/User.js';
import { seedDatabase } from '../src/utils/seed.js';

const mode = process.argv[2];
const output = (data) => process.stdout.write(`PROBE_RESULT=${JSON.stringify(data)}\n`);

await mongoose.connect(process.env.MONGO_URL, { dbName: process.env.DB_NAME });

try {
  if (mode === 'hash') {
    const email = process.argv[3].toLowerCase();
    const user = await User.findOne({ email }).select('+password');
    output({ found: Boolean(user), hash: user?.password || '' });
  } else if (mode === 'seed-update') {
    const suffix = `${Date.now()}_${process.pid}`;
    const email = `test_seed_admin_${suffix}@example.test`;
    const expectedPassword = `UpdatedPass_${suffix}!`;
    const expectedName = `TEST Updated Admin ${suffix}`;
    let user;
    try {
      user = await User.create({
        name: 'TEST Existing User',
        email,
        password: 'OriginalPass123!',
        role: 'user',
      });
      process.env.ADMIN_EMAIL = email;
      process.env.ADMIN_PASSWORD = expectedPassword;
      process.env.ADMIN_NAME = expectedName;
      await seedDatabase();
      user = await User.findOne({ email });
      output({
        found: Boolean(user),
        passwordUpdated: Boolean(user && await user.comparePassword(expectedPassword)),
        role: user?.role || '',
        name: user?.name || '',
        expectedName,
      });
    } finally {
      await User.deleteOne({ email });
    }
  } else {
    throw new Error(`Unknown probe mode: ${mode}`);
  }
} finally {
  await mongoose.disconnect();
}
