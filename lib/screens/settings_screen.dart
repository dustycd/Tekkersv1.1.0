import 'package:flutter/material.dart';
import 'package:tekkers/screens/themes_screen.dart';
import 'package:tekkers/screens/login_form_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context); // Access theme data from the context

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background Image (original look)
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/field.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Semi-transparent overlay for better readability (no change in color based on theme)
          Container(
            color: Colors.black.withOpacity(0.6),
          ),
          // SafeArea to avoid system UI overlaps
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  // Account Settings
                  _buildSettingsOption(
                    context: context,
                    icon: Icons.person,
                    title: 'Account',
                    subtitle: 'Manage your account settings',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginPage(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 10),

                  // Themes Settings
                  _buildSettingsOption(
                    context: context,
                    icon: Icons.color_lens,
                    title: 'Themes',
                    subtitle: 'Choose your theme',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ThemesScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 10),

                  // Add more settings options here...
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // A reusable method to create each settings option card
  Widget _buildSettingsOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final themeData = Theme.of(context); // Access theme data within the method

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 3,
      child: ListTile(
        leading: Icon(icon, color: themeData.iconTheme.color, size: 30),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: themeData.textTheme.bodyLarge?.color,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: themeData.textTheme.bodyMedium?.color,
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, color: themeData.iconTheme.color),
        onTap: onTap,
      ),
    );
  }
}