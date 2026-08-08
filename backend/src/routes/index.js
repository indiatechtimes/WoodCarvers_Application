import { Router } from 'express';
import multer from 'multer';
import * as auth from '../controllers/auth.controller.js';
import * as product from '../controllers/product.controller.js';
import * as cart from '../controllers/cart.controller.js';
import * as order from '../controllers/order.controller.js';
import * as media from '../controllers/media.controller.js';
import * as review from '../controllers/review.controller.js';
import * as wishlist from '../controllers/wishlist.controller.js';
import * as coupon from '../controllers/coupon.controller.js';
import * as setting from '../controllers/setting.controller.js';
import * as address from '../controllers/address.controller.js';
import * as analytics from '../controllers/analytics.controller.js';
import { requireAuth, requireAdmin, optionalAuth as optionalAuthMw } from '../middleware/auth.js';

const router = Router();
const upload = multer({ storage: multer.memoryStorage(), limits: { fileSize: 25 * 1024 * 1024 } });

router.get('/', (req, res) => res.json({ success: true, message: 'WOOD CARVERS API', ok: true }));

// Auth
router.post('/auth/register', auth.register);
router.post('/auth/login', auth.login);
router.post('/auth/refresh', auth.refresh);
router.post('/auth/logout', requireAuth, auth.logout);
router.get('/auth/me', requireAuth, auth.me);
router.put('/auth/profile', requireAuth, auth.updateProfile);
router.post('/auth/fcm-token', requireAuth, auth.registerFcmToken);

// Addresses
router.get('/addresses', requireAuth, address.listAddresses);
router.post('/addresses', requireAuth, address.addAddress);
router.put('/addresses/:id', requireAuth, address.updateAddress);
router.delete('/addresses/:id', requireAuth, address.deleteAddress);

// Products
router.get('/products', product.listProducts);
router.get('/products/:idOrSlug', product.getProduct);
router.post('/products', requireAuth, requireAdmin, product.createProduct);
router.put('/products/:id', requireAuth, requireAdmin, product.updateProduct);
router.delete('/products/:id', requireAuth, requireAdmin, product.deleteProduct);

// Cart
router.get('/cart', requireAuth, cart.getCart);
router.post('/cart/add', requireAuth, cart.addToCart);
router.put('/cart/item', requireAuth, cart.updateItem);
router.delete('/cart/item/:productId', requireAuth, cart.removeItem);
router.delete('/cart', requireAuth, cart.clearCart);

// Orders
router.get('/orders/razorpay/status', order.razorpayStatus);
router.post('/orders', requireAuth, order.createOrder);
router.post('/orders/verify', requireAuth, order.verifyPayment);
router.get('/orders', requireAuth, order.listMyOrders);
router.get('/orders/all', requireAuth, requireAdmin, order.listAllOrders);
router.get('/orders/:id', requireAuth, order.getMyOrder);
router.put('/orders/:id/status', requireAuth, requireAdmin, order.updateOrderStatus);

// Media
router.get('/media/status', media.cloudinaryStatus);
router.post('/media/upload', requireAuth, requireAdmin, upload.single('file'), media.uploadMedia);
router.post('/media/upload/review', requireAuth, upload.single('file'), media.uploadReviewPhoto);

// Reviews
router.get('/products/:productId/reviews', optionalAuthMw, review.listReviews);
router.post('/products/:productId/reviews', requireAuth, review.createReview);
router.delete('/reviews/:id', requireAuth, review.deleteReview);

// Wishlist
router.get('/wishlist', requireAuth, wishlist.getWishlist);
router.get('/wishlist/ids', requireAuth, wishlist.getWishlistIds);
router.post('/wishlist/toggle', requireAuth, wishlist.toggleWishlist);
router.get('/wishlist/share-link', requireAuth, wishlist.getShareLink);
router.get('/wishlist/public/:shareId', wishlist.getPublicWishlist);

// Coupons
router.post('/coupons/validate', coupon.validateCoupon);
router.get('/coupons', requireAuth, requireAdmin, coupon.listCoupons);
router.post('/coupons', requireAuth, requireAdmin, coupon.createCoupon);
router.put('/coupons/:id', requireAuth, requireAdmin, coupon.updateCoupon);
router.delete('/coupons/:id', requireAuth, requireAdmin, coupon.deleteCoupon);

// Settings (public read, admin write)
router.get('/settings', setting.listSettings);
router.put('/settings/:key', requireAuth, requireAdmin, setting.updateSetting);

// Admin analytics
router.get('/admin/analytics', requireAuth, requireAdmin, analytics.dashboardStats);

export default router;
