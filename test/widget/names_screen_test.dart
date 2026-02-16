
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:astro_learn/features/names/screens/names_screen.dart';
import 'package:astro_learn/app/theme.dart';
import 'package:astro_learn/core/services/gemini_service.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

// Mock GeminiService (though we won't strictly need it if we handle the error gracefully or mock the provider if it relies on one)
// For this widget test, we just want to see if the screen builds and we can interact with it.
// Since `GeminiService` is instantiated inside `_EnhancedNamesScreenState`, mocking it is tricky without dependency injection.
// However, the screen handles errors gracefully, so we can test the UI flow even if the service call fails (or build a testable version).

void main() {
  testWidgets('EnhancedNamesScreen UI Test', (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        theme: AstroTheme.darkTheme,
        home: const EnhancedNamesScreen(),
      ),
    );

    // Verify initial state
    expect(find.text('Name Analysis'), findsOneWidget);
    expect(find.text('Enter Your Name'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);

    // Enter a name
    await tester.enterText(find.byType(TextField), 'Abhinav');
    await tester.pump();

    // Tap Analyze button key
    // The button has text 'Analyze Name Energy'
    final analyzeButton = find.text('Analyze Name Energy');
    expect(analyzeButton, findsOneWidget);
    
    await tester.tap(analyzeButton);
    await tester.pump(); // Start animation
    
    // We expect a loading indicator or immediate result depending on implementation details.
    // Since the service call is real (and will fail in test environment without internet/api key), 
    // it likely shows an error or a fallback result.
    // The implementation catches errors and uses local fallback data! 
    // So we SHOULD see a result 
    
    await tester.pump(const Duration(seconds: 2)); // Wait for valid "fallback" analysis to process

    // Verify result card appears
    // The result card shows the name with sparkles
    expect(find.text('✨ Abhinav ✨'), findsOneWidget);
    
    // Verify Nakshatra analysis content
    // "Soul Vibration: ..."
    expect(find.textContaining('Soul Vibration:'), findsOneWidget);
    
    // Verify Personality Traits section
    expect(find.text('Personality Traits'), findsOneWidget);
  });
}
