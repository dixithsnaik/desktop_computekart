import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../controllers/register_controller.dart';
import '../../../shared/widgets/loading_indicator.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.emeraldLight, AppColors.emeraldSemi, AppColors.primary])),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 900, maxHeight: 560),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 30, offset: const Offset(0, 10))]),
            clipBehavior: Clip.antiAlias,
            child: Row(children: [
              Expanded(child: Container(color: Colors.white, padding: const EdgeInsets.all(40),
                child: Obx(() => Stack(children: [
                  if (controller.isLoading.value) Positioned.fill(child: Container(color: Colors.white70, child: const LoadingIndicator())),
                  Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('Register', style: AppTextStyles.h1(AppColors.greenDark)),
                    const SizedBox(height: 24),
                    _input('Email', false, (v) => controller.email.value = v),
                    const SizedBox(height: 12),
                    _input('Username', false, (v) => controller.username.value = v),
                    const SizedBox(height: 12),
                    _input('Password', true, (v) => controller.password.value = v),
                    const SizedBox(height: 12),
                    _input('Confirm Password', true, (v) => controller.confirmPassword.value = v),
                    const SizedBox(height: 18),
                    SizedBox(width: 320, height: 42, child: ElevatedButton(
                      onPressed: controller.isLoading.value ? null : controller.register,
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.emeraldBase, foregroundColor: Colors.white, shape: const StadiumBorder()),
                      child: const Text('Register', style: TextStyle(fontWeight: FontWeight.w600)))),
                    if (controller.error.value != null) Padding(padding: const EdgeInsets.only(top: 10), child: Text(controller.error.value!, style: AppTextStyles.bodySmall(AppColors.errorRed))),
                    const SizedBox(height: 16),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text('Already registered? ', style: AppTextStyles.bodySmall(AppColors.grayText)),
                      GestureDetector(onTap: () => Get.toNamed('/login'), child: Text('Login here', style: AppTextStyles.bodySemibold(AppColors.greenDark).copyWith(decoration: TextDecoration.underline))),
                    ]),
                  ]),
                ])))),
              Expanded(child: Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.emeraldMid, AppColors.emeraldSemi, AppColors.primary])),
                child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.cloud_outlined, size: 80, color: Colors.white.withValues(alpha: 0.8)),
                  const SizedBox(height: 16),
                  Text('ComputeKart', style: AppTextStyles.h2(Colors.white)),
                  const SizedBox(height: 8),
                  Text('Join the compute network', style: AppTextStyles.body(Colors.white70)),
                ])))),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _input(String hint, bool obscure, ValueChanged<String> onChanged) {
    return SizedBox(width: 320, child: TextField(onChanged: onChanged, obscureText: obscure, decoration: InputDecoration(hintText: hint, contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(30)), borderSide: BorderSide(color: AppColors.grayBorder)),
      enabledBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(30)), borderSide: BorderSide(color: AppColors.grayBorder)),
      focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(30)), borderSide: BorderSide(color: AppColors.greenFocus, width: 2)),
    )));
  }
}
