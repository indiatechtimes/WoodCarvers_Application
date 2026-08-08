import crypto from 'crypto';
import Razorpay from 'razorpay';
import Order from '../models/Order.js';
import Cart from '../models/Cart.js';
import Product from '../models/Product.js';
import User from '../models/User.js';
import Coupon from '../models/Coupon.js';
import ApiError from '../utils/ApiError.js';
import asyncHandler from '../utils/asyncHandler.js';
import { ORDER_STATUS, PAYMENT_STATUS, ROLES } from '../constants.js';
import { sendPushToTokens } from '../utils/fcm.js';
import { applyCoupon } from './coupon.controller.js';

const getRazorpay = () => {
  const { RAZORPAY_KEY_ID, RAZORPAY_KEY_SECRET } = process.env;
  if (!RAZORPAY_KEY_ID || !RAZORPAY_KEY_SECRET) return null;
  return new Razorpay({ key_id: RAZORPAY_KEY_ID, key_secret: RAZORPAY_KEY_SECRET });
};

export const razorpayStatus = asyncHandler(async (req, res) => {
  res.json({
    success: true,
    enabled: Boolean(process.env.RAZORPAY_KEY_ID && process.env.RAZORPAY_KEY_SECRET),
    keyId: process.env.RAZORPAY_KEY_ID || null,
  });
});

export const createOrder = asyncHandler(async (req, res) => {
  const { shippingAddress, notes, couponCode } = req.body;
  if (!shippingAddress?.name || !shippingAddress?.line1 || !shippingAddress?.city || !shippingAddress?.pincode) {
    throw new ApiError(400, 'Shipping address is incomplete');
  }
  const cart = await Cart.findOne({ user: req.user._id }).populate('items.product');
  if (!cart || cart.items.length === 0) throw new ApiError(400, 'Cart is empty');

  const items = cart.items.map((ci) => ({
    product: ci.product._id,
    name: ci.product.name,
    image: ci.product.media?.[0]?.url || '',
    price: ci.product.price,
    quantity: ci.quantity,
  }));
  const subtotal = items.reduce((s, it) => s + it.price * it.quantity, 0);

  let discount = 0;
  let appliedCode = '';
  if (couponCode) {
    const coupon = await Coupon.findOne({ code: String(couponCode).toUpperCase() });
    if (coupon) {
      const result = applyCoupon({ subtotal }, coupon);
      if (result.error) throw new ApiError(400, result.error);
      discount = result.discount;
      appliedCode = coupon.code;
    }
  }

  const afterDiscount = subtotal - discount;
  const shipping = afterDiscount >= 1499 ? 0 : 99;
  const tax = Math.round(afterDiscount * 0.05);
  const total = afterDiscount + shipping + tax;

  const order = await Order.create({
    user: req.user._id,
    items,
    subtotal,
    discount,
    couponCode: appliedCode,
    shipping,
    tax,
    total,
    shippingAddress,
    notes: notes || '',
  });

  const rp = getRazorpay();
  if (rp) {
    const rpOrder = await rp.orders.create({
      amount: total * 100,
      currency: 'INR',
      receipt: order._id.toString().slice(-20),
      notes: { orderId: order._id.toString() },
    });
    order.razorpayOrderId = rpOrder.id;
    await order.save();
    return res.status(201).json({
      success: true,
      order,
      razorpay: { orderId: rpOrder.id, keyId: process.env.RAZORPAY_KEY_ID, amount: rpOrder.amount, currency: rpOrder.currency },
    });
  }
  const mockOrderId = `mock_${crypto.randomBytes(6).toString('hex')}`;
  order.razorpayOrderId = mockOrderId;
  await order.save();
  res.status(201).json({
    success: true,
    order,
    razorpay: { orderId: mockOrderId, keyId: null, amount: total * 100, currency: 'INR', mock: true },
  });
});

