import '../models/product_model.dart';
import '../providers/api_provider.dart';

class ProductListResult {
  final List<ProductModel> products;
  final int total;
  final int page;
  final int limit;

  ProductListResult({
    required this.products,
    required this.total,
    required this.page,
    required this.limit,
  });
}

class ProductRepository {
  final _api = ApiProvider().dio;

  /// Matches the backend's query params exactly: q, category, featured,
  /// bestSeller, newArrival, minPrice, maxPrice, minRating, inStock, sort,
  /// page, limit.
  Future<ProductListResult> listProducts({Map<String, dynamic>? params}) async {
    final res = await _api.get('/products', queryParameters: params);
    final list = (res.data['products'] as List? ?? []);
    return ProductListResult(
      products: list.map((p) => ProductModel.fromJson(p)).toList(),
      total: res.data['total'] ?? 0,
      page: res.data['page'] ?? 1,
      limit: res.data['limit'] ?? 24,
    );
  }

  /// Returns (product, relatedProducts) — backend returns both together.
  Future<(ProductModel, List<ProductModel>)> getProduct(String idOrSlug) async {
    final res = await _api.get('/products/$idOrSlug');
    final product = ProductModel.fromJson(res.data['product']);
    final related = (res.data['related'] as List? ?? [])
        .map((p) => ProductModel.fromJson(p))
        .toList();
    return (product, related);
  }

  // Admin CRUD
  Future<ProductModel> createProduct(Map<String, dynamic> data) async {
    final res = await _api.post('/products', data: data);
    return ProductModel.fromJson(res.data['product']);
  }

  Future<ProductModel> updateProduct(String id, Map<String, dynamic> data) async {
    final res = await _api.put('/products/$id', data: data);
    return ProductModel.fromJson(res.data['product']);
  }

  Future<void> deleteProduct(String id) async {
    await _api.delete('/products/$id');
  }
}
