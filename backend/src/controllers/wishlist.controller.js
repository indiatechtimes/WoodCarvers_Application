import crypto from 'crypto';
import mongoose from 'mongoose';
import User from '../models/User.js';
import Product from '../models/Product.js';
import ApiError from '../utils/ApiError.js';
import asyncHandler from '../utils/asyncHandler.js';

const assertValidId = (id) => {
  if (!mongoose.isValidObjectId(id)) throw new ApiError(400, 'Invalid product id');
};

export const getWishlist = asyncHandler(async (req, res) => {
  const user = await User.findById(req.user._id).populate('wishlist');
  res.json({ success: true, wishlist: user.wishlist || [] });
});

export const toggleWishlist = asyncHandler(async (req, res) => {
  const { productId } = req.body;
  assertValidId(productId);
  const product = await Product.findById(productId);
  if (!product) throw new ApiError(404, 'Product not found');
  const user = await User.findById(req.user._id);
  const idx = user.wishlist.findIndex((p) => p.toString() === productId);
  let added;
  if (idx >= 0) { user.wishlist.splice(idx, 1); added = false; }
  else { user.wishlist.push(productId); added = true; }
  await user.save();
  res.json({ success: true, added, wishlistIds: user.wishlist.map((p) => p.toString()) });
});

export const getWishlistIds = asyncHandler(async (req, res) => {
  res.json({ success: true, ids: (req.user.wishlist || []).map((p) => p.toString()) });
});

// Get (or lazily create) a public share id for the current user's wishlist
export const getShareLink = asyncHandler(async (req, res) => {
  const user = await User.findById(req.user._id);
  if (!user.wishlistShareId) {
    user.wishlistShareId = crypto.randomBytes(9).toString('base64url');
    await user.save();
  }
  res.json({ success: true, shareId: user.wishlistShareId });
});

// Public: view someone's wishlist by share id (no auth)
export const getPublicWishlist = asyncHandler(async (req, res) => {
  const { shareId } = req.params;
  if (!shareId || shareId.length < 6) throw new ApiError(400, 'Invalid share id');
  const user = await User.findOne({ wishlistShareId: shareId }).populate('wishlist');
  if (!user) throw new ApiError(404, 'Wishlist not found');
  res.json({
    success: true,
    ownerName: user.name.split(' ')[0],
    wishlist: user.wishlist || [],
  });
});
