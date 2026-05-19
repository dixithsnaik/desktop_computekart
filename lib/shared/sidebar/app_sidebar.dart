import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_constants.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/wsl_execution_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// ─────────────────────────────────────────────────────────
/// Controller
/// ─────────────────────────────────────────────────────────
class SidebarController extends GetxController {
  final isCollapsed = false.obs;
  final currentRoute = ''.obs;

  @override
  void onInit() {
    super.onInit();
    currentRoute.value = Get.currentRoute;
  }

  void toggle() {
    isCollapsed.value = !isCollapsed.value;
  }

  void navigateTo(String route) {
    if (route.isEmpty) return;

    if (Get.currentRoute != route) {
      currentRoute.value = route;
      Get.offNamed(route);
    }
  }

  bool isActive(String route) {
    return route.isNotEmpty && currentRoute.value == route;
  }
}

/// ─────────────────────────────────────────────────────────
/// Sidebar
/// ─────────────────────────────────────────────────────────
class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.isRegistered<SidebarController>()
        ? Get.find<SidebarController>()
        : Get.put(SidebarController(), permanent: true);

    final auth = Get.find<AuthService>();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final palette = AppPalette(isDark: isDark);

    return Obx(() {
      final collapsed = ctrl.isCollapsed.value;

      final width = collapsed
          ? AppConstants.sidebarCollapsedWidth
          : AppConstants.sidebarExpandedWidth;

      return AnimatedContainer(
        duration: AppConstants.normalAnimation,
        curve: Curves.easeInOut,
        width: width,
        decoration: BoxDecoration(
          color: palette.bgNavbar,
          border: Border(
            right: BorderSide(
              color: palette.border,
              width: 1,
            ),
          ),
        ),
        child: Column(
          children: [
            /// HEADER
            _Header(
              ctrl: ctrl,
              collapsed: collapsed,
              palette: palette,
            ),

            const SizedBox(height: 8),

            /// NAVIGATION
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SidebarItem(
                      icon: Icons.analytics_outlined,
                      label: 'Analytics',
                      route: AppRoutes.dashboard,
                      collapsed: collapsed,
                      palette: palette,
                      ctrl: ctrl,
                    ),

                    _SectionLabel(
                      label: 'SERVICES',
                      collapsed: collapsed,
                      palette: palette,
                    ),

                    _SidebarItem(
                      icon: Icons.computer_outlined,
                      label: 'Virtual Machines',
                      route: AppRoutes.clientServices,
                      collapsed: collapsed,
                      palette: palette,
                      ctrl: ctrl,
                    ),

                    _SidebarItem(
                      icon: Icons.dns_outlined,
                      label: 'Providers',
                      route: AppRoutes.providers,
                      collapsed: collapsed,
                      palette: palette,
                      ctrl: ctrl,
                    ),

                    _SidebarItem(
                      icon: Icons.vpn_key_outlined,
                      label: 'Tunnels',
                      route: AppRoutes.tunnels,
                      collapsed: collapsed,
                      palette: palette,
                      ctrl: ctrl,
                    ),

                    _SectionLabel(
                      label: 'MANAGE',
                      collapsed: collapsed,
                      palette: palette,
                    ),

                    _SidebarItem(
                      icon: Icons.settings_outlined,
                      label: 'Manage Providers',
                      route: AppRoutes.manageProviders,
                      collapsed: collapsed,
                      palette: palette,
                      ctrl: ctrl,
                    ),

                    _SidebarItem(
                      icon: Icons.terminal_outlined,
                      label: 'Manage CLIs',
                      route: AppRoutes.manageClients,
                      collapsed: collapsed,
                      palette: palette,
                      ctrl: ctrl,
                    ),

                    // _SectionLabel(
                    //   label: 'STORAGE',
                    //   collapsed: collapsed,
                    //   palette: palette,
                    // ),

                    // _SidebarItem(
                    //   icon: Icons.folder_outlined,
                    //   label: 'Buckets',
                    //   route: AppRoutes.buckets,
                    //   collapsed: collapsed,
                    //   palette: palette,
                    //   ctrl: ctrl,
                    // ),
                  ],
                ),
              ),
            ),

            /// BOTTOM SECTION
            Divider(
              height: 1,
              color: palette.border,
            ),

            _SidebarItem(
              icon: Icons.task_alt_outlined,
              label: 'Background Tasks',
              route: '',
              collapsed: collapsed,
              palette: palette,
              ctrl: ctrl,
              onTap: () {
                final dm = Get.find<WslExecutionService>();
                dm.togglePanel();
              },
              trailing: Obx(() {
                final dm = Get.find<WslExecutionService>();
                final activeCount = dm.tasks.where((t) => t.status.value == WslTaskStatus.running).length;
                if (activeCount == 0 || collapsed) return const SizedBox();
                return Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.errorRed,
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),

            _SidebarItem(
              icon: isDark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
              label: isDark ? 'Light Mode' : 'Dark Mode',
              route: '',
              collapsed: collapsed,
              palette: palette,
              ctrl: ctrl,
              onTap: () {
                Get.changeThemeMode(
                  isDark ? ThemeMode.light : ThemeMode.dark,
                );
              },
            ),

            _SidebarItem(
              icon: Icons.person_outline,
              label: 'Profile',
              route: AppRoutes.profile,
              collapsed: collapsed,
              palette: palette,
              ctrl: ctrl,
            ),

            _LogoutButton(
              collapsed: collapsed,
              palette: palette,
              auth: auth,
            ),

            const SizedBox(height: 8),
          ],
        ),
      );
    });
  }
}

