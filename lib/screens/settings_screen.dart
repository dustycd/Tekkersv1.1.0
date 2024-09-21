import 'package:flutter/material.dart';
import 'package:tekkers/screens/themes_screen.dart';
import 'package:tekkers/screens/account_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/field.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Semi-transparent overlay for better readability
          Container(
            color: Colors.black.withOpacity(0.3),
          ),
          // SafeArea to avoid system UI overlaps
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.only(top: 20),
              children: [
                // Account Settings
                Container(
                  color: Colors.white, // White background for each option
                  child: ListTile(
                    leading: const Icon(Icons.person, color: Colors.black), // Icon in black
                    title: const Text(
                      'Account',
                      style: TextStyle(
                        color: Colors.black, // Text in black
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AccountSettingsScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const Divider(color: Colors.white70),

                // Themes Settings
                Container(
                  color: Colors.white,
                  child: ListTile(
                    leading: const Icon(Icons.color_lens, color: Colors.black),
                    title: const Text(
                      'Themes',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ThemesScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const Divider(color: Colors.white70),

                // Additional settings can go here...
              ],
            ),
          ),
        ],
      ),
    );
  }
}