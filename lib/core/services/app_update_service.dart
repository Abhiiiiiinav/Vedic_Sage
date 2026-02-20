import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Service to check GitHub for app updates by comparing commit SHAs.
/// Checks the remote repo for newer commits and caches the result.
class AppUpdateService {
  static final AppUpdateService _instance = AppUpdateService._();
  factory AppUpdateService() => _instance;
  AppUpdateService._();

  // ── Config ──
  static const String _owner = 'Abhiiiiiinav';
  static const String _repo = 'Vedic_Sage';
  static const String _branch = 'main';
  static const String _apiUrl =
      'https://api.github.com/repos/$_owner/$_repo/commits/$_branch';

  // ── Cache keys ──
  static const String _keyLastKnownSha = 'update_last_known_sha';
  static const String _keyLastCheckTime = 'update_last_check_time';
  static const String _keyUpdateAvailable = 'update_available';
  static const String _keyLatestMessage = 'update_latest_message';
  static const String _keyLatestSha = 'update_latest_sha';
  static const String _keyLatestDate = 'update_latest_date';

  SharedPreferences? _prefs;

  /// Initialize — call once at app start
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// The SHA the user last acknowledged (or the SHA at install time)
  String? get lastKnownSha => _prefs?.getString(_keyLastKnownSha);

  /// Whether an update is available (cached)
  bool get isUpdateAvailable => _prefs?.getBool(_keyUpdateAvailable) ?? false;

  /// Latest commit message from GitHub
  String get latestMessage =>
      _prefs?.getString(_keyLatestMessage) ?? 'No updates checked yet';

  /// Latest commit SHA (short)
  String get latestSha => _prefs?.getString(_keyLatestSha) ?? '';

  /// Latest commit date
  String get latestDate => _prefs?.getString(_keyLatestDate) ?? '';

  /// Time of last check
  DateTime? get lastCheckTime {
    final ms = _prefs?.getInt(_keyLastCheckTime);
    return ms != null ? DateTime.fromMillisecondsSinceEpoch(ms) : null;
  }

  /// Check GitHub for the latest commit on main branch.
  /// Returns an [UpdateCheckResult] with details.
  Future<UpdateCheckResult> checkForUpdates() async {
    await initialize();

    try {
      final response = await http.get(
        Uri.parse(_apiUrl),
        headers: {
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': 'AstroLearn-App',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        return UpdateCheckResult(
          success: false,
          error: 'GitHub API returned ${response.statusCode}',
        );
      }

      final data = jsonDecode(response.body);
      final remoteSha = data['sha'] as String;
      final commitMessage = data['commit']?['message'] as String? ?? '';
      final commitDate = data['commit']?['committer']?['date'] as String? ?? '';
      final shortSha = remoteSha.substring(0, 7);

      // Parse commit date for display
      String formattedDate = '';
      try {
        final dt = DateTime.parse(commitDate);
        final months = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec'
        ];
        formattedDate =
            '${months[dt.month - 1]} ${dt.day}, ${dt.year} at ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
      } catch (_) {
        formattedDate = commitDate;
      }

      // Compare with last known SHA
      final currentSha = lastKnownSha;
      final hasUpdate = currentSha != null && currentSha != remoteSha;

      // If this is the first check, set the current SHA as baseline
      if (currentSha == null) {
        await _prefs?.setString(_keyLastKnownSha, remoteSha);
      }

      // Cache results
      await _prefs?.setBool(_keyUpdateAvailable, hasUpdate);
      await _prefs?.setString(_keyLatestMessage, _firstLine(commitMessage));
      await _prefs?.setString(_keyLatestSha, shortSha);
      await _prefs?.setString(_keyLatestDate, formattedDate);
      await _prefs?.setInt(
          _keyLastCheckTime, DateTime.now().millisecondsSinceEpoch);

      return UpdateCheckResult(
        success: true,
        hasUpdate: hasUpdate,
        currentSha: currentSha?.substring(0, 7) ?? shortSha,
        latestSha: shortSha,
        commitMessage: _firstLine(commitMessage),
        commitDate: formattedDate,
      );
    } on SocketException {
      return UpdateCheckResult(
        success: false,
        error: 'No internet connection. Connect to Internet and try again.',
      );
    } on TimeoutException {
      return UpdateCheckResult(
        success: false,
        error: 'Connection timed out. Please try again.',
      );
    } catch (e) {
      return UpdateCheckResult(
        success: false,
        error: 'Update check failed. Please try later.',
      );
    }
  }

  /// Mark the latest SHA as acknowledged (user "updated")
  Future<void> acknowledgeUpdate() async {
    await initialize();
    // Clear the update flag — next check will use new baseline
    await _prefs?.setBool(_keyUpdateAvailable, false);

    // Use the full latest SHA if we can reconstruct it
    // Instead, just mark current as latest by doing a fresh check
    try {
      final response = await http.get(
        Uri.parse(_apiUrl),
        headers: {
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': 'AstroLearn-App',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _prefs?.setString(_keyLastKnownSha, data['sha'] as String);
      }
    } catch (_) {
      // Silent fail — update flag is already cleared
    }
  }

  /// Get the first line of a commit message
  String _firstLine(String message) {
    final lines = message.split('\n');
    return lines.first.trim();
  }

  /// How long ago was the last check
  String get timeSinceLastCheck {
    final last = lastCheckTime;
    if (last == null) return 'Never checked';

    final diff = DateTime.now().difference(last);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

/// Result of an update check
class UpdateCheckResult {
  final bool success;
  final bool hasUpdate;
  final String? currentSha;
  final String? latestSha;
  final String? commitMessage;
  final String? commitDate;
  final String? error;

  const UpdateCheckResult({
    required this.success,
    this.hasUpdate = false,
    this.currentSha,
    this.latestSha,
    this.commitMessage,
    this.commitDate,
    this.error,
  });
}
