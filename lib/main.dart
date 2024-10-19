import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/competition_provider.dart';
import 'providers/theme_manager.dart';
import 'screens/splash_screen.dart';
import 'providers/team_provider.dart';
import 'providers/match_provider.dart';
import 'providers/player_provider.dart';
import 'providers/news_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize the ThemeManager with the default theme.
  ThemeManager themeManager = ThemeManager(ThemeData.light());
  // Load the theme preference.
  await themeManager.loadTheme();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CompetitionProvider()),
        ChangeNotifierProvider(create: (_) => TeamProvider()),
        ChangeNotifierProvider(create: (_) => MatchProvider()),
        ChangeNotifierProvider(create: (_) => PlayerProvider()),
        ChangeNotifierProvider(create: (_) => NewsProvider()),
        ChangeNotifierProvider<ThemeManager>.value(value: themeManager),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the ThemeManager from the context
    final themeManager = Provider.of<ThemeManager>(context);
    return MaterialApp(
      title: 'Tekkers',
      theme: themeManager.themeData, // Use the theme data from ThemeManager
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
