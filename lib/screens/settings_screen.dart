import 'package:flutter/material.dart';
import 'package:tekkers/screens/themes_screen.dart';

// Import other necessary screens here
// import 'package:tekkers/screens/account_settings_screen.dart';
// import 'package:tekkers/screens/privacy_settings_screen.dart';
// import 'package:tekkers/screens/language_settings_screen.dart';
// import 'package:tekkers/screens/help_support_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Removed the default AppBar background color to allow the background image to show through
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
            color: Colors.white, // Set text color to white
            fontSize: 16, // Decreased font size for a smaller header
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true, // Allows the body to extend behind the AppBar
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/field.png'), // Ensure the path is correct
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
              padding: const EdgeInsets.only(top: 20), // Additional padding at the top
              children: [
                // Optional: Add a SizedBox for extra spacing
                const SizedBox(height: 10),
                
                // Account Settings
                ListTile(
                  leading: const Icon(
                    Icons.person,
                    color: Colors.white, // Set icon color to white
                  ),
                  title: const Text(
                    'Account',
                    style: TextStyle(
                      color: Colors.white, // Set text color to white
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white, // Set icon color to white
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AccountSettingsScreen(),
                      ),
                    );
                  },
                ),
                // Divider for separation
                const Divider(color: Colors.white70),
                
                // Themes Settings
                ListTile(
                  leading: const Icon(
                    Icons.color_lens,
                    color: Colors.white, // Set icon color to white
                  ),
                  title: const Text(
                    'Themes',
                    style: TextStyle(
                      color: Colors.white, // Set text color to white
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white, // Set icon color to white
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ThemesScreen(),
                      ),
                    );
                  },
                ),
                const Divider(color: Colors.white70),
                
                // Privacy Settings (Optional)
                ListTile(
                  leading: const Icon(
                    Icons.lock,
                    color: Colors.white, // Set icon color to white
                  ),
                  title: const Text(
                    'Privacy',
                    style: TextStyle(
                      color: Colors.white, // Set text color to white
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white, // Set icon color to white
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PrivacySettingsScreen(),
                      ),
                    );
                  },
                ),
                const Divider(color: Colors.white70),
                
                // Language Settings (Optional)
                ListTile(
                  leading: const Icon(
                    Icons.language,
                    color: Colors.white, // Set icon color to white
                  ),
                  title: const Text(
                    'Language',
                    style: TextStyle(
                      color: Colors.white, // Set text color to white
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white, // Set icon color to white
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LanguageSettingsScreen(),
                      ),
                    );
                  },
                ),
                const Divider(color: Colors.white70),
                
                // Help & Support (Optional)
                ListTile(
                  leading: const Icon(
                    Icons.help,
                    color: Colors.white, // Set icon color to white
                  ),
                  title: const Text(
                    'Help & Support',
                    style: TextStyle(
                      color: Colors.white, // Set text color to white
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white, // Set icon color to white
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HelpSupportScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Example of an Account Settings Screen
class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Settings'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/field.png'), // Optional: same background
            fit: BoxFit.cover,
          ),
        ),
        child: const Center(
          child: Text(
            'Account Settings Content',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

// Example of a Privacy Settings Screen
class PrivacySettingsScreen extends StatelessWidget {
  const PrivacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Settings'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/field.png'), // Optional: same background
            fit: BoxFit.cover,
          ),
        ),
        child: const Center(
          child: Text(
            'Privacy Settings Content',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

// Example of a Language Settings Screen
class LanguageSettingsScreen extends StatelessWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Language Settings'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/field.png'), // Optional: same background
            fit: BoxFit.cover,
          ),
        ),
        child: const Center(
          child: Text(
            'Language Settings Content',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

// Example of a Help & Support Screen
class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/field.png'), // Optional: same background
            fit: BoxFit.cover,
          ),
        ),
        child: const Center(
          child: Text(
            'Help & Support Content',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }
}