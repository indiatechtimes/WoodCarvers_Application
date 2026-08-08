import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_theme.dart';
import '../controllers/auth_page_controller.dart';

class AuthView extends GetView<AuthPageController> {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Obx(() => Form(
                    key: controller.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'WOOD CARVERS',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                letterSpacing: 3,
                                color: AppColors.mutedForeground,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          controller.isRegisterMode.value ? 'Create your account' : 'Welcome back',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          controller.isRegisterMode.value
                              ? 'Save wishlists, track orders and get 10% off your first heirloom.'
                              : 'Sign in to continue with WOOD CARVERS.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.mutedForeground, fontSize: 14),
                        ),
                        const SizedBox(height: 32),
                        if (controller.isRegisterMode.value) ...[
                          TextFormField(
                            controller: controller.nameCtrl,
                            decoration: const InputDecoration(hintText: 'Full name'),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                          ),
                          const SizedBox(height: 12),
                        ],
                        TextFormField(
                          controller: controller.emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(hintText: 'Email address'),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Email is required';
                            if (!v.contains('@')) return 'Enter a valid email';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: controller.passwordCtrl,
                          obscureText: true,
                          decoration: const InputDecoration(hintText: 'Password'),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Password is required';
                            if (v.length < 6) return 'Minimum 6 characters';
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: controller.loading.value ? null : controller.submit,
                          child: Text(
                            controller.loading.value
                                ? 'Please wait…'
                                : controller.isRegisterMode.value
                                    ? 'Create account'
                                    : 'Sign in',
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: TextButton(
                            onPressed: controller.toggleMode,
                            child: Text.rich(
                              TextSpan(
                                text: controller.isRegisterMode.value
                                    ? 'Already have an account? '
                                    : "Don't have an account? ",
                                style: const TextStyle(color: AppColors.mutedForeground, fontSize: 14),
                                children: [
                                  TextSpan(
                                    text: controller.isRegisterMode.value ? 'Sign in' : 'Create one',
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ),
          ),
        ),
      ),
    );
  }
}
