import mongoose from 'mongoose';
import Review from '../models/Review.js';
import Product from '../models/Product.js';
import Order from '../models/Order.js';
import ApiError from '../utils/ApiError.js';
import asyncHandler from '../utils/asyncHandler.js';
import { PAYMENT_STATUS } from '../constants.js';

const assertValidId = (id) => {
  if (!mongoose.isValidObjectId(id)) throw new ApiError(400, 'Invalid id');
};

const hasPurchased = async (userId, productId) => {
  const count = await Order.countDocuments({
    user: userId,
    paymentStatus: PAYMENT_STATUS.PAID,
    'items.product': productId,
  });
  return count > 0;
};

const recomputeProductRating = async (productId) => {
  const stats = await Review.aggregate([
    { $match: { product: new mongoose.Types.ObjectId(productId) } },
    { $group: { _id: '$product', avg: { $avg: '$rating' }, count: { $sum: 1 } } },
  ]);
  const rating = stats[0]?.avg || 0;
  const reviewCount = stats[0]?.count || 0;
  await Product.updateOne({ _id: productId }, { $set: { rating: Number(rating.toFixed(2)), reviewCount } });
};

export const listReviews = asyncHandler(async (req, res) => {
  const { productId } = req.params;
  assertValidId(productId);
  const reviews = await Review.find({ product: productId }).sort('-createdAt');
  const summary = await Review.aggregate([
    { $match: { product: new mongoose.Types.ObjectId(productId) } },
    { $group: { _id: '$rating', count: { $sum: 1 } } },
  ]);
  const distribution = { 5: 0, 4: 0, 3: 0, 2: 0, 1: 0 };
  summary.forEach((s) => { distribution[s._id] = s.count; });

  let canReview = false;
  let alreadyReviewed = false;
  if (req.user) {
    canReview = await hasPurchased(req.user._id, productId);
    alreadyReviewed = reviews.some((r) => r.user.toString() === req.user._id.toString());
  }
  res.json({ success: true, reviews, distribution, canReview, alreadyReviewed });
});

export const createReview = asyncHandler(async (req, res) => {
  const { productId } = req.params;
  assertValidId(productId);
  const { rating, title, body, photos } = req.body;
  const n = Number(rating);
  if (!Number.isInteger(n) || n < 1 || n > 5) throw new ApiError(400, 'rating must be an integer between 1 and 5');
  if (!body || body.trim().length < 3) throw new ApiError(400, 'review body required');

  const product = await Product.findById(productId);
  if (!product) throw new ApiError(404, 'Product not found');

  const purchased = await hasPurchased(req.user._id, productId);
  if (!purchased) throw new ApiError(403, 'Only buyers of this piece can leave a review');

  const cleanPhotos = Array.isArray(photos)
    ? photos.slice(0, 2).filter((p) => p && p.url).map((p) => ({ url: p.url, publicId: p.publicId || '' }))
    : [];

  const review = await Review.findOneAndUpdate(
    { product: productId, user: req.user._id },
    {
      product: productId,
      user: req.user._id,
      userName: req.user.name,
      rating: n,
      title: title || '',
      body: body.trim(),
      photos: cleanPhotos,
      verified: true,
    },
    { new: true, upsert: true, setDefaultsOnInsert: true }
  );
  await recomputeProductRating(product._id);
  res.status(201).json({ success: true, review });
});

export const deleteReview = asyncHandler(async (req, res) => {
  assertValidId(req.params.id);
  const review = await Review.findById(req.params.id);
  if (!review) throw new ApiError(404, 'Review not found');
  if (review.user.toString() !== req.user._id.toString() && req.user.role !== 'admin') {
    throw new ApiError(403, 'Not allowed');
  }
  const productId = review.product;
  await review.deleteOne();
  await recomputeProductRating(productId);
  res.json({ success: true });
});
