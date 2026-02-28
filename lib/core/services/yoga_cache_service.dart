import '../models/yoga_models.dart';

/// Service for caching yoga detection results
/// 
/// This service provides an in-memory cache to avoid recalculating
/// yoga detections for the same date and location. Cache keys are
/// based on date, latitude, longitude, and timezone.
class YogaCacheService {
  // Singleton pattern
  static final YogaCacheService _instance = YogaCacheService._internal();
  factory YogaCacheService() => _instance;
  YogaCacheService._internal();

  // Cache storage: key -> (results, timestamp)
  final Map<String, _CacheEntry> _cache = {};
  
  // Cache configuration
  static const int _maxCacheSize = 100; // Maximum number of cached entries
  static const Duration _cacheExpiry = Duration(hours: 24); // Cache validity period

  /// Generate cache key from parameters
  String _generateKey({
    required DateTime date,
    required double latitude,
    required double longitude,
    required double timezone,
  }) {
    // Normalize date to midnight for consistent keys
    final normalizedDate = DateTime(date.year, date.month, date.day);
    
    // Round coordinates to 4 decimal places (~11m precision)
    final lat = latitude.toStringAsFixed(4);
    final lon = longitude.toStringAsFixed(4);
    final tz = timezone.toStringAsFixed(1);
    
    return '${normalizedDate.millisecondsSinceEpoch}_${lat}_${lon}_$tz';
  }

  /// Get cached yoga results if available and not expired
  /// 
  /// Returns null if cache miss, expired, or error occurs
  List<YogaResult>? get({
    required DateTime date,
    required double latitude,
    required double longitude,
    required double timezone,
  }) {
    try {
      final key = _generateKey(
        date: date,
        latitude: latitude,
        longitude: longitude,
        timezone: timezone,
      );
      
      final entry = _cache[key];
      if (entry == null) return null;
      
      // Check if cache entry has expired
      final now = DateTime.now();
      if (now.difference(entry.timestamp) > _cacheExpiry) {
        _cache.remove(key);
        return null;
      }
      
      return entry.results;
    } catch (e) {
      print('Cache get error: $e');
      return null;
    }
  }

  /// Store yoga results in cache
  /// 
  /// Silently fails if error occurs (cache is optional)
  void put({
    required DateTime date,
    required double latitude,
    required double longitude,
    required double timezone,
    required List<YogaResult> results,
  }) {
    try {
      final key = _generateKey(
        date: date,
        latitude: latitude,
        longitude: longitude,
        timezone: timezone,
      );
      
      // Enforce cache size limit using LRU strategy
      if (_cache.length >= _maxCacheSize && !_cache.containsKey(key)) {
        _evictOldestEntry();
      }
      
      _cache[key] = _CacheEntry(
        results: results,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      print('Cache put error: $e');
      // Silently fail - cache is optional
    }
  }

  /// Evict the oldest cache entry (LRU)
  void _evictOldestEntry() {
    if (_cache.isEmpty) return;
    
    String? oldestKey;
    DateTime? oldestTime;
    
    for (final entry in _cache.entries) {
      if (oldestTime == null || entry.value.timestamp.isBefore(oldestTime)) {
        oldestTime = entry.value.timestamp;
        oldestKey = entry.key;
      }
    }
    
    if (oldestKey != null) {
      _cache.remove(oldestKey);
    }
  }

  /// Clear all cached entries
  void clear() {
    try {
      _cache.clear();
    } catch (e) {
      print('Cache clear error: $e');
    }
  }

  /// Clear expired entries
  void clearExpired() {
    try {
      final now = DateTime.now();
      final expiredKeys = <String>[];
      
      for (final entry in _cache.entries) {
        if (now.difference(entry.value.timestamp) > _cacheExpiry) {
          expiredKeys.add(entry.key);
        }
      }
      
      for (final key in expiredKeys) {
        _cache.remove(key);
      }
    } catch (e) {
      print('Cache clearExpired error: $e');
    }
  }

  /// Get cache statistics
  CacheStats getStats() {
    return CacheStats(
      size: _cache.length,
      maxSize: _maxCacheSize,
      expiryDuration: _cacheExpiry,
    );
  }

  /// Preload cache with multiple dates (for batch operations)
  /// 
  /// This method allows batch loading of cache entries, useful when
  /// you have already computed results for multiple dates and want
  /// to store them all at once.
  /// 
  /// Silently fails on errors (cache is optional)
  void preloadBatch({
    required Map<DateTime, List<YogaResult>> results,
    required double latitude,
    required double longitude,
    required double timezone,
  }) {
    try {
      for (final entry in results.entries) {
        put(
          date: entry.key,
          latitude: latitude,
          longitude: longitude,
          timezone: timezone,
          results: entry.value,
        );
      }
    } catch (e) {
      print('Cache preloadBatch error: $e');
    }
  }
}

/// Cache entry with timestamp
class _CacheEntry {
  final List<YogaResult> results;
  final DateTime timestamp;

  _CacheEntry({
    required this.results,
    required this.timestamp,
  });
}

/// Cache statistics
class CacheStats {
  final int size;
  final int maxSize;
  final Duration expiryDuration;

  CacheStats({
    required this.size,
    required this.maxSize,
    required this.expiryDuration,
  });

  double get utilizationPercent => (size / maxSize) * 100;
}