/// ─────────────────────────────────────────────────────────
/// Header
/// ─────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final SidebarController ctrl;
  final bool collapsed;
  final AppPalette palette;

  const _Header({
    required this.ctrl,
    required this.collapsed,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: palette.border,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          if (!collapsed) ...[
            Expanded(
              child: Text(
                'ComputeKart',
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.h4(
                  palette.brand0a,
                ),
              ),
            ),
          ],

          InkWell(
            onTap: ctrl.toggle,
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                collapsed
                    ? Icons.chevron_right
                    : Icons.chevron_left,
                size: 20,
                color: palette.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────
/// Sidebar Item
/// ─────────────────────────────────────────────────────────
class _SidebarItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final String route;
  final bool collapsed;
  final AppPalette palette;
  final SidebarController ctrl;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.collapsed,
    required this.palette,
    required this.ctrl,
    this.onTap,
    this.trailing,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    final isActive = widget.ctrl.isActive(widget.route);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: MouseRegion(
        onEnter: (_) {
          setState(() {
            hovered = true;
          });
        },
        onExit: (_) {
          setState(() {
            hovered = false;
          });
        },
        child: GestureDetector(
          onTap: widget.onTap ??
              () {
                widget.ctrl.navigateTo(widget.route);
              },
          child: AnimatedContainer(
            duration: AppConstants.fastAnimation,
            curve: Curves.easeInOut,
            padding: EdgeInsets.symmetric(
              horizontal: widget.collapsed ? 0 : 12,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.lime400.withValues(alpha: 0.15)
                  : hovered
                      ? widget.palette.bgSurfaceMuted
                          .withValues(alpha: 0.4)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isActive
                  ? const Border(
                      left: BorderSide(
                        color: AppColors.lime500,
                        width: 3,
                      ),
                    )
                  : null,
            ),
            child: widget.collapsed
                ? Tooltip(
                    message: widget.label,
                    child: SizedBox(
                      width: double.infinity,
                      child: Icon(
                        widget.icon,
                        size: 20,
                        color: isActive
                            ? AppColors.lime500
                            : hovered
                                ? widget.palette.textPrimary
                                : widget.palette.textMuted,
                      ),
                    ),
                  )
                : Row(
                    children: [
                      Icon(
                        widget.icon,
                        size: 18,
                        color: isActive
                            ? AppColors.lime500
                            : hovered
                                ? widget.palette.textPrimary
                                : widget.palette.textMuted,
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Text(
                          widget.label,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.sidebarItem(
                            isActive
                                ? AppColors.lime500
                                : hovered
                                    ? widget.palette.textPrimary
                                    : widget.palette.textSecondary,
                          ),
                        ),
                      ),
                      if (widget.trailing != null) widget.trailing!,
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────
/// Section Label
/// ─────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  final bool collapsed;
  final AppPalette palette;

  const _SectionLabel({
    required this.label,
    required this.collapsed,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    if (collapsed) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Divider(
          height: 1,
          color: palette.border,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(
        left: 12,
        top: 16,
        bottom: 6,
      ),
      child: Text(
        label,
        style: AppTextStyles.sidebarSection(
          palette.textMuted,
        ),
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────
/// Logout Button
/// ─────────────────────────────────────────────────────────
class _LogoutButton extends StatefulWidget {
  final bool collapsed;
  final AppPalette palette;
  final AuthService auth;

  const _LogoutButton({
    required this.collapsed,
    required this.palette,
    required this.auth,
  });

  @override
  State<_LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends State<_LogoutButton> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      child: MouseRegion(
        onEnter: (_) {
          setState(() {
            hovered = true;
          });
        },
        onExit: (_) {
          setState(() {
            hovered = false;
          });
        },
        child: GestureDetector(
          onTap: () {
            widget.auth.logout();
          },
          child: AnimatedContainer(
            duration: AppConstants.fastAnimation,
            curve: Curves.easeInOut,
            padding: EdgeInsets.symmetric(
              horizontal: widget.collapsed ? 0 : 12,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: hovered
                  ? AppColors.red500.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: widget.collapsed
                ? SizedBox(
                    width: double.infinity,
                    child: Icon(
                      Icons.logout,
                      size: 18,
                      color: AppColors.red500,
                    ),
                  )
                : Row(
                    children: [
                      Icon(
                        Icons.logout,
                        size: 18,
                        color: AppColors.red500,
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Text(
                          'Logout',
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.sidebarItem(
                            AppColors.red500,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}