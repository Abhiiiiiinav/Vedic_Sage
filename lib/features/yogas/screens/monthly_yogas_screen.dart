import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/astro_background.dart';
import '../../../core/services/special_days_service.dart';
import '../../../core/models/yoga_models.dart';
import '../../../core/database/hive_database_service.dart';
import '../widgets/yoga_card.dart';
import '../widgets/yoga_date_cell.dart';

/// Screen displaying a monthly calendar view of special yoga days
class MonthlyYogasScreen extends StatefulWidget {
  const MonthlyYogasScreen({super.key});

  @override
  State<MonthlyYogasScreen> createState() => _MonthlyYogasScreenState();
}

class _MonthlyYogasScreenState extends State<MonthlyYogasScreen> {
  DateTime _selectedMonth = DateTime.now();
  DateTime? _selectedDate;
  Map<DateTime, List<YogaResult>>? _monthlyYogas;
  bool _isLoading = true;
  String? _errorMessage;
  
  // Location data from user profile
  double _latitude = 28.6139; // Default to Delhi
  double _longitude = 77.2090;
  double _timezone = 5.5;
  String _locationName = 'Delhi, India';
  
  final SpecialDaysService _specialDaysService = SpecialDaysService();
  final HiveDatabaseService _db = HiveDatabaseService();

  @override
  void initState() {
    super.initState();
    _loadUserLocation();
    _fetchMonthlyYogas();
  }

  /// Load user's location from their profile
  void _loadUserLocation() {
    final profile = _db.getPrimaryProfile();
    if (profile != null && 
        profile.latitude != null && 
        profile.longitude != null &&
        profile.timezoneOffset != null) {
      setState(() {
        _latitude = profile.latitude!;
        _longitude = profile.longitude!;
        _timezone = profile.timezoneOffset!;
        _locationName = profile.birthPlace ?? 'Current Location';
      });
    }
  }

  /// Fetch yogas for the selected month
  Future<void> _fetchMonthlyYogas() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final yogas = await _specialDaysService.getSpecialDaysForMonth(
        year: _selectedMonth.year,
        month: _selectedMonth.month,
        latitude: _latitude,
        longitude: _longitude,
        timezone: _timezone,
      );
      
