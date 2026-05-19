import 'dart:async';
import 'package:get/get.dart';
import '../../../core/services/api_service.dart';
import '../../../core/constants/api_constants.dart';

class ProvidersController extends GetxController {
  final providers = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final searchInput = ''.obs;
  final selectedProvider = Rxn<Map<String, dynamic>>();
  final formData = <String, dynamic>{'vcpus': '', 'ram': '', 'vm_image': '', 'remarks': '', 'provider_id': '', 'vm_name': '', 'client_id': '1', 'storage': ''}.obs;
  Timer? _debounce;

  @override void onInit() { super.onInit(); ever(searchInput, (_) => _debounceSearch()); fetchProviders(); }
  @override void onClose() { _debounce?.cancel(); super.onClose(); }

  void _debounceSearch() { _debounce?.cancel(); _debounce = Timer(const Duration(milliseconds: 500), fetchProviders); }

  Future<void> fetchProviders() async {
    isLoading.value = true;
    try {
      final api = Get.find<ApiService>();
      final res = await api.call('GET', ApiConstants.providersList, queryParameters: {'provider_name': searchInput.value});
      final list = res['all_providers'] as List? ?? [];
      providers.value = list.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) { 
      print('ProvidersController.fetchProviders Error: $e'); 
    }
    isLoading.value = false;
  }

  void selectProvider(Map<String, dynamic> p) {
    if (selectedProvider.value?['providerId'] == p['providerId']) { selectedProvider.value = null; formData.value = {'vcpus': '', 'ram': '', 'vm_image': '', 'remarks': '', 'provider_id': '', 'vm_name': '', 'client_id': '1', 'storage': ''}; return; }
    selectedProvider.value = p;
    formData['provider_id'] = p['providerId'].toString();
  }

  void updateField(String key, dynamic value) { formData[key] = value; formData.refresh(); }

  Future<String?> queryVM() async {
    if (selectedProvider.value == null) return 'Please select a provider';
    try {
      final api = Get.find<ApiService>();
      final res = await api.call('POST', ApiConstants.providersQuery, data: {...formData, 'provider_user_id': selectedProvider.value!['user_id']});
      return res['can_create'] == true ? 'You can create VM in this Provider.' : 'Cannot create VM in this provider';
    } catch (e) { return e.toString(); }
  }

  Future<String?> requestVM() async {
    if (selectedProvider.value == null) return 'Please select a provider';
    try {
      final api = Get.find<ApiService>();
      await api.call('POST', ApiConstants.launchVm, data: {...formData, 'provider_user_id': selectedProvider.value!['user_id'], 'provider_name': selectedProvider.value!['provider_name']});
      return 'VM has been created!';
    } catch (e) { return e.toString(); }
  }
}
