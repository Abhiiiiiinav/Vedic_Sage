import 'dart:async';

/// Utility class for debouncing function calls
/// 
/// Debouncing delays the execution of a function until after a specified
/// duration has elapsed since the last time it was invoked. This is useful
/// for rate-limiting expensive operations like API calls or calculations
/// triggered by user input.
/// 
/// Example usage:
/// ```dart
/// final debouncer = Debouncer(duration: Duration(milliseconds: 500));
/// 
/// // In a text field's onChanged callback:
/// debouncer.run(() {
///   performExpensiveSearch(query);
/// });
/// ```
class Debouncer {
  final Duration duration;
  Timer? _timer;

  Debouncer({required this.duration});

  /// Run the given action after the debounce duration
  /// 
  /// If this method is called again before the duration elapses,
  /// the previous timer is cancelled and a new one is started.
  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }

  /// Cancel any pending debounced action
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// Dispose of the debouncer and cancel any pending actions
  void dispose() {
    cancel();
  }
}

/// Throttler - limits function execution to once per duration
/// 
/// Unlike debouncing, throttling ensures the function is called at most
/// once per specified duration, regardless of how many times it's triggered.
/// The first call executes immediately, and subsequent calls within the
/// duration are ignored.
/// 
/// Example usage:
/// ```dart
/// final throttler = Throttler(duration: Duration(milliseconds: 1000));
/// 
/// // In a scroll listener:
/// throttler.run(() {
///   updateScrollPosition();
/// });
/// ```
class Throttler {
  final Duration duration;
  DateTime? _lastExecutionTime;

  Throttler({required this.duration});

  /// Run the given action if enough time has passed since last execution
  /// 
  /// Returns true if the action was executed, false if it was throttled.
  bool run(void Function() action) {
    final now = DateTime.now();
    
    if (_lastExecutionTime == null ||
        now.difference(_lastExecutionTime!) >= duration) {
      _lastExecutionTime = now;
      action();
      return true;
    }
    
    return false;
  }

  /// Reset the throttler state
  void reset() {
    _lastExecutionTime = null;
  }
}