      setState(() {
        _monthlyYogas = yogas;
        _isLoading = false;
      });
    } on ArgumentError catch (e) {
      setState(() {
        _errorMessage = _getUserFriendlyErrorMessage(e.toString());
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = _getUserFriendlyErrorMessage(e.toString());
        _isLoading = false;
      });
    }
  }
  
  /// Convert technical error messages to user-friendly ones
  String _getUserFriendlyErrorMessage(String error) {
    if (error.contains('latitude') || error.contains('Latitude')) {
      return 'Invalid location coordinates. Please check your profile settings.';
    } else if (error.contains('longitude') || error.contains('Longitude')) {
      return 'Invalid location coordinates. Please check your profile settings.';
    } else if (error.contains('timezone') || error.contains('Timezone')) {
      return 'Invalid timezone setting. Please check your profile settings.';
    } else if (error.contains('Date must be between')) {
      return 'Selected date is out of valid range. Please choose a date between 1900 and 2100.';
    } else if (error.contains('Month must be between')) {
      return 'Invalid month selected. Please try again.';
    } else if (error.contains('panchang')) {
      return 'Unable to calculate astrological data for this month. Please try a different month.';
    } else if (error.contains('network') || error.contains('connection')) {
      return 'Network connection error. Please check your internet connection and try again.';
    } else if (error.contains('timeout')) {
      return 'Request timed out. Please check your connection and try again.';
    } else {
      return 'Unable to load monthly yogas. Please try again or select a different month.';
    }
  }

  /// Navigate to previous month
  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
      _selectedDate = null;
    });
    _fetchMonthlyYogas();
  }

  /// Navigate to next month
  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
      _selectedDate = null;
    });
    _fetchMonthlyYogas();
  }

  /// Handle date selection
  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  /// Get yogas for a specific date
  List<YogaResult>? _getYogasForDate(DateTime date) {
    if (_monthlyYogas == null) return null;
    
    // Normalize date to midnight for comparison
    final normalizedDate = DateTime(date.year, date.month, date.day);
    return _monthlyYogas![normalizedDate];
  }

  @override
  Widget build(BuildContext context) {
    return AstroBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildMonthSelector(),
              _buildLocationInfo(),
              if (_isLoading)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AstroTheme.accentGold,
                    ),
                  ),
                )
              else if (_errorMessage != null)
                Expanded(child: _buildErrorState())
              else
                Expanded(
                  child: Column(
                    children: [
                      _buildCalendarGrid(),
                      if (_selectedDate != null)
                        Expanded(child: _buildSelectedDateDetails()),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build header with title and back button
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: AstroTheme.primaryGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.calendar_month,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Monthly Yogas',
                  style: AstroTheme.headingMedium,
                ),
                Text(
                  'Special Days Calendar',
                  style: AstroTheme.bodyMedium.copyWith(
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build month selector with navigation
  Widget _buildMonthSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AstroTheme.accentGold.withOpacity(0.2),
              AstroTheme.accentGold.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AstroTheme.accentGold.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: _previousMonth,
              icon: const Icon(
                Icons.chevron_left,
                color: AstroTheme.accentGold,
              ),
            ),
            Text(
              DateFormat('MMMM yyyy').format(_selectedMonth),
              style: const TextStyle(
                color: AstroTheme.accentGold,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              onPressed: _nextMonth,
              icon: const Icon(
                Icons.chevron_right,
                color: AstroTheme.accentGold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build location info
  Widget _buildLocationInfo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Row(
        children: [
          Icon(
            Icons.location_on,
            color: AstroTheme.accentCyan.withOpacity(0.7),
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            _locationName,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  /// Build calendar grid
  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final lastDayOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final firstWeekday = firstDayOfMonth.weekday % 7; // 0 = Sunday, 6 = Saturday

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Weekday headers
          _buildWeekdayHeaders(),
          const SizedBox(height: 8),
          // Calendar grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: firstWeekday + daysInMonth,
            itemBuilder: (context, index) {
              if (index < firstWeekday) {
                // Empty cell before first day
                return const SizedBox.shrink();
              }
              
              final day = index - firstWeekday + 1;
              final date = DateTime(_selectedMonth.year, _selectedMonth.month, day);
              final yogas = _getYogasForDate(date);
              final isSelected = _selectedDate != null &&
                  _selectedDate!.year == date.year &&
                  _selectedDate!.month == date.month &&
                  _selectedDate!.day == date.day;
              final isToday = DateTime.now().year == date.year &&
                  DateTime.now().month == date.month &&
                  DateTime.now().day == date.day;

              return YogaDateCell(
                date: date,
                yogas: yogas,
                isSelected: isSelected,
                isToday: isToday,
                onTap: () => _onDateSelected(date),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Build weekday headers
  Widget _buildWeekdayHeaders() {
    const weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    
    return Row(
      children: weekdays.map((day) => Expanded(
        child: Center(
          child: Text(
            day,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      )).toList(),
    );
  }

  /// Build selected date details
  Widget _buildSelectedDateDetails() {
    if (_selectedDate == null) return const SizedBox.shrink();
    
    final yogas = _getYogasForDate(_selectedDate!);
    if (yogas == null || yogas.isEmpty) return const SizedBox.shrink();

    // Separate auspicious and inauspicious yogas
    final auspiciousYogas = yogas.where((y) => y.isAuspicious).toList();
    final inauspiciousYogas = yogas.where((y) => !y.isAuspicious).toList();

    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AstroTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AstroTheme.accentGold.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AstroTheme.accentGold.withOpacity(0.2),
                  AstroTheme.accentGold.withOpacity(0.05),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: AstroTheme.accentGold,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('EEEE').format(_selectedDate!),
                        style: const TextStyle(
                          color: AstroTheme.accentGold,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        DateFormat('MMMM d, yyyy').format(_selectedDate!),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => _selectedDate = null),
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white54,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
          // Yogas list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (auspiciousYogas.isNotEmpty) ...[
                  _buildSectionHeader(
                    'Auspicious',
                    Icons.check_circle,
                    Colors.green,
                    auspiciousYogas.length,
                  ),
                  const SizedBox(height: 12),
                  ...auspiciousYogas.map((yoga) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: YogaCard(yoga: yoga),
                      )),
                  if (inauspiciousYogas.isNotEmpty)
                    const SizedBox(height: 16),
                ],
                if (inauspiciousYogas.isNotEmpty) ...[
                  _buildSectionHeader(
                    'Inauspicious',
                    Icons.warning,
                    Colors.red,
                    inauspiciousYogas.length,
                  ),
                  const SizedBox(height: 12),
                  ...inauspiciousYogas.map((yoga) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: YogaCard(yoga: yoga),
                      )),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build section header
  Widget _buildSectionHeader(
    String title,
    IconData icon,
    Color color,
    int count,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  /// Build error state
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Error Loading Calendar',
              style: AstroTheme.headingMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? 'An unknown error occurred',
              style: AstroTheme.bodyMedium.copyWith(
                color: Colors.white60,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _fetchMonthlyYogas,
              icon: const Icon(Icons.refresh),
              label: const Text('RETRY'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AstroTheme.accentGold,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
