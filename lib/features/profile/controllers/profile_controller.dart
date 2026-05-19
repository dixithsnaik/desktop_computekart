import 'package:get/get.dart';
import '../../../core/services/api_service.dart';
import '../../../core/constants/api_constants.dart';

class ProfileController extends GetxController {
  final isLoading = true.obs;
  final user = Rxn<Map<String, dynamic>>();
  final providers = <Map<String, dynamic>>[].obs;
  final clients = <Map<String, dynamic>>[].obs;
  final isProvider = true.obs;

  @override
  void onInit() { super.onInit(); _loadAll(); }

  Future<void> _loadAll() async {
    isLoading.value = true;
    final api = Get.find<ApiService>();
    try {
      final results = await Future.wait([
        api.call('GET', ApiConstants.getUserDetails),
        api.call('GET', ApiConstants.userProviderDetails),
        api.call('GET', ApiConstants.getAllCliSessionDetails),
      ]);
      user.value = results[0] is Map<String, dynamic> ? results[0] : {};
      final provList = results[1]['all_providers'] as List? ?? [];
      providers.value = provList.map((e) => Map<String, dynamic>.from(e)).toList();
      
      final cliList = results[2]['cli_session_details'] as List? ?? [];
      clients.value = cliList.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) { 
      print('ProfileController._loadAll Error: $e'); 
    }
    isLoading.value = false;
  }

  Future<void> fetchUserDetails() async {
    final api = Get.find<ApiService>();
    try { user.value = await api.call('GET', ApiConstants.getUserDetails); } catch (_) {}
  }

  Future<String?> updateProfile({String? profileName, String? profileImage}) async {
    final api = Get.find<ApiService>();
    try {
      final body = <String, dynamic>{};
      if (profileName != null) body['profileName'] = profileName;
      if (profileImage != null) body['profileImage'] = profileImage;
      final res = await api.call('PUT', ApiConstants.updateUserDetails, data: body);
      await fetchUserDetails();
      return res['message'] ?? 'Profile updated';
    } catch (e) { return null; }
  }
}
