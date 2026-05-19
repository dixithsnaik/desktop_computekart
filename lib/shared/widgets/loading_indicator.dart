import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class LoadingIndicator extends StatelessWidget {
  final double size;
  const LoadingIndicator({super.key, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(width: size, height: size,
        child: CircularProgressIndicator(strokeWidth: 3, valueColor: const AlwaysStoppedAnimation<Color>(AppColors.lime400), backgroundColor: AppColors.lime200.withValues(alpha: 0.3))),
    );
  }
}
