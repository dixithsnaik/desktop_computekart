import 'package:get/get.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/utils/validators.dart';

class RegisterController extends GetxController {
  final isLoading = false.obs;
  final error = RxnString();
  final email = ''.obs;
  final username = ''.obs;
  final password = ''.obs;
  final confirmPassword = ''.obs;

  Future<void> register() async {
    error.value = null;
    var e = Validators.username(username.value); if (e != null) { error.value = e; return; }
    e = Validators.email(email.value); if (e != null) { error.value = e; return; }
    e = Validators.password(password.value); if (e != null) { error.value = e; return; }
    if (password.value != confirmPassword.value) { error.value = 'Passwords do not match'; return; }

    try {
      isLoading.value = true;
      final api = Get.find<ApiService>();
      final res = await api.call('POST', ApiConstants.register, data: {'email': email.value, 'username': username.value, 'password': password.value});
      Get.find<AuthService>().login(res['token']);
      Get.offAllNamed('/dashboard');
    } catch (err) {
      error.value = err.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
