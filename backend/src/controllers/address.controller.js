import User from '../models/User.js';
import ApiError from '../utils/ApiError.js';
import asyncHandler from '../utils/asyncHandler.js';

export const listAddresses = asyncHandler(async (req, res) => {
  res.json({ success: true, addresses: req.user.addresses || [] });
});

export const addAddress = asyncHandler(async (req, res) => {
  const body = req.body || {};
  if (!body.name || !body.line1 || !body.city || !body.pincode) throw new ApiError(400, 'name, line1, city and pincode required');
  const user = await User.findById(req.user._id);
  if (body.isDefault) user.addresses.forEach((a) => (a.isDefault = false));
  if (user.addresses.length === 0) body.isDefault = true;
  user.addresses.push(body);
  await user.save();
  res.status(201).json({ success: true, addresses: user.addresses });
});

export const updateAddress = asyncHandler(async (req, res) => {
  const user = await User.findById(req.user._id);
  const addr = user.addresses.id(req.params.id);
  if (!addr) throw new ApiError(404, 'Address not found');
  Object.assign(addr, req.body);
  if (req.body.isDefault) user.addresses.forEach((a) => { a.isDefault = a._id.equals(addr._id); });
  await user.save();
  res.json({ success: true, addresses: user.addresses });
});

export const deleteAddress = asyncHandler(async (req, res) => {
  const user = await User.findById(req.user._id);
  const addr = user.addresses.id(req.params.id);
  if (!addr) throw new ApiError(404, 'Address not found');
  addr.deleteOne();
  if (!user.addresses.some((a) => a.isDefault) && user.addresses.length > 0) {
    user.addresses[0].isDefault = true;
  }
  await user.save();
  res.json({ success: true, addresses: user.addresses });
});
