import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tekkers/providers/theme_manager.dart';

class ThemesScreen extends StatelessWidget {
  const ThemesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Themes',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background Image (consistent with SettingsScreen)
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/field.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Semi-transparent overlay for better readability
          Container(
            color: Colors.black.withOpacity(0.6),
          ),
          // SafeArea to avoid system UI overlaps
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  // Light Theme Option
                  ThemeOptionCard(
                    icon: Icons.wb_sunny,
                    title: 'Light Theme',
                    onTap: () => themeManager.setTheme(ThemeData.light()),
                  ),
                  const SizedBox(height: 10),
                  // Dark Theme Option
                  ThemeOptionCard(
                    icon: Icons.nights_stay,
                    title: 'Dark Theme',
                    onTap: () => themeManager.setTheme(ThemeData.dark()),
                  ),
                  const SizedBox(height: 10),
                  // Add more theme options here
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// A reusable card widget for theme selection options
class ThemeOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const ThemeOptionCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
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
        onTap: onTap,
      ),
    );
  }
}