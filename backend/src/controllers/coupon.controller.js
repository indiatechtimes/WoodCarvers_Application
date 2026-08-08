import Coupon from '../models/Coupon.js';
import ApiError from '../utils/ApiError.js';
import asyncHandler from '../utils/asyncHandler.js';

export const applyCoupon = ({ subtotal }, coupon) => {
  if (!coupon) return { discount: 0, error: null };
  if (!coupon.active) return { discount: 0, error: 'This coupon is not active' };
  if (coupon.expiresAt && new Date(coupon.expiresAt).getTime() < Date.now()) return { discount: 0, error: 'This coupon has expired' };
  if (coupon.usageLimit > 0 && coupon.usedCount >= coupon.usageLimit) return { discount: 0, error: 'This coupon has been fully redeemed' };
  if (subtotal < (coupon.minSubtotal || 0)) return { discount: 0, error: `Minimum subtotal ₹${coupon.minSubtotal} required` };
  let discount = coupon.type === 'percent' ? Math.round((subtotal * coupon.value) / 100) : coupon.value;
  if (coupon.maxDiscount > 0) discount = Math.min(discount, coupon.maxDiscount);
  discount = Math.min(discount, subtotal);
  return { discount, error: null };
};

// PUBLIC: validate + preview discount for the current cart subtotal
export const validateCoupon = asyncHandler(async (req, res) => {
  const code = String(req.body?.code || req.query?.code || '').trim().toUpperCase();
  const subtotal = Number(req.body?.subtotal || req.query?.subtotal || 0);
  if (!code) throw new ApiError(400, 'Coupon code required');
  const coupon = await Coupon.findOne({ code });
  if (!coupon) throw new ApiError(404, 'Invalid coupon code');
  const { discount, error } = applyCoupon({ subtotal }, coupon);
  if (error) throw new ApiError(400, error);
  res.json({ success: true, coupon: { code: coupon.code, description: coupon.description, type: coupon.type, value: coupon.value }, discount });
});

// ADMIN CRUD
export const listCoupons = asyncHandler(async (req, res) => {
  const coupons = await Coupon.find().sort('-createdAt');
  res.json({ success: true, coupons });
});
export const createCoupon = asyncHandler(async (req, res) => {
  const c = await Coupon.create({ ...req.body, code: String(req.body.code || '').toUpperCase().trim() });
  res.status(201).json({ success: true, coupon: c });
});
export const updateCoupon = asyncHandler(async (req, res) => {
  const c = await Coupon.findByIdAndUpdate(req.params.id, req.body, { new: true });
  if (!c) throw new ApiError(404, 'Coupon not found');
  res.json({ success: true, coupon: c });
});
export const deleteCoupon = asyncHandler(async (req, res) => {
  const c = await Coupon.findByIdAndDelete(req.params.id);
  if (!c) throw new ApiError(404, 'Coupon not found');
  res.json({ success: true });
});
