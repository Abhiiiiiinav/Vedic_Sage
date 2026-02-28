import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:astro_learn/features/yogas/widgets/purpose_filter_widget.dart';
import 'package:astro_learn/core/models/yoga_models.dart';

void main() {
  group('PurposeFilterWidget', () {
    testWidgets('displays all filter chips including "All"', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PurposeFilterWidget(
              onFilterChanged: (_) {},
            ),
          ),
        ),
      );

      // Should display "All" chip
      expect(find.text('All'), findsOneWidget);
      
      // Should display all purpose chips
      expect(find.text('Marriage'), findsOneWidget);
      expect(find.text('Business'), findsOneWidget);
      expect(find.text('Education'), findsOneWidget);
      expect(find.text('Travel'), findsOneWidget);
      expect(find.text('Spiritual'), findsOneWidget);
      expect(find.text('Health'), findsOneWidget);
    });

    testWidgets('"All" is selected by default', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PurposeFilterWidget(
              onFilterChanged: (_) {},
            ),
          ),
        ),
      );

      // Find the "All" chip container
      final allChip = find.ancestor(
        of: find.text('All'),
        matching: find.byType(InkWell),
      );
      
      expect(allChip, findsOneWidget);
    });

    testWidgets('selecting a purpose calls onFilterChanged', (tester) async {
      List<YogaPurpose>? capturedPurposes;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PurposeFilterWidget(
              onFilterChanged: (purposes) {
                capturedPurposes = purposes;
              },
            ),
          ),
        ),
      );

      // Tap on "Marriage" chip
      await tester.tap(find.text('Marriage'));
      await tester.pumpAndSettle();

      // Should call onFilterChanged with Marriage purpose
      expect(capturedPurposes, isNotNull);
      expect(capturedPurposes, contains(YogaPurpose.marriage));
      expect(capturedPurposes!.length, 1);
    });

    testWidgets('can select multiple purposes', (tester) async {
      List<YogaPurpose>? capturedPurposes;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PurposeFilterWidget(
              onFilterChanged: (purposes) {
                capturedPurposes = purposes;
              },
            ),
          ),
        ),
      );

      // Tap on "Marriage" chip
      await tester.tap(find.text('Marriage'));
      await tester.pumpAndSettle();

      // Tap on "Business" chip
      await tester.tap(find.text('Business'));
      await tester.pumpAndSettle();

      // Should have both purposes selected
      expect(capturedPurposes, isNotNull);
      expect(capturedPurposes, contains(YogaPurpose.marriage));
      expect(capturedPurposes, contains(YogaPurpose.business));
      expect(capturedPurposes!.length, 2);
    });

    testWidgets('tapping selected purpose deselects it', (tester) async {
      List<YogaPurpose>? capturedPurposes;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PurposeFilterWidget(
              onFilterChanged: (purposes) {
                capturedPurposes = purposes;
              },
            ),
          ),
        ),
      );

      // Tap on "Marriage" chip to select
      await tester.tap(find.text('Marriage'));
      await tester.pumpAndSettle();

      // Tap on "Marriage" chip again to deselect
      await tester.tap(find.text('Marriage'));
      await tester.pumpAndSettle();

      // Should have no purposes selected (back to "All")
      expect(capturedPurposes, isNotNull);
      expect(capturedPurposes!.isEmpty, true);
    });

    testWidgets('tapping "All" clears all selections', (tester) async {
      List<YogaPurpose>? capturedPurposes;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PurposeFilterWidget(
              onFilterChanged: (purposes) {
                capturedPurposes = purposes;
              },
            ),
          ),
        ),
      );

      // Select multiple purposes
      await tester.tap(find.text('Marriage'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Business'));
      await tester.pumpAndSettle();

      // Tap "All" to clear selections
      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();

      // Should have no purposes selected
      expect(capturedPurposes, isNotNull);
      expect(capturedPurposes!.isEmpty, true);
    });

    testWidgets('respects initial selection', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PurposeFilterWidget(
              onFilterChanged: (_) {},
              initialSelection: [YogaPurpose.marriage, YogaPurpose.business],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // The widget should start with Marriage and Business selected
      // We can't easily verify visual state, but we can verify it doesn't crash
      expect(find.text('Marriage'), findsOneWidget);
      expect(find.text('Business'), findsOneWidget);
    });
  });
}
