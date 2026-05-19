import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/services/api_service.dart';
import 'core/services/monitoring_api_service.dart';
import 'core/services/auth_service.dart';
import 'core/services/download_manager_service.dart';
import 'core/services/wsl_execution_service.dart';
import 'core/routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ─── Environment Variables ─────────────────────────────────────
  await dotenv.load(fileName: ".env");

  // ─── Local Storage ────────────────────────────────────────────
  await GetStorage.init();

  // ─── Window Manager (desktop only, skip on web) ───────────────
  if (!kIsWeb) {
    try {
      await windowManager.ensureInitialized();

      const windowOptions = WindowOptions(
        size: Size(AppConstants.defaultWindowWidth, AppConstants.defaultWindowHeight),
        minimumSize: Size(AppConstants.minWindowWidth, AppConstants.minWindowHeight),
        center: true,
        backgroundColor: Colors.transparent,
        titleBarStyle: TitleBarStyle.normal,
        title: AppConstants.appName,
      );

      await windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
      });
    } catch (_) {
      // Silently ignore on unsupported platforms
    }
  }

  // ─── Global Services (permanent) ─────────────────────────────
  Get.put(AuthService(), permanent: true);
  Get.put(ApiService(), permanent: true);
  Get.put(MonitoringApiService(), permanent: true);
  Get.put(DownloadManagerService(), permanent: true);
  Get.put(WslExecutionService(), permanent: true);

  runApp(const ComputeKartApp());
}

class ComputeKartApp extends StatelessWidget {
  const ComputeKartApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthService>();

    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

      // ─── Themes ──────────────────────────────────────────────
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,

      // ─── Routing ─────────────────────────────────────────────
      initialRoute: auth.isLoggedIn ? AppRoutes.dashboard : AppRoutes.login,
      getPages: AppRoutes.pages,

      // ─── Default Transition ──────────────────────────────────
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 200),
    );
  }
}
