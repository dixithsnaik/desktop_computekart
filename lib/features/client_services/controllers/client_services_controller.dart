import 'dart:async';
import 'package:get/get.dart';
import '../../../core/services/api_service.dart';
import '../../../core/constants/api_constants.dart';

class ClientServicesController extends GetxController {
  final vms = <Map<String, dynamic>>[].obs;
  final selectedVM = Rxn<Map<String, dynamic>>();
  final searchInput = ''.obs;
  final isLoadingList = false.obs;
  final isLoadingAction = false.obs;
  Timer? _debounce;

  List<Map<String, dynamic>> get activeVms => vms.where((vm) => vm['vmDeleted'] != true).toList();

  @override void onInit() { super.onInit(); ever(searchInput, (_) { _debounce?.cancel(); _debounce = Timer(const Duration(milliseconds: 500), fetchVMs); }); fetchVMs(); }
  @override void onClose() { _debounce?.cancel(); super.onClose(); }

  Future<void> fetchVMs() async {
    isLoadingList.value = true;
    try {
      final api = Get.find<ApiService>();
      final q = searchInput.value.trim();
      final res = await api.call('GET', ApiConstants.allVms, queryParameters: q.isNotEmpty ? {'vmName': q} : null);
      vms.value = List<Map<String, dynamic>>.from(res['all_vms'] ?? []);
      if (selectedVM.value != null) { final found = vms.firstWhereOrNull((vm) => vm['internalVmName'] == selectedVM.value!['internalVmName']); selectedVM.value = found; }
    } catch (_) {}
    isLoadingList.value = false;
  }

  void selectVM(Map<String, dynamic> vm) { selectedVM.value = selectedVM.value?['internalVmName'] == vm['internalVmName'] ? null : vm; }

  Future<String> vmAction(String type) async {
    if (selectedVM.value == null) return 'No VM selected';
    final endpoints = {'start': ApiConstants.startVm, 'stop': ApiConstants.stopVm, 'delete': ApiConstants.removeVm};
    isLoadingAction.value = true;
    try {
      final api = Get.find<ApiService>();
      final res = await api.call('POST', endpoints[type]!, data: {'vm_id': selectedVM.value!['internalVmName'], 'provider_id': selectedVM.value!['providerId']});
      await fetchVMs();
      return res['message'] ?? '$type succeeded';
    } catch (e) { return 'Error: $e'; } finally { isLoadingAction.value = false; }
  }
}
