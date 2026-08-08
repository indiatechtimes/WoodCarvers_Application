import User from '../models/User.js';
import ApiError from '../utils/ApiError.js';
import asyncHandler from '../utils/asyncHandler.js';
import { signAccessToken, signRefreshToken, verifyRefreshToken } from '../utils/tokens.js';

const buildTokens = async (user) => {
  const payload = { id: user._id.toString(), role: user.role, email: user.email };
  const accessToken = signAccessToken(payload);
  const refreshToken = signRefreshToken(payload);
  user.refreshTokens = [...(user.refreshTokens || []).slice(-4), refreshToken];
  await user.save();
  return { accessToken, refreshToken };
};

export const register = asyncHandler(async (req, res) => {
  const { name, email, password } = req.body;
  if (!name || !email || !password) throw new ApiError(400, 'name, email and password are required');
  if (password.length < 6) throw new ApiError(400, 'Password must be at least 6 characters');
  const exists = await User.findOne({ email: email.toLowerCase() });
  if (exists) throw new ApiError(409, 'Email already registered');
  const user = await User.create({ name, email: email.toLowerCase(), password });
  const tokens = await buildTokens(user);
  res.status(201).json({ success: true, user, ...tokens });
});

export const login = asyncHandler(async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) throw new ApiError(400, 'email and password are required');
  const user = await User.findOne({ email: email.toLowerCase() });
  if (!user) throw new ApiError(401, 'Invalid credentials');
  const ok = await user.comparePassword(password);
  if (!ok) throw new ApiError(401, 'Invalid credentials');
  const tokens = await buildTokens(user);
  res.json({ success: true, user, ...tokens });
});

export const refresh = asyncHandler(async (req, res) => {
  const { refreshToken } = req.body;
  if (!refreshToken) throw new ApiError(400, 'refreshToken required');
  let decoded;
  try {
    decoded = verifyRefreshToken(refreshToken);
  } catch (_) {
    throw new ApiError(401, 'Invalid refresh token');
  }
  const user = await User.findById(decoded.id);
  if (!user || !user.refreshTokens.includes(refreshToken)) {
    throw new ApiError(401, 'Refresh token not recognized');
  }
  // rotate
  user.refreshTokens = user.refreshTokens.filter((t) => t !== refreshToken);
  const payload = { id: user._id.toString(), role: user.role, email: user.email };
  const accessToken = signAccessToken(payload);
  const newRefresh = signRefreshToken(payload);
  user.refreshTokens.push(newRefresh);
  await user.save();
  res.json({ success: true, accessToken, refreshToken: newRefresh });
});

export const logout = asyncHandler(async (req, res) => {
  const { refreshToken } = req.body;
  if (req.user && refreshToken) {
    req.user.refreshTokens = req.user.refreshTokens.filter((t) => t !== refreshToken);
    await req.user.save();
  }
  res.json({ success: true, message: 'Logged out' });
});

export const me = asyncHandler(async (req, res) => {
  res.json({ success: true, user: req.user });
});

export const updateProfile = asyncHandler(async (req, res) => {
  const { name, phone, address } = req.body;
  if (name) req.user.name = name;
  if (phone !== undefined) req.user.phone = phone;
  if (address) req.user.address = { ...req.user.address.toObject?.() || req.user.address, ...address };
  await req.user.save();
  res.json({ success: true, user: req.user });
});

export const registerFcmToken = asyncHandler(async (req, res) => {
  const { token } = req.body;
  if (!token) throw new ApiError(400, 'token required');
  if (!req.user.fcmTokens.includes(token)) {
    req.user.fcmTokens.push(token);
    await req.user.save();
  }
  res.json({ success: true });
});
