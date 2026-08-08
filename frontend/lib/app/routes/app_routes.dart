abstract class Routes {
  static const splash = '/splash';
  static const home = '/';
  static const shop = '/shop';
  static const productDetail = '/product/:slug';
  static const checkout = '/checkout';
  static const auth = '/auth'; // covers both /login and /register via a mode arg
  static const account = '/account';
  static const orders = '/orders';
  static const orderDetail = '/orders/:id';
  static const wishlist = '/wishlist';
  static const publicWishlist = '/w/:shareId';
  static const about = '/about';
  static const admin = '/admin';
}
