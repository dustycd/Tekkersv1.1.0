import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tekkers/screens/home_screen.dart';
import 'package:tekkers/providers/team_provider.dart';
import 'package:tekkers/screens/news_screen.dart';
import 'package:tekkers/screens/settings_screen.dart';

void main() {
  // Helper function to wrap the widget under test with the required providers.
  Widget createTestableWidget(Widget widget) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TeamProvider()),
        // Add providers if needed
      ],
      child: MaterialApp(
        home: widget,
      ),
    );
  }

  testWidgets('App renders HomeScreen with BottomNavigationBar',
      (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(createTestableWidget(const HomeScreen()));

    // Act
    await tester.pumpAndSettle();

    // Assert
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('News'), findsOneWidget);
    expect(find.text('Transfers'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('Tapping on BottomNavigationBar switches screens',
      (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(createTestableWidget(const HomeScreen()));

    // Act & Assert
    await tester.tap(find.text('News'));
    await tester.pumpAndSettle();
    expect(find.byType(NewsScreen), findsOneWidget); // Check for NewsScreen

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen),
        findsOneWidget); // Check for SettingsScreen

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('NewsScreen shows loading indicator while fetching news',
      (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(createTestableWidget(const NewsScreen()));

    // Act
    await tester.pump(); // Let the loading state be active for a moment

    // Assert
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('NewsScreen displays list of news articles after loading',
      (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(createTestableWidget(const NewsScreen()));

    // Act
    await tester.pumpAndSettle(); // Wait for the loading and news data

    // Assert
    expect(find.byType(ListTile),
        findsWidgets); // Assuming ListTile represents a news article
  });

  testWidgets('NewsScreen search functionality works',
      (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(createTestableWidget(const NewsScreen()));

    // Act
    await tester.enterText(find.byType(TextField), 'Premier League');
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle(); // Wait for the search results to load

    // Assert
    expect(find.textContaining('Premier League'),
        findsWidgets); // Verifying search results contain 'Premier League'
  });

  testWidgets('HomeScreen displays a list of teams when loaded',
      (WidgetTester tester) async {
    // Arrange
    final teamProvider = TeamProvider();
    // Mock or load data here, assuming fetchTeams is the correct method
    await teamProvider.fetchTeams(); // Mocking team loading

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => teamProvider),
        ],
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    // Act
    await tester.pumpAndSettle();

    // Assert
    expect(find.byType(ListTile), findsWidgets);
  });

  testWidgets('HomeScreen shows loading indicator while fetching data',
      (WidgetTester tester) async {
    // Arrange
    final teamProvider = TeamProvider();
    teamProvider.fetchTeams(); // Ensure this triggers a loading state

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => teamProvider),
        ],
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    // Act
    await tester.pump();

    // Assert
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
