import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../../app/controllers/auth_controller.dart';
import '../../../app/routes/app_routes.dart';

class AuthPageController extends GetxController {
  final RxBool isRegisterMode = false.obs;
  final RxBool loading = false.obs;

  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  final formKey = GlobalKey<FormState>();

  void toggleMode() {
    isRegisterMode.value = !isRegisterMode.value;
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;

    loading.value = true;
    try {
      final auth = Get.find<AuthController>();
      if (isRegisterMode.value) {
        await auth.register(nameCtrl.text.trim(), emailCtrl.text.trim(), passwordCtrl.text);
        Get.snackbar('Welcome to WOOD CARVERS', '', snackPosition: SnackPosition.BOTTOM);
      } else {
        await auth.login(emailCtrl.text.trim(), passwordCtrl.text);
        Get.snackbar('Welcome back', '', snackPosition: SnackPosition.BOTTOM);
      }
      final next = Get.parameters['next'];
      Get.offAllNamed(next ?? Routes.home);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Something went wrong';
      Get.snackbar('Error', message, snackPosition: SnackPosition.BOTTOM);
    } finally {
      loading.value = false;
    }
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.onClose();
  }
}
