import 'package:flutter_test/flutter_test.dart';
import 'package:jyotish_app/core/utils/debouncer.dart';

void main() {
  group('Debouncer', () {
    test('should delay execution until duration elapses', () async {
      final debouncer = Debouncer(duration: const Duration(milliseconds: 100));
      int callCount = 0;

      debouncer.run(() {
        callCount++;
      });

      // Should not execute immediately
      expect(callCount, equals(0));

      // Wait for duration to elapse
      await Future.delayed(const Duration(milliseconds: 150));

      // Should have executed once
      expect(callCount, equals(1));

      debouncer.dispose();
    });

    test('should cancel previous timer when called again', () async {
      final debouncer = Debouncer(duration: const Duration(milliseconds: 100));
      int callCount = 0;

      // First call
      debouncer.run(() {
        callCount++;
      });

      // Wait 50ms (less than duration)
      await Future.delayed(const Duration(milliseconds: 50));

      // Second call (should cancel first)
      debouncer.run(() {
        callCount++;
      });

      // Wait for first duration to complete (should not execute)
      await Future.delayed(const Duration(milliseconds: 60));
      expect(callCount, equals(0));

      // Wait for second duration to complete
      await Future.delayed(const Duration(milliseconds: 50));
      expect(callCount, equals(1));

      debouncer.dispose();
    });

    test('should execute only the last call in rapid succession', () async {
      final debouncer = Debouncer(duration: const Duration(milliseconds: 100));
      int lastValue = 0;

      // Rapid succession of calls
      for (int i = 1; i <= 5; i++) {
        debouncer.run(() {
          lastValue = i;
        });
        await Future.delayed(const Duration(milliseconds: 20));
      }

      // Wait for debounce duration
      await Future.delayed(const Duration(milliseconds: 150));

      // Should only execute the last call
      expect(lastValue, equals(5));

      debouncer.dispose();
    });

    test('should cancel pending action', () async {
      final debouncer = Debouncer(duration: const Duration(milliseconds: 100));
      int callCount = 0;

      debouncer.run(() {
        callCount++;
      });

      // Cancel before execution
      debouncer.cancel();

      // Wait for duration
      await Future.delayed(const Duration(milliseconds: 150));

      // Should not have executed
      expect(callCount, equals(0));

      debouncer.dispose();
    });

    test('should dispose and cancel pending actions', () async {
      final debouncer = Debouncer(duration: const Duration(milliseconds: 100));
      int callCount = 0;

      debouncer.run(() {
        callCount++;
      });

      // Dispose immediately
      debouncer.dispose();

      // Wait for duration
      await Future.delayed(const Duration(milliseconds: 150));

      // Should not have executed
      expect(callCount, equals(0));
    });
  });

  group('Throttler', () {
    test('should execute immediately on first call', () {
      final throttler = Throttler(duration: const Duration(milliseconds: 100));
      int callCount = 0;

      final executed = throttler.run(() {
        callCount++;
      });

      expect(executed, isTrue);
      expect(callCount, equals(1));
    });

    test('should throttle subsequent calls within duration', () async {
      final throttler = Throttler(duration: const Duration(milliseconds: 100));
      int callCount = 0;

      // First call - should execute
      throttler.run(() {
        callCount++;
      });

      expect(callCount, equals(1));

      // Second call immediately - should be throttled
      final executed = throttler.run(() {
        callCount++;
      });

      expect(executed, isFalse);
      expect(callCount, equals(1));

      // Wait for duration to elapse
      await Future.delayed(const Duration(milliseconds: 150));

      // Third call - should execute
      final executed2 = throttler.run(() {
        callCount++;
      });

      expect(executed2, isTrue);
      expect(callCount, equals(2));
    });

    test('should allow execution after duration elapses', () async {
      final throttler = Throttler(duration: const Duration(milliseconds: 100));
      int callCount = 0;

      // First call
      throttler.run(() {
        callCount++;
      });

      // Wait for duration
      await Future.delayed(const Duration(milliseconds: 150));

      // Second call - should execute
      throttler.run(() {
        callCount++;
      });

      expect(callCount, equals(2));
    });

    test('should reset throttler state', () async {
      final throttler = Throttler(duration: const Duration(milliseconds: 100));
      int callCount = 0;

      // First call
      throttler.run(() {
        callCount++;
      });

      expect(callCount, equals(1));

      // Reset immediately
      throttler.reset();

      // Second call - should execute because state was reset
      throttler.run(() {
        callCount++;
      });

      expect(callCount, equals(2));
    });

    test('should handle rapid calls correctly', () async {
      final throttler = Throttler(duration: const Duration(milliseconds: 100));
      int callCount = 0;

      // Rapid succession of calls
      for (int i = 0; i < 10; i++) {
        throttler.run(() {
          callCount++;
        });
        await Future.delayed(const Duration(milliseconds: 20));
      }

      // Only first call should execute (200ms total < 100ms + 100ms)
      expect(callCount, equals(1));

      // Wait for throttle duration
      await Future.delayed(const Duration(milliseconds: 100));

      // Next call should execute
      throttler.run(() {
        callCount++;
      });

      expect(callCount, equals(2));
    });
  });
}
