import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:astro_learn/features/yogas/screens/annual_yogas_screen.dart';
import 'package:astro_learn/app/theme.dart';

void main() {
  group('AnnualYogasScreen Widget Tests', () {
    testWidgets('should display screen title and header', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AnnualYogasScreen(),
        ),
      );

      // Wait for initial render
      await tester.pump();

      // Verify header elements
      expect(find.text('Annual Yogas'), findsOneWidget);
      expect(find.text('Special Days List'), findsOneWidget);
      expect(find.byIcon(Icons.event_note), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios), findsOneWidget);
    });

    testWidgets('should display year selector with current year', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AnnualYogasScreen(),
        ),
      );

      await tester.pump();

      // Verify year selector
      final currentYear = DateTime.now().year;
      expect(find.text(currentYear.toString()), findsOneWidget);
      expect(find.byIcon(Icons.chevron_left), findsWidgets);
      expect(find.byIcon(Icons.chevron_right), findsWidgets);
    });

    testWidgets('should display search bar', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AnnualYogasScreen(),
        ),
      );

      await tester.pump();

      // Verify search bar
      expect(
        find.widgetWithText(TextField, 'Search by date, weekday, or yoga name...'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('should display filter chips', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AnnualYogasScreen(),
        ),
      );

      await tester.pump();

      // Verify "All" filter chip
      expect(find.text('All'), findsOneWidget);
      
      // Verify some yoga type filter chips
      expect(find.text('Amrit Siddhi'), findsOneWidget);
      expect(find.text('Guru Pushya'), findsOneWidget);
      expect(find.text('Dagdha'), findsOneWidget);
    });

    testWidgets('should display loading indicator initially', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AnnualYogasScreen(),
        ),
      );

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display location info', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AnnualYogasScreen(),
        ),
      );

      await tester.pump();

      // Verify location icon
      expect(find.byIcon(Icons.location_on), findsOneWidget);
    });

    testWidgets('should allow year navigation', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AnnualYogasScreen(),
        ),
      );

      await tester.pump();

      final currentYear = DateTime.now().year;
      expect(find.text(currentYear.toString()), findsOneWidget);

      // Tap next year button
      final nextYearButtons = find.byIcon(Icons.chevron_right);
      await tester.tap(nextYearButtons.first);
      await tester.pump();

      // Year should increment
      expect(find.text((currentYear + 1).toString()), findsOneWidget);

      // Tap previous year button
      final prevYearButtons = find.byIcon(Icons.chevron_left);
      await tester.tap(prevYearButtons.first);
      await tester.pump();

      // Year should go back to current
      expect(find.text(currentYear.toString()), findsOneWidget);
    });

    testWidgets('should allow search input', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AnnualYogasScreen(),
        ),
      );

      await tester.pump();

      // Find search field
      final searchField = find.widgetWithText(
        TextField,
        'Search by date, weekday, or yoga name...',
      );
      expect(searchField, findsOneWidget);

      // Enter search text
      await tester.enterText(searchField, 'Guru Pushya');
      await tester.pump();

      // Verify text was entered
      expect(find.text('Guru Pushya'), findsWidgets);

      // Clear button should appear
      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('should clear search when clear button tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AnnualYogasScreen(),
        ),
      );

      await tester.pump();

      // Enter search text
      final searchField = find.widgetWithText(
        TextField,
        'Search by date, weekday, or yoga name...',
      );
      await tester.enterText(searchField, 'test');
      await tester.pump();

      // Tap clear button
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      // Search field should be empty
      final textField = tester.widget<TextField>(searchField);
      expect(textField.controller?.text, isEmpty);
    });

    testWidgets('should toggle filter chips', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AnnualYogasScreen(),
        ),
      );

      await tester.pump();

      // Find and tap a filter chip
      final amritSiddhiChip = find.text('Amrit Siddhi');
      expect(amritSiddhiChip, findsOneWidget);

      await tester.tap(amritSiddhiChip);
      await tester.pump();

      // Filter alt off icon should appear (clear filters button)
      expect(find.byIcon(Icons.filter_alt_off), findsOneWidget);
    });

    testWidgets('should clear all filters when clear button tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AnnualYogasScreen(),
        ),
      );

      await tester.pump();

      // Select a filter
      await tester.tap(find.text('Amrit Siddhi'));
      await tester.pump();

      // Clear filters button should appear
      expect(find.byIcon(Icons.filter_alt_off), findsOneWidget);

      // Tap clear filters
      await tester.tap(find.byIcon(Icons.filter_alt_off));
      await tester.pump();

      // Clear button should disappear
      expect(find.byIcon(Icons.filter_alt_off), findsNothing);
    });

    testWidgets('should navigate back when back button pressed', (WidgetTester tester) async {
      bool didPop = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AnnualYogasScreen(),
                      ),
                    );
                    didPop = true;
                  },
                  child: const Text('Go'),
                ),
              ),
            ),
          ),
        ),
      );

      // Navigate to annual yogas screen
      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();

      // Verify we're on the annual yogas screen
      expect(find.text('Annual Yogas'), findsOneWidget);

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back_ios));
      await tester.pumpAndSettle();

      // Should have navigated back
      expect(didPop, isTrue);
    });
  });
}
