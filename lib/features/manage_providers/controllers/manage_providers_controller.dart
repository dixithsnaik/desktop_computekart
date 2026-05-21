import 'package:get/get.dart';
import '../../../core/services/api_service.dart';
import '../../../core/constants/api_constants.dart';

class ManageProvidersController extends GetxController {
  final providers = <Map<String, dynamic>>[].obs;
  final selectedProvider = Rxn<Map<String, dynamic>>();
  final providerClients = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;
  final isLoadingClients = false.obs;

  @override void onInit() { super.onInit(); fetchProviders(); }

  Future<void> fetchProviders() async {
    isLoading.value = true;
    try { 
      final api = Get.find<ApiService>(); 
      final res = await api.call('GET', ApiConstants.userProviderDetails); 
      final list = res['all_providers'] as List? ?? [];
      providers.value = list.map((e) => Map<String, dynamic>.from(e)).toList(); 
    } catch (e) { 
      print('ManageProvidersController.fetchProviders Error: $e'); 
    }
    isLoading.value = false;
  }

  Future<void> selectProvider(Map<String, dynamic> p) async {
    selectedProvider.value = p;
    await fetchProviderClients(p['providerId']);
  }

  Future<void> fetchProviderClients(String providerId) async {
    isLoadingClients.value = true;
    try { final api = Get.find<ApiService>(); final res = await api.call('GET', ApiConstants.providerClientDetails, queryParameters: {'providerId': providerId}); providerClients.value = List<Map<String, dynamic>>.from(res['providerClientDetails'] ?? []); } catch (_) {}
    isLoadingClients.value = false;
  }

  Future<String?> addProvider() async {
    try {
      final api = Get.find<ApiService>();
      final res = await api.call('POST', ApiConstants.getProviderVerificationToken, data: {
        'user_id': '',
        'providerId': ''
      });
      final token = res['cli_verification_token'] ?? res['token'];
      if (token != null) {
        return 'curl -sL ${ApiConstants.installMegaUrl} | sudo INSTALL_TOKEN=$token bash';
      }
      return res['command'];
    } catch (e) {
      return null;
    }
  }

  Future<String?> updateConfig(String providerId, Map<String, dynamic> config) async {
    try { final api = Get.find<ApiService>(); await api.call('PUT', ApiConstants.updateProviderConfig, data: {'providerId': providerId, ...config}); await fetchProviders(); return 'Config updated'; } catch (e) { return 'Error: $e'; }
  }
}
