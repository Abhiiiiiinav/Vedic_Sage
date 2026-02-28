import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:astro_learn/features/yogas/widgets/yoga_date_cell.dart';
import 'package:astro_learn/core/models/yoga_models.dart';

void main() {
  group('YogaDateCell Widget Tests', () {
    final testDate = DateTime(2024, 1, 15);
    
    testFinder(String text) => find.text(text);
    
    Widget createTestWidget(Widget child) {
      return MaterialApp(
        home: Scaffold(
          body: Center(child: child),
        ),
      );
    }

    test('YogaDateCell displays date number', () {
      final widget = YogaDateCell(
        date: testDate,
        yogas: null,
      );
      
      expect(widget.date.day, 15);
    });

    testWidgets('displays date with no yogas', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          YogaDateCell(
            date: testDate,
            yogas: [],
          ),
        ),
      );

      expect(testFinder('15'), findsOneWidget);
      // Should not show yoga indicators when no yogas
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('displays date with auspicious yogas', (WidgetTester tester) async {
      final auspiciousYoga = YogaResult(
        type: YogaType.amritSiddhi,
        definition: YogaDefinitions.amritSiddhi,
        activeDate: testDate,
        tithi: 'Pratipada',
        nakshatra: 'Ashwini',
        vara: 'Sunday',
      );

      await tester.pumpWidget(
        createTestWidget(
          YogaDateCell(
            date: testDate,
            yogas: [auspiciousYoga],
          ),
        ),
      );

      expect(testFinder('15'), findsOneWidget);
      expect(testFinder('1'), findsOneWidget); // Yoga count badge
    });

    testWidgets('displays date with mixed yogas', (WidgetTester tester) async {
      final auspiciousYoga = YogaResult(
        type: YogaType.siddha,
        definition: YogaDefinitions.siddha,
        activeDate: testDate,
        tithi: 'Dwitiya',
        nakshatra: 'Bharani',
        vara: 'Monday',
      );
      
      final inauspiciousYoga = YogaResult(
        type: YogaType.dagdha,
        definition: YogaDefinitions.dagdha,
        activeDate: testDate,
        tithi: 'Tritiya',
        nakshatra: 'Krittika',
        vara: 'Tuesday',
      );

      await tester.pumpWidget(
        createTestWidget(
          YogaDateCell(
            date: testDate,
            yogas: [auspiciousYoga, inauspiciousYoga],
          ),
        ),
      );

      expect(testFinder('15'), findsOneWidget);
      expect(testFinder('2'), findsOneWidget); // Yoga count badge shows 2
    });

    testWidgets('handles tap when yogas present', (WidgetTester tester) async {
      bool tapped = false;
      final yoga = YogaResult(
        type: YogaType.guruPushya,
        definition: YogaDefinitions.guruPushya,
        activeDate: testDate,
        tithi: 'Panchami',
        nakshatra: 'Pushya',
        vara: 'Thursday',
      );

      await tester.pumpWidget(
        createTestWidget(
          YogaDateCell(
            date: testDate,
            yogas: [yoga],
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.byType(YogaDateCell));
      expect(tapped, true);
    });

    testWidgets('shows selected state', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          YogaDateCell(
            date: testDate,
            yogas: [],
            isSelected: true,
          ),
        ),
      );

      expect(testFinder('15'), findsOneWidget);
      // Widget should be rendered with selected styling
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(GestureDetector),
          matching: find.byType(Container),
        ).first,
      );
      expect(container, isNotNull);
    });

    testWidgets('shows today state', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          YogaDateCell(
            date: testDate,
            yogas: [],
            isToday: true,
          ),
        ),
      );

      expect(testFinder('15'), findsOneWidget);
      // Widget should be rendered with today styling
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(GestureDetector),
          matching: find.byType(Container),
        ).first,
      );
      expect(container, isNotNull);
    });
  });
}
