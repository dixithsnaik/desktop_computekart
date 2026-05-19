import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../controllers/login_controller.dart';
import '../../../shared/widgets/loading_indicator.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.emeraldLight, AppColors.emeraldSemi, AppColors.primary])),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 900, maxHeight: 520),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 30, offset: const Offset(0, 10))]),
            clipBehavior: Clip.antiAlias,
            child: Row(children: [
              // Left — Form
              Expanded(child: Container(color: Colors.white, padding: const EdgeInsets.all(40),
                child: Obx(() => Stack(children: [
                  if (controller.isLoading.value) Positioned.fill(child: Container(color: Colors.white70, child: const LoadingIndicator())),
                  Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('Login', style: AppTextStyles.h1(AppColors.greenDark)),
                    const SizedBox(height: 28),
                    _input('Username / email', false, (v) => controller.usernameOrEmail.value = v),
                    const SizedBox(height: 14),
                    _input('Password', true, (v) => controller.password.value = v),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: 320,
                      height: 42,
                      child: ElevatedButton(
                        onPressed: controller.isLoading.value ? null : controller.login,
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(AppColors.emeraldBase),
                          foregroundColor: MaterialStateProperty.all(Colors.white),
                          overlayColor: MaterialStateProperty.resolveWith((states) {
                            if (states.contains(MaterialState.pressed)) {
                              // Keep same background when pressed
                              return AppColors.emeraldBase.withOpacity(0.9);
                            }
                            return null;
                          }),
                          shape: MaterialStateProperty.all(const StadiumBorder()),
                        ),
                        child: const Text('Submit', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                    if (controller.error.value != null) Padding(padding: const EdgeInsets.only(top: 10), child: Text(controller.error.value!, style: AppTextStyles.bodySmall(AppColors.errorRed))),
                    const SizedBox(height: 20),
                    Text('Terms & Conditions', style: AppTextStyles.bodySemibold(AppColors.grayText)),
                    const SizedBox(height: 6),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text("Don't have an account? ", style: AppTextStyles.bodySmall(AppColors.grayText)),
                      GestureDetector(onTap: () => Get.toNamed('/register'), child: Text('Register', style: AppTextStyles.bodySemibold(AppColors.greenDark).copyWith(decoration: TextDecoration.underline))),
                    ]),
                  ]),
                ])))),
              // Right — Gradient
              Expanded(child: Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.emeraldMid, AppColors.emeraldSemi, AppColors.primary])),
                child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.cloud_outlined, size: 80, color: Colors.white.withValues(alpha: 0.8)),
                  const SizedBox(height: 16),
                  Text('ComputeKart', style: AppTextStyles.h2(Colors.white)),
                  const SizedBox(height: 8),
                  Text('Cloud computing reimagined', style: AppTextStyles.body(Colors.white70)),
                ])))),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _input(String hint, bool obscure, ValueChanged<String> onChanged) {
    return SizedBox(
      width: 320,
      child: TextField(
        onChanged: onChanged,
        obscureText: obscure,
        style: const TextStyle(color: Colors.black87),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.bodySmall(AppColors.grayText),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(30)),
            borderSide: BorderSide(color: AppColors.grayBorder),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(30)),
            borderSide: BorderSide(color: AppColors.grayBorder),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(30)),
            borderSide: BorderSide(color: AppColors.greenFocus, width: 2),
          ),
        ),
      ),
    );
  }
}
