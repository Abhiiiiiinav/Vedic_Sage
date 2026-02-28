import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'panchang_service.dart';
import 'daily_tasks_service.dart';
import 'gamification_service.dart';
import '../stores/profile_store.dart';

/// Pushes app data to native home screen widgets via [home_widget].
///
/// Singleton — call `HomeWidgetService().updateAllWidgets()` after services init.
class HomeWidgetService {
  static final HomeWidgetService _instance = HomeWidgetService._();
  factory HomeWidgetService() => _instance;
  HomeWidgetService._();

  // Android widget provider class names
  static const _panchangWidget = 'PanchangWidgetProvider';
  static const _taskWidget = 'TaskWidgetProvider';
  static const _streakWidget = 'StreakWidgetProvider';
  static const _planetDayWidget = 'PlanetOfDayWidgetProvider';
  static const _auspiciousWidget = 'AuspiciousTimeWidgetProvider';
  static const _levelWidget = 'LevelProgressWidgetProvider';
  static const _birthChartWidget = 'BirthChartWidgetProvider';

  // Planet themes for each Vara lord
  static const _planetThemes = {
    'Sun': 'Authority & Leadership',
    'Moon': 'Emotions & Intuition',
    'Mars': 'Energy & Courage',
    'Mercury': 'Communication & Learning',
    'Jupiter': 'Wisdom & Expansion',
    'Venus': 'Love & Creativity',
    'Saturn': 'Discipline & Karma',
  };

  // Planet emojis
  static const _planetEmojis = {
    'Sun': '☀️',
    'Moon': '🌙',
    'Mars': '♂️',
    'Mercury': '☿️',
    'Jupiter': '♃',
    'Venus': '♀️',
    'Saturn': '♄',
  };

  /// Initialize home_widget (call once at app start).
  Future<void> initialize() async {
    if (kIsWeb) return;
    try {
      debugPrint('🏠 HomeWidgetService initialized');
    } catch (e) {
      debugPrint('⚠️ HomeWidgetService init failed: $e');
    }
  }

  /// Push all widget data at once.
  Future<void> updateAllWidgets() async {
    if (kIsWeb) return;
    try {
      await Future.wait([
        updatePanchangWidget(),
        updateTaskWidget(),
        updateStreakWidget(),
        updatePlanetOfDayWidget(),
        updateAuspiciousTimeWidget(),
        updateLevelProgressWidget(),
        updateBirthChartWidget(),
      ]);
      debugPrint('🏠 All 7 home widgets updated');
    } catch (e) {
      debugPrint('⚠️ Home widget update failed: $e');
    }
  }

  // ═══════════════════════════════════════════════════
  // 1. PANCHANG WIDGET
  // ═══════════════════════════════════════════════════

  Future<void> updatePanchangWidget() async {
    if (kIsWeb) return;
    try {
      final now = DateTime.now();
      final tithi = PanchangService.calculateTithi(now);
      final nakshatra = PanchangService.calculateNakshatra(now);
      final yoga = PanchangService.calculateYoga(now);
      final vara = PanchangService.getVara(now);
      final varaLord = PanchangService.getVaraLord(now);

      await HomeWidget.saveWidgetData<String>('tithi', tithi['name'] ?? '—');
      await HomeWidget.saveWidgetData<String>(
          'nakshatra', nakshatra['name'] ?? '—');
      await HomeWidget.saveWidgetData<String>('yoga', yoga['name'] ?? '—');
      await HomeWidget.saveWidgetData<String>('vara', vara);
      await HomeWidget.saveWidgetData<String>('vara_lord', varaLord);
      await HomeWidget.saveWidgetData<String>(
          'date', '${now.day}/${now.month}/${now.year}');

      await HomeWidget.updateWidget(
        androidName: _panchangWidget,
        qualifiedAndroidName: 'com.astrolearn.astro_learn.$_panchangWidget',
      );
    } catch (e) {
      debugPrint('⚠️ Panchang widget update failed: $e');
    }
  }

  // ═══════════════════════════════════════════════════
  // 2. TASK WIDGET
  // ═══════════════════════════════════════════════════

  Future<void> updateTaskWidget() async {
    if (kIsWeb) return;
    try {
      final service = DailyTasksService();
      final tasks = service.tasks;
      final completed = tasks.where((t) => t.isCompleted).length;
      final total = tasks.length;

      final incomplete = tasks.where((t) => !t.isCompleted).toList();
      final task1 = incomplete.isNotEmpty ? incomplete[0].title : '—';
      final task2 = incomplete.length > 1 ? incomplete[1].title : '';

      await HomeWidget.saveWidgetData<int>('tasks_completed', completed);
      await HomeWidget.saveWidgetData<int>('tasks_total', total);
      await HomeWidget.saveWidgetData<String>('task_1', task1);
      await HomeWidget.saveWidgetData<String>('task_2', task2);

      await HomeWidget.updateWidget(
        androidName: _taskWidget,
        qualifiedAndroidName: 'com.astrolearn.astro_learn.$_taskWidget',
      );
    } catch (e) {
      debugPrint('⚠️ Task widget update failed: $e');
    }
  }

  // ═══════════════════════════════════════════════════
  // 3. STREAK WIDGET
  // ═══════════════════════════════════════════════════

