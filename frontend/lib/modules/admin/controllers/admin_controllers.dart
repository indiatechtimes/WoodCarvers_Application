import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/models/order_model.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/analytics_repository.dart';
import '../../../data/repositories/coupon_repository.dart';
import '../../../data/repositories/media_repository.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../data/repositories/settings_repository.dart';

class AdminController extends GetxController {
  final RxString activeTab = 'dashboard'.obs;
  void setTab(String tab) => activeTab.value = tab;
}

// ---------------- Dashboard ----------------

class AdminDashboardController extends GetxController {
  final _repo = AnalyticsRepository();
  final Rxn<DashboardStats> stats = Rxn<DashboardStats>();
  final RxBool loading = true.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    try {
      stats.value = await _repo.getDashboardStats();
    } catch (_) {
      // keep null
    } finally {
      loading.value = false;
    }
  }
}

// ---------------- Products ----------------

const kAdminCategories = ['wall-decor', 'home-decor', 'kitchen', 'office', 'gifts', 'personalized'];

class AdminProductsController extends GetxController {
  final _repo = ProductRepository();
  final _mediaRepo = MediaRepository();

  final RxList<ProductModel> products = <ProductModel>[].obs;
  final RxBool loading = true.obs;

  // Editor state
  final RxBool editorOpen = false.obs;
  final Rxn<String> editingId = Rxn<String>();
  final nameCtrl = TextEditingController();
  final skuCtrl = TextEditingController();
  final brandCtrl = TextEditingController(text: 'WOOD CARVERS');
  final priceCtrl = TextEditingController();
  final compareAtPriceCtrl = TextEditingController();
  final RxString category = kAdminCategories.first.obs;
  final stockCtrl = TextEditingController();
  final colorCtrl = TextEditingController();
  final dimensionsCtrl = TextEditingController();
  final weightCtrl = TextEditingController();
  final tagsCtrl = TextEditingController();
  final materialsCtrl = TextEditingController();
  final shortDescriptionCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();
  final seoTitleCtrl = TextEditingController();
  final seoDescriptionCtrl = TextEditingController();
  final RxBool featured = false.obs;
  final RxBool bestSeller = false.obs;
  final RxBool newArrival = false.obs;
  final RxBool published = true.obs;
  final RxList<ProductMedia> media = <ProductMedia>[].obs;
  final RxBool uploading = false.obs;
  final RxBool saving = false.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    try {
      final result = await _repo.listProducts(params: {'limit': 100, 'sort': '-createdAt'});
      products.value = result.products;
    } catch (_) {
      // keep empty
    } finally {
      loading.value = false;
    }
  }

  void openNew() {
    editingId.value = null;
    nameCtrl.clear();
    skuCtrl.clear();
    brandCtrl.text = 'WOOD CARVERS';
    priceCtrl.text = '0';
    compareAtPriceCtrl.text = '0';
    category.value = kAdminCategories.first;
    stockCtrl.text = '0';
    colorCtrl.clear();
    dimensionsCtrl.clear();
    weightCtrl.clear();
    tagsCtrl.clear();
    materialsCtrl.clear();
    shortDescriptionCtrl.clear();
    descriptionCtrl.clear();
    seoTitleCtrl.clear();
    seoDescriptionCtrl.clear();
    featured.value = false;
    bestSeller.value = false;
    newArrival.value = false;
    published.value = true;
    media.clear();
    editorOpen.value = true;
  }

  void openEdit(ProductModel p) {
    editingId.value = p.id;
    nameCtrl.text = p.name;
    skuCtrl.text = p.sku;
    brandCtrl.text = p.brand;
    priceCtrl.text = p.price.toString();
    compareAtPriceCtrl.text = p.compareAtPrice.toString();
    category.value = kAdminCategories.contains(p.category) ? p.category : kAdminCategories.first;
    stockCtrl.text = p.stock.toString();
    colorCtrl.text = p.color;
    dimensionsCtrl.text = p.dimensions;
    weightCtrl.text = p.weight;
    tagsCtrl.text = p.tags.join(', ');
    materialsCtrl.text = p.materials.join(', ');
    shortDescriptionCtrl.text = p.shortDescription;
    descriptionCtrl.text = p.description;
    seoTitleCtrl.clear();
    seoDescriptionCtrl.clear();
    featured.value = p.featured;
    bestSeller.value = p.bestSeller;
    newArrival.value = p.newArrival;
    published.value = p.active;
    media.value = List.of(p.media);
    editorOpen.value = true;
  }

  void closeEditor() => editorOpen.value = false;

  Future<void> uploadMedia() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;
    uploading.value = true;
    try {
      final m = await _mediaRepo.upload(File(picked.path));
      media.add(m);
    } catch (_) {
      Get.snackbar('Error', 'Upload failed', snackPosition: SnackPosition.BOTTOM);
    } finally {
      uploading.value = false;
    }
  }

  void removeMedia(int index) => media.removeAt(index);

  void moveMedia(int from, int to) {
    if (to < 0 || to >= media.length) return;
    final item = media.removeAt(from);
    media.insert(to, item);
  }

  Future<void> save() async {
    if (nameCtrl.text.trim().isEmpty || descriptionCtrl.text.trim().isEmpty) {
      Get.snackbar('Missing fields', 'Name and description are required', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    saving.value = true;
    final payload = {
      'name': nameCtrl.text.trim(),
      'sku': skuCtrl.text.trim(),
      'brand': brandCtrl.text.trim().isEmpty ? 'WOOD CARVERS' : brandCtrl.text.trim(),
      'price': double.tryParse(priceCtrl.text) ?? 0,
      'compareAtPrice': double.tryParse(compareAtPriceCtrl.text) ?? 0,
      'category': category.value,
      'stock': int.tryParse(stockCtrl.text) ?? 0,
      'color': colorCtrl.text.trim(),
      'dimensions': dimensionsCtrl.text.trim(),
      'weight': weightCtrl.text.trim(),
      'tags': tagsCtrl.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
      'materials': materialsCtrl.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
      'shortDescription': shortDescriptionCtrl.text.trim(),
      'description': descriptionCtrl.text.trim(),
      'seoTitle': seoTitleCtrl.text.trim(),
      'seoDescription': seoDescriptionCtrl.text.trim(),
      'featured': featured.value,
      'bestSeller': bestSeller.value,
      'newArrival': newArrival.value,
      'published': published.value,
      'media': media.map((m) => {'url': m.url, 'publicId': m.publicId, 'type': m.type}).toList(),
    };
    try {
      if (editingId.value != null) {
        await _repo.updateProduct(editingId.value!, payload);
      } else {
        await _repo.createProduct(payload);
      }
      Get.snackbar('Saved', '', snackPosition: SnackPosition.BOTTOM);
      editorOpen.value = false;
      await load();
    } catch (e) {
      Get.snackbar('Error', 'Failed to save product', snackPosition: SnackPosition.BOTTOM);
    } finally {
      saving.value = false;
    }
  }

  Future<void> delete(String id) async {
    try {
      await _repo.deleteProduct(id);
      Get.snackbar('Deleted', '', snackPosition: SnackPosition.BOTTOM);
      await load();
    } catch (_) {
      Get.snackbar('Error', 'Failed to delete product', snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    skuCtrl.dispose();
    brandCtrl.dispose();
    priceCtrl.dispose();
    compareAtPriceCtrl.dispose();
    stockCtrl.dispose();
    colorCtrl.dispose();
    dimensionsCtrl.dispose();
    weightCtrl.dispose();
    tagsCtrl.dispose();
    materialsCtrl.dispose();
    shortDescriptionCtrl.dispose();
    descriptionCtrl.dispose();
    seoTitleCtrl.dispose();
    seoDescriptionCtrl.dispose();
    super.onClose();
  }
}

// ---------------- Orders ----------------

const kOrderStatuses = ['pending', 'paid', 'processing', 'shipped', 'delivered', 'cancelled', 'failed'];

class AdminOrdersController extends GetxController {
  final _repo = OrderRepository();

  final RxList<OrderModel> orders = <OrderModel>[].obs;
  final RxBool loading = true.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    try {
      orders.value = await _repo.listAllOrders();
    } catch (_) {
      // keep empty
    } finally {
      loading.value = false;
    }
  }

  Future<void> setStatus(String id, String status) async {
    try {
      await _repo.updateOrderStatus(id, status);
      Get.snackbar('Updated', '', snackPosition: SnackPosition.BOTTOM);
      await load();
    } catch (_) {
      Get.snackbar('Error', 'Could not update status', snackPosition: SnackPosition.BOTTOM);
    }
  }
}

// ---------------- Coupons ----------------

class AdminCouponsController extends GetxController {
  final _repo = CouponRepository();

  final RxList<Map<String, dynamic>> coupons = <Map<String, dynamic>>[].obs;
  final RxBool loading = true.obs;

  final RxBool editorOpen = false.obs;
  final Rxn<String> editingId = Rxn<String>();
  final codeCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();
  final RxString type = 'percent'.obs;
  final valueCtrl = TextEditingController(text: '10');
  final minSubtotalCtrl = TextEditingController(text: '0');
  final maxDiscountCtrl = TextEditingController(text: '0');
  final RxBool active = true.obs;
  final RxBool saving = false.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    try {
      coupons.value = await _repo.listCoupons();
    } catch (_) {
      // keep empty
    } finally {
      loading.value = false;
    }
  }

  void openNew() {
    editingId.value = null;
    codeCtrl.clear();
    descriptionCtrl.clear();
    type.value = 'percent';
    valueCtrl.text = '10';
    minSubtotalCtrl.text = '0';
    maxDiscountCtrl.text = '0';
    active.value = true;
    editorOpen.value = true;
  }

  void openEdit(Map<String, dynamic> c) {
    editingId.value = c['_id'];
    codeCtrl.text = c['code'] ?? '';
    descriptionCtrl.text = c['description'] ?? '';
    type.value = c['type'] ?? 'percent';
    valueCtrl.text = '${c['value'] ?? 0}';
    minSubtotalCtrl.text = '${c['minSubtotal'] ?? 0}';
    maxDiscountCtrl.text = '${c['maxDiscount'] ?? 0}';
    active.value = c['active'] ?? true;
    editorOpen.value = true;
  }

  void closeEditor() => editorOpen.value = false;

  Future<void> save() async {
    if (codeCtrl.text.trim().isEmpty) {
      Get.snackbar('Missing code', 'Enter a coupon code', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    saving.value = true;
    final payload = {
      'code': codeCtrl.text.trim().toUpperCase(),
      'description': descriptionCtrl.text.trim(),
      'type': type.value,
      'value': double.tryParse(valueCtrl.text) ?? 0,
      'minSubtotal': double.tryParse(minSubtotalCtrl.text) ?? 0,
      'maxDiscount': double.tryParse(maxDiscountCtrl.text) ?? 0,
      'active': active.value,
    };
    try {
      if (editingId.value != null) {
        await _repo.updateCoupon(editingId.value!, payload);
      } else {
        await _repo.createCoupon(payload);
      }
      Get.snackbar('Saved', '', snackPosition: SnackPosition.BOTTOM);
      editorOpen.value = false;
      await load();
    } catch (e) {
      Get.snackbar('Error', 'Failed to save coupon', snackPosition: SnackPosition.BOTTOM);
    } finally {
      saving.value = false;
    }
  }

  Future<void> delete(String id) async {
    try {
      await _repo.deleteCoupon(id);
      Get.snackbar('Deleted', '', snackPosition: SnackPosition.BOTTOM);
      await load();
    } catch (_) {
      Get.snackbar('Error', 'Failed to delete coupon', snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  void onClose() {
    codeCtrl.dispose();
    descriptionCtrl.dispose();
    valueCtrl.dispose();
    minSubtotalCtrl.dispose();
    maxDiscountCtrl.dispose();
    super.onClose();
  }
}

// ---------------- Banners / Settings ----------------

class AdminBannersController extends GetxController {
  final _repo = SettingsRepository();
  final _mediaRepo = MediaRepository();

  final RxMap<String, dynamic> settings = <String, dynamic>{}.obs;
  final RxBool loading = true.obs;
  final RxBool saving = false.obs;

  final headlineCtrl = TextEditingController();
  final subheadingCtrl = TextEditingController();
  final promoTextCtrl = TextEditingController();
  final RxBool promoActive = false.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    try {
      settings.value = await _repo.getSettings();
      headlineCtrl.text = settings['hero_headline'] ?? '';
      subheadingCtrl.text = settings['hero_subheading'] ?? '';
      final banner = settings['promo_banner'];
      if (banner is Map) {
        promoTextCtrl.text = banner['text'] ?? '';
        promoActive.value = banner['active'] == true;
      }
    } catch (_) {
      // keep empty
    } finally {
      loading.value = false;
    }
  }

  Future<void> saveHeadline() async {
    saving.value = true;
    try {
      await _repo.updateSetting('hero_headline', headlineCtrl.text.trim());
      settings['hero_headline'] = headlineCtrl.text.trim();
      Get.snackbar('Saved', '', snackPosition: SnackPosition.BOTTOM);
    } catch (_) {
      Get.snackbar('Error', 'Failed', snackPosition: SnackPosition.BOTTOM);
    } finally {
      saving.value = false;
    }
  }

  Future<void> saveSubheading() async {
    saving.value = true;
    try {
      await _repo.updateSetting('hero_subheading', subheadingCtrl.text.trim());
      settings['hero_subheading'] = subheadingCtrl.text.trim();
      Get.snackbar('Saved', '', snackPosition: SnackPosition.BOTTOM);
    } catch (_) {
      Get.snackbar('Error', 'Failed', snackPosition: SnackPosition.BOTTOM);
    } finally {
      saving.value = false;
    }
  }

  Future<void> savePromo() async {
    saving.value = true;
    try {
      final value = {'text': promoTextCtrl.text.trim(), 'active': promoActive.value};
      await _repo.updateSetting('promo_banner', value);
      settings['promo_banner'] = value;
      Get.snackbar('Saved', '', snackPosition: SnackPosition.BOTTOM);
    } catch (_) {
      Get.snackbar('Error', 'Failed', snackPosition: SnackPosition.BOTTOM);
    } finally {
      saving.value = false;
    }
  }

  Future<void> uploadHero() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;
    try {
      final m = await _mediaRepo.upload(File(picked.path));
      settings['hero_image'] = m.url;
      await _repo.updateSetting('hero_image', m.url);
      Get.snackbar('Hero updated', '', snackPosition: SnackPosition.BOTTOM);
    } catch (_) {
      Get.snackbar('Error', 'Upload failed', snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  void onClose() {
    headlineCtrl.dispose();
    subheadingCtrl.dispose();
    promoTextCtrl.dispose();
    super.onClose();
  }
}
