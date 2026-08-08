import asyncHandler from '../utils/asyncHandler.js';
import ApiError from '../utils/ApiError.js';
import { isCloudinaryConfigured, uploadBufferToCloudinary } from '../utils/cloudinary.js';

export const cloudinaryStatus = asyncHandler(async (req, res) => {
  res.json({ success: true, enabled: isCloudinaryConfigured() });
});

export const uploadMedia = asyncHandler(async (req, res) => {
  if (!req.file) throw new ApiError(400, 'No file uploaded');
  const type = req.file.mimetype.startsWith('video/') ? 'video' : 'image';
  if (isCloudinaryConfigured()) {
    const result = await uploadBufferToCloudinary(req.file.buffer, type);
    return res.json({
      success: true,
      media: { url: result.secure_url, publicId: result.public_id, type },
    });
  }
  const base64 = req.file.buffer.toString('base64');
  const dataUrl = `data:${req.file.mimetype};base64,${base64}`;
  res.json({
    success: true,
    media: { url: dataUrl, publicId: '', type },
    warning: 'Cloudinary not configured; returned data URL. Configure CLOUDINARY_* env vars for production.',
  });
});

// User-scoped image upload (for review photos). Images only, hard-capped folder.
export const uploadReviewPhoto = asyncHandler(async (req, res) => {
  if (!req.file) throw new ApiError(400, 'No file uploaded');
  if (!req.file.mimetype.startsWith('image/')) throw new ApiError(400, 'Only image uploads allowed');
  if (isCloudinaryConfigured()) {
    const result = await uploadBufferToCloudinary(req.file.buffer, 'image', 'bamboo-decor/reviews');
    return res.json({ success: true, media: { url: result.secure_url, publicId: result.public_id, type: 'image' } });
  }
  const base64 = req.file.buffer.toString('base64');
  res.json({
    success: true,
    media: { url: `data:${req.file.mimetype};base64,${base64}`, publicId: '', type: 'image' },
  });
});
