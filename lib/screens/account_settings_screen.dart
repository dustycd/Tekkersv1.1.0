import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tekkers/models/user.dart';
import 'package:tekkers/screens/login_form_screen.dart';
import 'package:tekkers/service/auth_service.dart';


class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  _AccountSettingsScreenState createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  String? _username;
  String? _email;
  bool _isAuthenticated = false;
  final secureStorage = const FlutterSecureStorage();
  UserProfile? _userProfile; // Store user profile details

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Load user data from SharedPreferences and access token from secure storage
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = await secureStorage.read(key: 'accessToken');

    setState(() {
      _username = prefs.getString('username');
      _email = prefs.getString('email');
      _isAuthenticated = accessToken != null; // User is authenticated if access token exists
    });
  }

  Future<void> _logout() async {
    await AuthService().logout(); // Use AuthService for logout
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all non-sensitive user data
    await secureStorage.delete(key: 'accessToken'); // Clear access token from secure storage
    setState(() {
      _isAuthenticated = false;
      _username = null;
      _email = null;
      _userProfile = null;
    });
  }

  Future<void> _fetchUserProfile() async {
    final authService = AuthService();
    final credentials = await authService.login();
    if (credentials != null) {
      setState(() {
        _userProfile = credentials.user; // Set user profile after successful login
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Settings'),
        actions: _isAuthenticated
            ? [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: _logout,
                ),
              ]
            : null,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/field.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: _isAuthenticated
              ? _buildLoggedInUI() // Show account info if logged in
              : _buildLoggedOutUI(context), // Show login form if not logged in
        ),
      ),
    );
  }

  // Creative UI for logged-in users with user profile display
  Widget _buildLoggedInUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _userProfile != null
            ? UserWidget(user: _userProfile) // Show full user profile if available
            : CircularProgressIndicator(), // Show loading indicator until user profile is fetched
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _fetchUserProfile, // Button to fetch user profile
          child: const Text('Refresh Profile'),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _logout,
          child: const Text('Logout'),
        ),
      ],
    );
  }

  // Login form when user is not authenticated
  Widget _buildLoggedOutUI(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'You are not logged in',
          style: TextStyle(fontSize: 18, color: Colors.white),
          
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            ).then((_) {
              _loadUserData(); // Reload user data after login
            });
          },
          child: const Text('Login / Register'),
        ),
      ],
    );
  }
}