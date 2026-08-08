import Product from '../models/Product.js';
import ApiError from '../utils/ApiError.js';
import asyncHandler from '../utils/asyncHandler.js';

const slugify = (s) =>
  s.toLowerCase().trim().replace(/[^\w\s-]/g, '').replace(/\s+/g, '-').replace(/-+/g, '-');

export const listProducts = asyncHandler(async (req, res) => {
  const { q, category, featured, bestSeller, newArrival, minPrice, maxPrice, minRating, inStock, limit = 24, page = 1, sort = '-createdAt' } = req.query;
  const filter = { active: true };
  if (category) filter.category = category;
  if (featured === 'true') filter.featured = true;
  if (bestSeller === 'true') filter.bestSeller = true;
  if (newArrival === 'true') filter.newArrival = true;
  if (inStock === 'true') filter.stock = { $gt: 0 };
  if (minRating) filter.rating = { $gte: Number(minRating) };
  if (minPrice || maxPrice) {
    filter.price = {};
    if (minPrice) filter.price.$gte = Number(minPrice);
    if (maxPrice) filter.price.$lte = Number(maxPrice);
  }
  if (q) filter.$text = { $search: q };
  const skip = (Number(page) - 1) * Number(limit);
  const [products, total] = await Promise.all([
    Product.find(filter).sort(sort).skip(skip).limit(Number(limit)),
    Product.countDocuments(filter),
  ]);
  res.json({ success: true, products, total, page: Number(page), limit: Number(limit) });
});

export const getProduct = asyncHandler(async (req, res) => {
  const { idOrSlug } = req.params;
  const isId = /^[0-9a-fA-F]{24}$/.test(idOrSlug);
  const product = await Product.findOne(isId ? { _id: idOrSlug } : { slug: idOrSlug });
  if (!product) throw new ApiError(404, 'Product not found');
  const related = await Product.find({
    _id: { $ne: product._id },
    active: true,
    category: product.category,
  }).limit(4).sort('-featured -rating');
  res.json({ success: true, product, related });
});

export const createProduct = asyncHandler(async (req, res) => {
  const data = req.body || {};
  if (!data.name || !data.description || data.price == null || !data.category) {
    throw new ApiError(400, 'name, description, price, category required');
  }
  const slug = data.slug ? slugify(data.slug) : slugify(`${data.name}-${Date.now().toString(36)}`);
  const product = await Product.create({ ...data, slug });
  res.status(201).json({ success: true, product });
});

export const updateProduct = asyncHandler(async (req, res) => {
  const product = await Product.findByIdAndUpdate(req.params.id, req.body, { new: true });
  if (!product) throw new ApiError(404, 'Product not found');
  res.json({ success: true, product });
});

export const deleteProduct = asyncHandler(async (req, res) => {
  const product = await Product.findByIdAndDelete(req.params.id);
  if (!product) throw new ApiError(404, 'Product not found');
  res.json({ success: true, message: 'Deleted' });
});