export const verifyPayment = asyncHandler(async (req, res) => {
  const { orderId, razorpay_order_id, razorpay_payment_id, razorpay_signature } = req.body;
  const order = await Order.findById(orderId);
  if (!order) throw new ApiError(404, 'Order not found');
  if (order.user.toString() !== req.user._id.toString()) throw new ApiError(403, 'Not your order');

  // Idempotent: already-paid orders return without repeating side effects
  if (order.paymentStatus === PAYMENT_STATUS.PAID) {
    return res.json({ success: true, order, alreadyVerified: true });
  }

  const rp = getRazorpay();
  let verified = false;
  if (rp && process.env.RAZORPAY_KEY_SECRET) {
    const expected = crypto
      .createHmac('sha256', process.env.RAZORPAY_KEY_SECRET)
      .update(`${razorpay_order_id}|${razorpay_payment_id}`)
      .digest('hex');
    verified = expected === razorpay_signature;
  } else {
    verified = true;
  }

  if (!verified) {
    order.paymentStatus = PAYMENT_STATUS.FAILED;
    order.status = ORDER_STATUS.FAILED;
    await order.save();
    throw new ApiError(400, 'Payment signature verification failed');
  }

  // Atomic compare-and-set: only proceed with side effects if we win the transition
  const claim = await Order.updateOne(
    { _id: order._id, paymentStatus: { $ne: PAYMENT_STATUS.PAID } },
    {
      $set: {
        razorpayPaymentId: razorpay_payment_id || `mock_pay_${Date.now()}`,
        razorpaySignature: razorpay_signature || 'mock',
        paymentStatus: PAYMENT_STATUS.PAID,
        status: ORDER_STATUS.PAID,
      },
    }
  );
  if (claim.modifiedCount === 0) {
    const fresh = await Order.findById(order._id);
    return res.json({ success: true, order: fresh, alreadyVerified: true });
  }
  const updated = await Order.findById(order._id);

  // Bump coupon usage
  if (updated.couponCode) {
    await Coupon.updateOne({ code: updated.couponCode }, { $inc: { usedCount: 1 } });
  }

  // Decrement stock and clear cart
  await Promise.all(
    updated.items.map((it) => Product.updateOne({ _id: it.product }, { $inc: { stock: -it.quantity } }))
  );
  await Cart.updateOne({ user: req.user._id }, { $set: { items: [] } });

  sendPushToTokens(
    req.user.fcmTokens || [],
    { title: 'Payment received', body: `Your order #${updated._id.toString().slice(-6)} is confirmed.` },
    { orderId: updated._id.toString(), status: updated.status }
  );

  res.json({ success: true, order: updated });
});

export const listMyOrders = asyncHandler(async (req, res) => {
  const orders = await Order.find({ user: req.user._id }).sort('-createdAt');
  res.json({ success: true, orders });
});

export const getMyOrder = asyncHandler(async (req, res) => {
  const order = await Order.findById(req.params.id);
  if (!order) throw new ApiError(404, 'Order not found');
  if (order.user.toString() !== req.user._id.toString() && req.user.role !== ROLES.ADMIN) {
    throw new ApiError(403, 'Not allowed');
  }
  res.json({ success: true, order });
});

export const listAllOrders = asyncHandler(async (req, res) => {
  const orders = await Order.find().sort('-createdAt').populate('user', 'name email');
  res.json({ success: true, orders });
});

export const updateOrderStatus = asyncHandler(async (req, res) => {
  const { status } = req.body;
  if (!Object.values(ORDER_STATUS).includes(status)) throw new ApiError(400, 'invalid status');
  const order = await Order.findById(req.params.id);
  if (!order) throw new ApiError(404, 'Order not found');
  order.status = status;
  await order.save();

  const user = await User.findById(order.user);
  if (user) {
    sendPushToTokens(
      user.fcmTokens || [],
      { title: `Order ${status}`, body: `Your order #${order._id.toString().slice(-6)} is now ${status}.` },
      { orderId: order._id.toString(), status }
    );
  }
  res.json({ success: true, order });
});
