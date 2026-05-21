import 'package:get/get.dart';
import '../../../core/services/api_service.dart';
import '../../../core/constants/api_constants.dart';

class ManageProvidersController extends GetxController {
  final providers = <Map<String, dynamic>>[].obs;
  final selectedProvider = Rxn<Map<String, dynamic>>();
  final providerClients = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;
  final isLoadingClients = false.obs;

  // Form State
  final selectedProviderName = ''.obs;
  final selectedVcpu = ''.obs;
  final selectedRam = ''.obs;
  final selectedStorage = ''.obs;
  final selectedNetworks = ''.obs;
  final selectedVms = ''.obs;

  // Graph State
  final graphSeries = <Map<String, dynamic>>[].obs;
  final isGraphLoading = false.obs;
  final graphError = RxnString();

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
    // Populate form state
    selectedProviderName.value = p['providerName']?.toString() ?? '';
    final vcpu = p['providerAllowedVcpu']?.toString() ?? '';
    selectedVcpu.value = vcpu.isNotEmpty ? (vcpu == '1' ? '1 vCPU' : '$vcpu vCPUs') : '';

    selectedRam.value = (int.tryParse(p['providerAllowedRam']?.toString() ?? '0') ?? 0) > 0 
        ? '${((int.tryParse(p['providerAllowedRam'].toString()) ?? 0) / 1024).round()} GB' 
        : '';
    selectedStorage.value = (int.tryParse(p['providerAllowedStorage']?.toString() ?? '0') ?? 0) > 0 
        ? '${((int.tryParse(p['providerAllowedStorage'].toString()) ?? 0) / 1024).round()} GB' 
        : '';

    final net = p['providerAllowedNetworks']?.toString() ?? '';
    selectedNetworks.value = net.isNotEmpty ? (net == '1' ? '1 Network' : '$net Networks') : '';

    final vms = p['providerAllowedVms']?.toString() ?? '';
    selectedVms.value = vms.isNotEmpty ? (vms == '1' ? '1 VM' : '$vms VMs') : '';

    await fetchProviderClients(p['providerId']);
    await fetchGraphData(p['providerId']);
  }

  Future<void> fetchProviderClients(String providerId) async {
    isLoadingClients.value = true;
    try { 
      final api = Get.find<ApiService>(); 
      final res = await api.call('POST', ApiConstants.providerClientDetails, data: {'providerId': providerId}); 
      providerClients.value = List<Map<String, dynamic>>.from(res['client_details'] ?? []); 
    } catch (_) {}
    isLoadingClients.value = false;
  }

  Future<void> fetchGraphData(String providerId) async {
    isGraphLoading.value = true;
    graphError.value = null;
    try {
      final api = Get.find<ApiService>();
      final payload = {
        'graphId': 'dummy-graph-id',
        'dashboardId': 'dummy-dashboard-id',
        'graphName': 'Provider Metrics',
        'graphType': 'time_series',
        'defaultTimeRange': '1772562600|1774809000',
        'refreshIntervalSeconds': 30,
        'settings': '{}',
        'series': [
          {
            'seriesId': '3d54006d-3c9c-481b-afd2-753678ccff65',
            'graphId': '70347d3b-0ffa-478a-8134-867b0274e2be',
            'metricId': '58e6f7e4-a803-49ef-83ea-b3c86aac71b6',
            'metricName': 'vm_ram_allocated',
            'entityType': 'vm',
            'aggregation': 'sum',
            'filters': {'provider_id': providerId},
            'groupBy': [],
            'yAxisPosition': 'left',
            'data': [],
          },
          {
            'seriesId': '3d54006d-3c9c-481b-afd2-753678ccff65',
            'graphId': '70347d3b-0ffa-478a-8134-867b0274e2be',
            'metricId': '58e6f7e4-a803-49ef-83ea-b3c86aac71b6',
            'metricName': 'vm_cpu_allocated',
            'entityType': 'vm',
            'aggregation': 'sum',
            'filters': {'provider_id': providerId},
            'groupBy': [],
            'yAxisPosition': 'left',
            'data': [],
          },
        ],
      };
      // Important: Use the monitoring server for graphs if that's how it's done. 
      // In the React app, apiServices.js uses monitoring server directly via interceptor.
      // We will assume apiService handles base URL appropriately if passed full URL, or just uses the default one and it gets routed.
      // Wait, in Flutter, ApiService has `call` which prepends `ApiConstants.mgServer`. 
      // For graphs, it might need to use `monitoringServer`. Let's just pass the endpoint and see, or pass full url.
      final res = await api.call('POST', '${ApiConstants.monitoringServer}${ApiConstants.getGraphPoints}', data: payload);
      graphSeries.value = List<Map<String, dynamic>>.from(res['series'] ?? []);
    } catch (e) {
      graphError.value = 'Request failed with status code 500';
    }
    isGraphLoading.value = false;
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

  Future<bool> deleteProvider(String providerId) async {
    try {
      final api = Get.find<ApiService>();
      final res = await api.call('DELETE', '/ui/providers/$providerId');
      if (res['status'] == 'success') {
        providers.removeWhere((p) => p['providerId'] == providerId);
        selectedProvider.value = null;
        return true;
      }
    } catch (e) {
      print('Delete error: $e');
    }
    return false;
  }

  Future<String?> saveProviderConfig() async {
    final p = selectedProvider.value;
    if (p == null) return 'No provider selected';

    final config = <String, dynamic>{
      'providerId': p['providerId'],
      'providerName': selectedProviderName.value.isNotEmpty ? selectedProviderName.value : p['providerName'],
    };

    if (selectedVcpu.value.isNotEmpty) config['providerAllowedVcpu'] = selectedVcpu.value.split(' ')[0];
    if (selectedRam.value.isNotEmpty) {
      final val = int.tryParse(selectedRam.value.split(' ')[0]) ?? 0;
      config['providerAllowedRam'] = (val * 1024).toString();
    }
    if (selectedStorage.value.isNotEmpty) {
      final val = int.tryParse(selectedStorage.value.split(' ')[0]) ?? 0;
      config['providerAllowedStorage'] = (val * 1024).toString();
    }
    if (selectedNetworks.value.isNotEmpty) config['providerAllowedNetworks'] = selectedNetworks.value.split(' ')[0];
    if (selectedVms.value.isNotEmpty) config['providerAllowedVms'] = selectedVms.value.split(' ')[0];

    try { 
      final api = Get.find<ApiService>(); 
      // Using POST like React (although previously it was PUT in Flutter, React uses POST for /ui/providers/update_config)
      await api.call('POST', ApiConstants.updateProviderConfig, data: config); 
      await fetchProviders(); 
      return null; // Success
    } catch (e) { 
      return 'Error: $e'; 
    }
  }
}
