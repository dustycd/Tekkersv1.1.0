import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tekkers/screens/account_settings_screen.dart';
import 'package:tekkers/screens/login_form_screen.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  // Method to check if the user is logged in by using SharedPreferences
  Future<bool> _isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Assuming the login state is stored as a boolean under 'isLoggedIn'
    return prefs.getBool('isLoggedIn') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<bool>(
        future: _isLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // While waiting for the future to complete, show a loading indicator
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData && snapshot.data == true) {
            // If the user is logged in, show the AccountSettingsScreen
            return AccountSettingsScreen();
          } else {
            // Otherwise, show the LoginPage
            return LoginPage();
          }
        },
      ),
    );
  }
}