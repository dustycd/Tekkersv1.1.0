import 'package:flutter/material.dart';
import 'news_screen.dart';
import 'home_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const NewsScreen(),
    const SettingsScreen(),
  ];

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent, // Remove ripple effect
          highlightColor: Colors.transparent, // Remove highlight effect
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTap,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home, size: 22), // Smaller icon size
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.article, size: 22), // Smaller icon size
              label: 'News',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings, size: 22), // Smaller icon size
              label: 'Settings',
            ),
          ],
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true, // Show labels for unselected items
          backgroundColor: Colors.black,
          type: BottomNavigationBarType.fixed, // Fixed to show all items
          elevation: 5, // Small shadow for a polished look
          selectedFontSize: 12, // Smaller text for selected items
          unselectedFontSize: 10, // Smaller text for unselected items
        ),
      ),
    );
  }
}