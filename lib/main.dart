// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/competition_provider.dart';
import 'providers/theme_manager.dart';
import 'screens/splash_screen.dart';
import 'providers/team_provider.dart';
import 'providers/match_provider.dart';
import 'providers/player_provider.dart';
import 'providers/news_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CompetitionProvider()),
        ChangeNotifierProvider(create: (_) => TeamProvider()),
        ChangeNotifierProvider(create: (_) => MatchProvider()),
        ChangeNotifierProvider(create: (_) => PlayerProvider()),
        ChangeNotifierProvider(create: (_) => NewsProvider()),
        ChangeNotifierProvider(create: (_) => ThemeManager()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tekkers',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(), 
      debugShowCheckedModeBanner: false, 
    );
  }
}