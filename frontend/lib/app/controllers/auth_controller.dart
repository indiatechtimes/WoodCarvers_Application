import 'package:get/get.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

class AuthController extends GetxController {
  final _repo = AuthRepository();

  final Rxn<UserModel> user = Rxn<UserModel>();
  final RxBool loading = true.obs;

  bool get isLoggedIn => user.value != null;
  bool get isAdmin => user.value?.isAdmin ?? false;

  @override
  void onInit() {
    super.onInit();
    loadMe();
  }

  Future<void> loadMe() async {
    loading.value = true;
    try {
      user.value = await _repo.getMe();
    } finally {
      loading.value = false;
    }
  }

  Future<void> login(String email, String password) async {
    user.value = await _repo.login(email, password);
  }

  Future<void> register(String name, String email, String password) async {
    user.value = await _repo.register(name, email, password);
  }

  Future<void> logout() async {
    await _repo.logout();
    user.value = null;
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    user.value = await _repo.updateProfile(data);
  }
}
