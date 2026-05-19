import 'package:get/get.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/utils/validators.dart';

class LoginController extends GetxController {
  final isLoading = false.obs;
  final error = RxnString();
  final usernameOrEmail = ''.obs;
  final password = ''.obs;

  Future<void> login() async {
    // Validation
    String? validationError;
    final input = usernameOrEmail.value;
    if (input.contains('@')) {
      validationError = Validators.email(input);
    } else {
      validationError = Validators.username(input);
    }
    validationError ??= Validators.password(password.value);
    if (validationError != null) { error.value = validationError; return; }

    try {
      isLoading.value = true;
      error.value = null;
      final api = Get.find<ApiService>();
      final res = await api.call('POST', ApiConstants.login, data: {'username_or_email': input, 'password': password.value});
      final auth = Get.find<AuthService>();
      auth.login(res['token']);
      Get.offAllNamed('/dashboard');
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
