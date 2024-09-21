import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  late Auth0 auth0;
  final secureStorage = const FlutterSecureStorage();

  AuthService() {
    // Manually input the Auth0 domain and client ID here
    auth0 = Auth0('dev-fzxnew5iop6eeim0.us.auth0.com', 'ghXOlGD9aeqA4pRo06kV0mIRIgqUL6Iy');
  }

  // Login function returns Credentials (correct type)
  Future<Credentials?> login() async {
    try {
      // Perform login and return credentials, which contains access token and user info
      var credentials = await auth0
          .webAuthentication(scheme: 'tekkers')
          .login(useHTTPS: true);

      // Store credentials locally
      final prefs = await SharedPreferences.getInstance();
      await secureStorage.write(key: 'accessToken', value: credentials.accessToken ?? '');
      await prefs.setString('username', credentials.user.name ?? 'No Name');
      await prefs.setString('email', credentials.user.email ?? 'No Email');

      return credentials; // Return full credentials object
    } catch (e) {
      print('Error during login: $e');
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await auth0
          .webAuthentication(scheme: 'tekkers')
          .logout(useHTTPS: true);

      // Clear stored credentials
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Clear all user data
      await secureStorage.delete(key: 'accessToken'); // Delete access token from secure storage
    } catch (e) {
      print('Error during logout: $e');
    }
  }
}