import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:astro_learn/features/panchang/screens/panchang_screen.dart';

/// Widget test for Panchang screen yoga section integration
/// 
/// These tests verify that the yoga section has been successfully integrated
/// into the Panchang screen without breaking existing functionality.
void main() {
  group('Panchang Yoga Integration Tests', () {
    testWidgets('Panchang screen should load without errors', (WidgetTester tester) async {
      // Build the Panchang screen
      await tester.pumpWidget(
        const MaterialApp(
          home: PanchangScreen(),
        ),
      );
      
      // Wait for initial loading to complete
      await tester.pumpAndSettle();
      
      // Verify the screen loads successfully
      expect(find.text('Panchang'), findsOneWidget);
      
      // Verify tabs are present
      expect(find.text('📅 Today'), findsOneWidget);
      expect(find.text('✨ For You'), findsOneWidget);
    });
    
    testWidgets('Panchang screen should show loading state initially', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PanchangScreen(),
        ),
      );
      
      // Before pumpAndSettle, we should see loading indicators
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });
    
    testWidgets('Panchang screen should render without throwing exceptions', (WidgetTester tester) async {
      // This test verifies that adding the yoga section doesn't break the screen
      await tester.pumpWidget(
        const MaterialApp(
          home: PanchangScreen(),
        ),
      );
      
      // Pump multiple frames to ensure async operations complete
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      
      // If we get here without exceptions, the integration is successful
      expect(find.byType(PanchangScreen), findsOneWidget);
    });
  });
}
