/// Application-wide constants.
class AppConstants {
  AppConstants._();

  static const String appName = 'ComputeKart';
  static const String appVersion = '1.0.0';

  // Minimum desktop window dimensions
  static const double minWindowWidth = 1024;
  static const double minWindowHeight = 600;

  // Default window dimensions
  static const double defaultWindowWidth = 1280;
  static const double defaultWindowHeight = 720;

  // Sidebar dimensions
  static const double sidebarExpandedWidth = 220;
  static const double sidebarCollapsedWidth = 64;

  // Desktop breakpoints
  static const double compactBreakpoint = 1024;
  static const double mediumBreakpoint = 1440;
  static const double expandedBreakpoint = 1920;

  // Animation durations
  static const Duration fastAnimation = Duration(milliseconds: 150);
  static const Duration normalAnimation = Duration(milliseconds: 250);
  static const Duration slowAnimation = Duration(milliseconds: 400);

  // Debounce
  static const Duration searchDebounce = Duration(milliseconds: 500);

  // Toast
  static const Duration toastDuration = Duration(seconds: 3);
}
