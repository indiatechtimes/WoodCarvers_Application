import mongoose from 'mongoose';

// key-value store for editable site content (banners, hero, logo, etc.)
const settingSchema = new mongoose.Schema(
  {
    key: { type: String, required: true, unique: true, index: true },
    value: { type: mongoose.Schema.Types.Mixed, default: null },
  },
  { timestamps: true }
);

export default mongoose.model('Setting', settingSchema);
