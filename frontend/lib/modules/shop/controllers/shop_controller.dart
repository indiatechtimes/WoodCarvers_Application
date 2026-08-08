import 'package:get/get.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/product_repository.dart';

class ShopController extends GetxController {
  final _repo = ProductRepository();

  final RxList<ProductModel> products = <ProductModel>[].obs;
  final RxInt total = 0.obs;
  final RxBool loading = true.obs;
  final RxBool loadingMore = false.obs;
  final RxInt page = 1.obs;

  // Filters — mirror the React app's URL search params
  final RxString category = ''.obs;
  final RxString searchQuery = ''.obs;
  final RxString sort = '-createdAt'.obs;
  final RxString priceRange = ''.obs; // e.g. "0-1499"
  final RxString minRating = ''.obs;
  final RxBool inStockOnly = false.obs;
  final RxString viewMode = 'grid'.obs; // 'grid' | 'list'

  static const categories = [
    ('', 'All'),
    ('wall-decor', 'Wall Décor'),
    ('home-decor', 'Home Décor'),
    ('kitchen', 'Kitchen'),
    ('office', 'Office'),
    ('gifts', 'Gifts'),
    ('personalized', 'Personalized'),
  ];

  static const priceRanges = [
    ('', 'Any price'),
    ('0-1499', 'Under ₹1,499'),
    ('1500-2999', '₹1,500 – ₹2,999'),
    ('3000-4999', '₹3,000 – ₹4,999'),
    ('5000-999999', '₹5,000 & above'),
  ];

  static const sortOptions = [
    ('-createdAt', 'Newest'),
    ('price', 'Price: Low to High'),
    ('-price', 'Price: High to Low'),
    ('-rating', 'Top rated'),
  ];

  int get activeFilterCount => [
    category.value,
    searchQuery.value,
    priceRange.value,
    minRating.value,
    inStockOnly.value ? 'true' : '',
  ].where((v) => v.isNotEmpty).length;

  @override
  void onInit() {
    super.onInit();
    // Pick up ?category= / ?q= / ?sort= passed via Get.toNamed
    final params = Get.parameters;
    if (params['category'] != null) category.value = params['category']!;
    if (params['q'] != null) searchQuery.value = params['q']!;
    if (params['sort'] != null) sort.value = params['sort']!;

    everAll([
      category,
      searchQuery,
      sort,
      priceRange,
      minRating,
      inStockOnly,
    ], (_) => _refetch());
    _refetch();
  }

  void _refetch() {
    page.value = 1;
    _fetch(reset: true);
  }

  Future<void> loadMore() async {
    if (loadingMore.value || products.length >= total.value) return;
    page.value += 1;
    await _fetch(reset: false);
  }

  Future<void> _fetch({required bool reset}) async {
    if (reset) {
      loading.value = true;
    } else {
      loadingMore.value = true;
    }
    try {
      double? minPrice;
      double? maxPrice;
      if (priceRange.value.isNotEmpty) {
        final parts = priceRange.value.split('-');
        minPrice = double.tryParse(parts[0]);
        maxPrice = parts.length > 1 ? double.tryParse(parts[1]) : null;
      }

      final result = await _repo.listProducts(
        params: {
          if (category.value.isNotEmpty) 'category': category.value,
          if (searchQuery.value.isNotEmpty) 'q': searchQuery.value,
          'sort': sort.value,
          if (minPrice != null) 'minPrice': minPrice,
          if (maxPrice != null) 'maxPrice': maxPrice,
          if (minRating.value.isNotEmpty) 'minRating': minRating.value,
          if (inStockOnly.value) 'inStock': 'true',
          'page': page.value,
          'limit': 12,
        },
      );

      total.value = result.total;
      if (reset) {
        products.value = result.products;
      } else {
        products.addAll(result.products);
      }
    } finally {
      loading.value = false;
      loadingMore.value = false;
    }
  }

  void clearAllFilters() {
    category.value = '';
    searchQuery.value = '';
    priceRange.value = '';
    minRating.value = '';
    inStockOnly.value = false;
    sort.value = '-createdAt';
  }
}
