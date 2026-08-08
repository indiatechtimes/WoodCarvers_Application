import 'package:get/get.dart';
import '../../modules/splash/views/splash_view.dart';
import '../../modules/auth/views/auth_view.dart';
import '../../modules/auth/bindings/auth_binding.dart';
import '../../modules/home/views/home_view.dart';
import '../../modules/home/bindings/home_binding.dart';
import '../../modules/shop/views/shop_view.dart';
import '../../modules/shop/bindings/shop_binding.dart';
import '../../modules/product_detail/views/product_detail_view.dart';
import '../../modules/product_detail/bindings/product_detail_binding.dart';
import '../../modules/checkout/views/checkout_view.dart';
import '../../modules/checkout/bindings/checkout_binding.dart';
import '../../modules/orders/views/orders_views.dart';
import '../../modules/orders/bindings/orders_bindings.dart';
import '../../modules/account/views/account_view.dart';
import '../../modules/account/bindings/account_binding.dart';
import '../../modules/wishlist/views/wishlist_views.dart';
import '../../modules/wishlist/bindings/wishlist_bindings.dart';
import '../../modules/about/views/about_view.dart';
import '../../modules/admin/views/admin_view.dart';
import '../../modules/admin/bindings/admin_binding.dart';
import 'app_routes.dart';
import 'auth_guard_middleware.dart';

// All customer-facing and admin modules are wired below.
class AppPages {
  static final pages = [
    GetPage(
      name: Routes.splash,
      page: () => const SplashView(),
    ),
    GetPage(
      name: Routes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.shop,
      page: () => const ShopView(),
      binding: ShopBinding(),
    ),
    GetPage(
      name: Routes.productDetail,
      page: () => const ProductDetailView(),
      binding: ProductDetailBinding(),
    ),
    GetPage(
      name: Routes.checkout,
      page: () => const CheckoutView(),
      binding: CheckoutBinding(),
      middlewares: [AuthGuardMiddleware()],
    ),
    GetPage(
      name: Routes.orders,
      page: () => const OrdersListView(),
      binding: OrdersListBinding(),
      middlewares: [AuthGuardMiddleware()],
    ),
    GetPage(
      name: Routes.orderDetail,
      page: () => const OrderDetailView(),
      binding: OrderDetailBinding(),
      middlewares: [AuthGuardMiddleware()],
    ),
    GetPage(
      name: Routes.account,
      page: () => const AccountView(),
      binding: AccountBinding(),
      middlewares: [AuthGuardMiddleware()],
    ),
    GetPage(
      name: Routes.wishlist,
      page: () => const WishlistView(),
      binding: WishlistBinding(),
    ),
    GetPage(
      name: Routes.publicWishlist,
      page: () => const PublicWishlistView(),
      binding: PublicWishlistBinding(),
    ),
    GetPage(
      name: Routes.about,
      page: () => const AboutView(),
    ),
    GetPage(
      name: Routes.admin,
      page: () => const AdminView(),
      binding: AdminBinding(),
      middlewares: [AuthGuardMiddleware()],
    ),
    GetPage(
      name: Routes.auth,
      page: () => const AuthView(),
      binding: AuthBinding(),
    ),
  ];
}