  Future<void> updateStreakWidget() async {
    if (kIsWeb) return;
    try {
      final gamification = GamificationService();
      await HomeWidget.saveWidgetData<int>(
          'streak', gamification.currentStreak);
      await HomeWidget.saveWidgetData<int>('total_xp', gamification.totalXP);
      await HomeWidget.saveWidgetData<int>('level', gamification.currentLevel);

      await HomeWidget.updateWidget(
        androidName: _streakWidget,
        qualifiedAndroidName: 'com.astrolearn.astro_learn.$_streakWidget',
      );
    } catch (e) {
      debugPrint('⚠️ Streak widget update failed: $e');
    }
  }

  // ═══════════════════════════════════════════════════
  // 4. PLANET OF THE DAY WIDGET
  // ═══════════════════════════════════════════════════

  Future<void> updatePlanetOfDayWidget() async {
    if (kIsWeb) return;
    try {
      final now = DateTime.now();
      final varaLord = PanchangService.getVaraLord(now);
      final theme = _planetThemes[varaLord] ?? 'Cosmic Energy';
      final emoji = _planetEmojis[varaLord] ?? '🪐';

      await HomeWidget.saveWidgetData<String>('pod_planet', varaLord);
      await HomeWidget.saveWidgetData<String>('pod_theme', theme);
      await HomeWidget.saveWidgetData<String>('pod_emoji', emoji);

      await HomeWidget.updateWidget(
        androidName: _planetDayWidget,
        qualifiedAndroidName: 'com.astrolearn.astro_learn.$_planetDayWidget',
      );
    } catch (e) {
      debugPrint('⚠️ Planet of Day widget update failed: $e');
    }
  }

  // ═══════════════════════════════════════════════════
  // 5. AUSPICIOUS TIME WIDGET
  // ═══════════════════════════════════════════════════

  Future<void> updateAuspiciousTimeWidget() async {
    if (kIsWeb) return;
    try {
      final now = DateTime.now();
      final sunrise = PanchangService.calculateSunrise(
        date: now,
        latitude: 28.6,
        longitude: 77.2,
        timezone: 5.5,
      );
      final sunset = PanchangService.calculateSunset(
        date: now,
        latitude: 28.6,
        longitude: 77.2,
        timezone: 5.5,
      );
      final abhijit = PanchangService.calculateAbhijitMuhurta(
        sunrise: sunrise,
        sunset: sunset,
      );
      final yoga = PanchangService.calculateYoga(now);
      final karana = PanchangService.calculateKarana(now);

      await HomeWidget.saveWidgetData<String>(
          'ausp_time', '${abhijit['start']} – ${abhijit['end']}');
      await HomeWidget.saveWidgetData<String>('ausp_yoga', yoga['name'] ?? '—');
      await HomeWidget.saveWidgetData<String>(
          'ausp_karana', karana['name'] ?? '—');

      await HomeWidget.updateWidget(
        androidName: _auspiciousWidget,
        qualifiedAndroidName: 'com.astrolearn.astro_learn.$_auspiciousWidget',
      );
    } catch (e) {
      debugPrint('⚠️ Auspicious Time widget update failed: $e');
    }
  }

  // ═══════════════════════════════════════════════════
  // 6. LEVEL PROGRESS WIDGET
  // ═══════════════════════════════════════════════════

  Future<void> updateLevelProgressWidget() async {
    if (kIsWeb) return;
    try {
      final g = GamificationService();
      final level = g.currentLevel;
      final xpCurrent = g.xpInCurrentLevel;
      final xpNeeded = g.xpForNextLevel;
      final chapters = g.completedChapterCount;
      final progressPercent = xpNeeded > 0 ? (xpCurrent * 100) ~/ xpNeeded : 0;

      await HomeWidget.saveWidgetData<int>('lp_level', level);
      await HomeWidget.saveWidgetData<int>('lp_xp_current', xpCurrent);
      await HomeWidget.saveWidgetData<int>('lp_xp_needed', xpNeeded);
      await HomeWidget.saveWidgetData<int>('lp_progress', progressPercent);
      await HomeWidget.saveWidgetData<int>('lp_chapters', chapters);

      await HomeWidget.updateWidget(
        androidName: _levelWidget,
        qualifiedAndroidName: 'com.astrolearn.astro_learn.$_levelWidget',
      );
    } catch (e) {
      debugPrint('⚠️ Level Progress widget update failed: $e');
    }
  }

  // ═══════════════════════════════════════════════════
  // 7. BIRTH CHART SNAPSHOT WIDGET
  // ═══════════════════════════════════════════════════

  Future<void> updateBirthChartWidget() async {
    if (kIsWeb) return;
    try {
      final store = ProfileStore();
      if (!store.isLoaded) {
        await HomeWidget.saveWidgetData<String>('bc_name', 'No chart loaded');
        await HomeWidget.saveWidgetData<String>('bc_lagna', '—');
        await HomeWidget.saveWidgetData<String>('bc_charts', '');
      } else {
        final summary = store.getChartSummary();
        final name = summary['userName'] ?? 'Explorer';
        final ascendant = summary['ascendant'] ?? '—';
        final chartCount = (summary['chartsLoaded'] ?? 0) as int;

        await HomeWidget.saveWidgetData<String>('bc_name', name);
        await HomeWidget.saveWidgetData<String>(
            'bc_lagna', 'Lagna: $ascendant');
        await HomeWidget.saveWidgetData<String>(
            'bc_charts', '$chartCount charts loaded');
      }

      await HomeWidget.updateWidget(
        androidName: _birthChartWidget,
        qualifiedAndroidName: 'com.astrolearn.astro_learn.$_birthChartWidget',
      );
    } catch (e) {
      debugPrint('⚠️ Birth Chart widget update failed: $e');
    }
  }
}
