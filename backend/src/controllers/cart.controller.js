import Cart from '../models/Cart.js';
import Product from '../models/Product.js';
import ApiError from '../utils/ApiError.js';
import asyncHandler from '../utils/asyncHandler.js';

const getOrCreateCart = async (userId) => {
  let cart = await Cart.findOne({ user: userId }).populate('items.product');
  if (!cart) {
    cart = await Cart.create({ user: userId, items: [] });
    cart = await cart.populate('items.product');
  }
  return cart;
};

export const getCart = asyncHandler(async (req, res) => {
  const cart = await getOrCreateCart(req.user._id);
  res.json({ success: true, cart });
});

export const addToCart = asyncHandler(async (req, res) => {
  const { productId, quantity = 1 } = req.body;
  const q = Number(quantity);
  if (!Number.isInteger(q) || q < 1) throw new ApiError(400, 'quantity must be a positive integer');
  const product = await Product.findById(productId);
  if (!product) throw new ApiError(404, 'Product not found');
  let cart = await Cart.findOne({ user: req.user._id });
  if (!cart) cart = await Cart.create({ user: req.user._id, items: [] });
  const existing = cart.items.find((i) => i.product.toString() === productId);
  const target = (existing?.quantity || 0) + q;
  if (target > product.stock) throw new ApiError(400, `Only ${product.stock} available in stock`);
  if (existing) existing.quantity = target;
  else cart.items.push({ product: productId, quantity: q });
  await cart.save();
  await cart.populate('items.product');
  res.json({ success: true, cart });
});

export const updateItem = asyncHandler(async (req, res) => {
  const { productId, quantity } = req.body;
  const q = Number(quantity);
  if (!Number.isInteger(q) || q < 0) throw new ApiError(400, 'quantity must be a non-negative integer');
  const cart = await Cart.findOne({ user: req.user._id });
  if (!cart) throw new ApiError(404, 'Cart not found');
  const item = cart.items.find((i) => i.product.toString() === productId);
  if (!item) throw new ApiError(404, 'Item not in cart');
  if (q === 0) {
    cart.items = cart.items.filter((i) => i.product.toString() !== productId);
  } else {
    const product = await Product.findById(productId);
    if (!product) throw new ApiError(404, 'Product not found');
    if (q > product.stock) throw new ApiError(400, `Only ${product.stock} available in stock`);
    item.quantity = q;
  }
  await cart.save();
  await cart.populate('items.product');
  res.json({ success: true, cart });
});

export const removeItem = asyncHandler(async (req, res) => {
  const { productId } = req.params;
  const cart = await Cart.findOne({ user: req.user._id });
  if (!cart) throw new ApiError(404, 'Cart not found');
  cart.items = cart.items.filter((i) => i.product.toString() !== productId);
  await cart.save();
  await cart.populate('items.product');
  res.json({ success: true, cart });
});

export const clearCart = asyncHandler(async (req, res) => {
  const cart = await Cart.findOne({ user: req.user._id });
  if (cart) {
    cart.items = [];
    await cart.save();
  }
  res.json({ success: true, cart: cart || { items: [] } });
});
