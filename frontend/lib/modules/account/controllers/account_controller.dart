import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/controllers/auth_controller.dart';
import '../../../data/models/order_model.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../data/repositories/wishlist_repository.dart';

class AccountController extends GetxController {
  final _authRepo = AuthRepository();
  final _orderRepo = OrderRepository();
  final _wishlistRepo = WishlistRepository();

  final RxString activeTab = 'orders'.obs;

  // Orders tab
  final RxList<OrderModel> orders = <OrderModel>[].obs;
  final RxBool ordersLoading = true.obs;

  // Wishlist tab
  final RxList<ProductModel> wishlistProducts = <ProductModel>[].obs;
  final RxBool wishlistLoading = true.obs;

  // Addresses tab
  final RxList<AddressModel> addresses = <AddressModel>[].obs;
  final RxBool addressesLoading = true.obs;
  final Rxn<AddressModel> editingAddress = Rxn<AddressModel>();
  final RxBool isNewAddress = false.obs;

  // Address editor form controllers
  final labelCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final line1Ctrl = TextEditingController();
  final line2Ctrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final stateCtrl = TextEditingController();
  final pincodeCtrl = TextEditingController();
  final countryCtrl = TextEditingController();
  final RxBool formIsDefault = false.obs;
  final RxBool savingAddress = false.obs;

  // Profile tab
  final profileNameCtrl = TextEditingController();
  final profilePhoneCtrl = TextEditingController();
  final RxBool savingProfile = false.obs;

  @override
  void onInit() {
    super.onInit();
    final auth = Get.find<AuthController>();
    profileNameCtrl.text = auth.user.value?.name ?? '';
    profilePhoneCtrl.text = auth.user.value?.phone ?? '';
    loadOrders();
  }

  void setTab(String tab) {
    activeTab.value = tab;
    if (tab == 'wishlist' && wishlistProducts.isEmpty) loadWishlist();
    if (tab == 'addresses' && addresses.isEmpty) loadAddresses();
  }

  Future<void> loadOrders() async {
    ordersLoading.value = true;
    try {
      orders.value = await _orderRepo.listMyOrders();
    } catch (_) {
      // keep empty
    } finally {
      ordersLoading.value = false;
    }
  }

  Future<void> loadWishlist() async {
    wishlistLoading.value = true;
    try {
      wishlistProducts.value = await _wishlistRepo.getWishlist();
    } catch (_) {
      // keep empty
    } finally {
      wishlistLoading.value = false;
    }
  }

  Future<void> loadAddresses() async {
    addressesLoading.value = true;
    try {
      addresses.value = await _authRepo.listAddresses();
    } catch (_) {
      // keep empty
    } finally {
      addressesLoading.value = false;
    }
  }

  void openNewAddressForm() {
    isNewAddress.value = true;
    editingAddress.value = null;
    labelCtrl.text = 'Home';
    nameCtrl.clear();
    phoneCtrl.clear();
    line1Ctrl.clear();
    line2Ctrl.clear();
    cityCtrl.clear();
    stateCtrl.clear();
    pincodeCtrl.clear();
    countryCtrl.text = 'India';
    formIsDefault.value = addresses.isEmpty;
  }

  void openEditAddressForm(AddressModel a) {
    isNewAddress.value = false;
    editingAddress.value = a;
    labelCtrl.text = a.label;
    nameCtrl.text = a.name;
    phoneCtrl.text = a.phone;
    line1Ctrl.text = a.line1;
    line2Ctrl.text = a.line2;
    cityCtrl.text = a.city;
    stateCtrl.text = a.state;
    pincodeCtrl.text = a.pincode;
    countryCtrl.text = a.country;
    formIsDefault.value = a.isDefault;
  }

  void closeAddressForm() {
    editingAddress.value = null;
    isNewAddress.value = false;
  }

  bool get isAddressFormOpen => isNewAddress.value || editingAddress.value != null;

  Future<void> saveAddress() async {
    savingAddress.value = true;
    final address = AddressModel(
      id: editingAddress.value?.id,
      label: labelCtrl.text.trim().isEmpty ? 'Home' : labelCtrl.text.trim(),
      name: nameCtrl.text.trim(),
      phone: phoneCtrl.text.trim(),
      line1: line1Ctrl.text.trim(),
      line2: line2Ctrl.text.trim(),
      city: cityCtrl.text.trim(),
      state: stateCtrl.text.trim(),
      pincode: pincodeCtrl.text.trim(),
      country: countryCtrl.text.trim().isEmpty ? 'India' : countryCtrl.text.trim(),
      isDefault: formIsDefault.value,
    );
    try {
      if (address.id != null) {
        addresses.value = await _authRepo.updateAddress(address.id!, address);
      } else {
        addresses.value = await _authRepo.addAddress(address);
      }
      Get.snackbar('Saved', '', snackPosition: SnackPosition.BOTTOM);
      closeAddressForm();
    } catch (e) {
      Get.snackbar('Error', 'Failed to save address', snackPosition: SnackPosition.BOTTOM);
    } finally {
      savingAddress.value = false;
    }
  }

  Future<void> deleteAddress(String id) async {
    try {
      addresses.value = await _authRepo.deleteAddress(id);
      Get.snackbar('Deleted', '', snackPosition: SnackPosition.BOTTOM);
    } catch (_) {
      Get.snackbar('Error', 'Failed to delete address', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> saveProfile() async {
    savingProfile.value = true;
    try {
      final auth = Get.find<AuthController>();
      await auth.updateProfile({
        'name': profileNameCtrl.text.trim(),
        'phone': profilePhoneCtrl.text.trim(),
      });
      Get.snackbar('Profile updated', '', snackPosition: SnackPosition.BOTTOM);
    } catch (_) {
      Get.snackbar('Error', 'Could not update profile', snackPosition: SnackPosition.BOTTOM);
    } finally {
      savingProfile.value = false;
    }
  }

  @override
  void onClose() {
    labelCtrl.dispose();
    nameCtrl.dispose();
    phoneCtrl.dispose();
    line1Ctrl.dispose();
    line2Ctrl.dispose();
    cityCtrl.dispose();
    stateCtrl.dispose();
    pincodeCtrl.dispose();
    countryCtrl.dispose();
    profileNameCtrl.dispose();
    profilePhoneCtrl.dispose();
    super.onClose();
  }
}
