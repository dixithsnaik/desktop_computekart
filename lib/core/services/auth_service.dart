import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// Auth service — mirrors React's `authHandler.js`.
class AuthService extends GetxService {
  final _storage = GetStorage();
  final _tokenKey = 'token';

  String get token => _storage.read(_tokenKey) ?? '';

  bool get isLoggedIn => token.isNotEmpty;

  void login(String token) {
    _storage.write(_tokenKey, token);
  }

  void logout() {
    _storage.remove(_tokenKey);
    Get.offAllNamed('/login');
  }

  String getToken() => token;
}
