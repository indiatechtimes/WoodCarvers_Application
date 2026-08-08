import Setting from '../models/Setting.js';
import ApiError from '../utils/ApiError.js';
import asyncHandler from '../utils/asyncHandler.js';

export const listSettings = asyncHandler(async (req, res) => {
  const settings = await Setting.find();
  const obj = {};
  for (const s of settings) obj[s.key] = s.value;
  res.json({ success: true, settings: obj });
});

export const updateSetting = asyncHandler(async (req, res) => {
  const { key } = req.params;
  const { value } = req.body;
  if (!key) throw new ApiError(400, 'key required');
  const setting = await Setting.findOneAndUpdate(
    { key },
    { $set: { value } },
    { new: true, upsert: true }
  );
  res.json({ success: true, setting });
});
