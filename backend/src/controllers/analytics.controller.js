import Order from '../models/Order.js';
import Product from '../models/Product.js';
import User from '../models/User.js';
import asyncHandler from '../utils/asyncHandler.js';
import { PAYMENT_STATUS } from '../constants.js';

export const dashboardStats = asyncHandler(async (req, res) => {
  const since30 = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);

  const [
    revenueAgg,
    ordersCount,
    productsCount,
    customersCount,
    lowStock,
    recentOrders,
    salesByDay,
    topProducts,
  ] = await Promise.all([
    Order.aggregate([
      { $match: { paymentStatus: PAYMENT_STATUS.PAID } },
      { $group: { _id: null, total: { $sum: '$total' } } },
    ]),
    Order.countDocuments(),
    Product.countDocuments(),
    User.countDocuments({ role: 'user' }),
    Product.find({ stock: { $lte: 5 } }).select('name stock category').limit(6),
    Order.find().sort('-createdAt').limit(6).populate('user', 'name email'),
    Order.aggregate([
      { $match: { paymentStatus: PAYMENT_STATUS.PAID, createdAt: { $gte: since30 } } },
      { $group: { _id: { $dateToString: { format: '%Y-%m-%d', date: '$createdAt' } }, revenue: { $sum: '$total' }, count: { $sum: 1 } } },
      { $sort: { _id: 1 } },
    ]),
    Order.aggregate([
      { $match: { paymentStatus: PAYMENT_STATUS.PAID } },
      { $unwind: '$items' },
      { $group: { _id: '$items.product', name: { $first: '$items.name' }, sold: { $sum: '$items.quantity' }, revenue: { $sum: { $multiply: ['$items.price', '$items.quantity'] } } } },
      { $sort: { sold: -1 } },
      { $limit: 5 },
    ]),
  ]);

  // Fill missing days in last 30d
  const map = new Map(salesByDay.map((s) => [s._id, s]));
  const series = [];
  for (let i = 29; i >= 0; i--) {
    const d = new Date(Date.now() - i * 24 * 60 * 60 * 1000);
    const key = d.toISOString().slice(0, 10);
    const entry = map.get(key) || { _id: key, revenue: 0, count: 0 };
    series.push({ date: key, revenue: entry.revenue, orders: entry.count });
  }

  res.json({
    success: true,
    stats: {
      revenue: revenueAgg[0]?.total || 0,
      ordersCount,
      productsCount,
      customersCount,
    },
    lowStock,
    recentOrders,
    salesSeries: series,
    topProducts,
  });
});
