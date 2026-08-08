import '../models/product_model.dart';
import '../providers/api_provider.dart';

class WishlistRepository {
  final _api = ApiProvider().dio;

  Future<List<String>> getIds() async {
    final res = await _api.get('/wishlist/ids');
    return (res.data['ids'] as List? ?? []).cast<String>();
  }

  Future<List<ProductModel>> getWishlist() async {
    final res = await _api.get('/wishlist');
    return (res.data['wishlist'] as List? ?? [])
        .map((p) => ProductModel.fromJson(p))
        .toList();
  }

  /// Returns (added, updatedIds)
  Future<(bool, List<String>)> toggle(String productId) async {
    final res = await _api.post('/wishlist/toggle', data: {'productId': productId});
    final ids = (res.data['wishlistIds'] as List? ?? []).cast<String>();
    final added = res.data['added'] == true;
    return (added, ids);
  }

  Future<String> getShareLink() async {
    final res = await _api.get('/wishlist/share-link');
    return res.data['shareId'] ?? res.data['link'] ?? '';
  }

  Future<(String, List<ProductModel>)> getPublicWishlist(String shareId) async {
    final res = await _api.get('/wishlist/public/$shareId');
    final products = (res.data['wishlist'] as List? ?? [])
        .map((p) => ProductModel.fromJson(p))
        .toList();
    return (res.data['ownerName'] as String? ?? '', products);
  }
}
