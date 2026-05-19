import 'package:get/get.dart';
import '../../features/auth/bindings/auth_binding.dart';
import '../../features/auth/views/login_view.dart';
import '../../features/auth/views/register_view.dart';
import '../../features/profile/bindings/profile_binding.dart';
import '../../features/profile/views/profile_view.dart';
import '../../features/providers/bindings/providers_binding.dart';
import '../../features/providers/views/providers_view.dart';
import '../../features/client_services/bindings/client_services_binding.dart';
import '../../features/client_services/views/client_services_view.dart';
import '../../features/dashboard/bindings/dashboard_binding.dart';
import '../../features/dashboard/views/dashboard_list_view.dart';
import '../../features/dashboard/views/dashboard_detail_view.dart';
import '../../features/manage_providers/bindings/manage_providers_binding.dart';
import '../../features/manage_providers/views/manage_providers_view.dart';
import '../../features/manage_clients/bindings/manage_clients_binding.dart';
import '../../features/manage_clients/views/manage_clients_view.dart';
import '../../features/tunnels/bindings/tunnels_binding.dart';
import '../../features/tunnels/views/tunnels_view.dart';
import '../../features/buckets/bindings/buckets_binding.dart';
import '../../features/buckets/views/buckets_view.dart';

class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String register = '/register';
  static const String profile = '/profile';
  static const String providers = '/providers';
  static const String clientServices = '/client-services';
  static const String dashboard = '/dashboard';
  static const String dashboardView = '/dashboard/view';
  static const String manageProviders = '/manage/providers';
  static const String manageClients = '/manage/clients';
  static const String tunnels = '/tunnels';
  static const String buckets = '/buckets';

  static final List<GetPage> pages = [
    GetPage(
      name: login,
      page: () => const LoginView(),
      binding: AuthBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 200),
    ),
    GetPage(
      name: register,
      page: () => const RegisterView(),
      binding: AuthBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 200),
    ),
    GetPage(
      name: profile,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: providers,
      page: () => const ProvidersView(),
      binding: ProvidersBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: clientServices,
      page: () => const ClientServicesView(),
      binding: ClientServicesBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: dashboard,
      page: () => const DashboardListView(),
      binding: DashboardBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: dashboardView,
      page: () => const DashboardDetailView(),
      binding: DashboardBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: manageProviders,
      page: () => const ManageProvidersView(),
      binding: ManageProvidersBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: manageClients,
      page: () => const ManageClientsView(),
      binding: ManageClientsBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: tunnels,
      page: () => const TunnelsView(),
      binding: TunnelsBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: buckets,
      page: () => const BucketsView(),
      binding: BucketsBinding(),
      transition: Transition.fadeIn,
    ),
  ];
}
