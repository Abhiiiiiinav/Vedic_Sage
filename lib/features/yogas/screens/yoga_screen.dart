import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/astro_background.dart';
import '../../../core/services/yoga_detection_service.dart';
import '../../../core/services/yoga_filter_service.dart';
import '../../../core/models/yoga_models.dart';
import '../../../core/database/hive_database_service.dart';
import '../../../core/utils/debouncer.dart';
import '../widgets/yoga_card.dart';
import '../widgets/purpose_filter_widget.dart';

/// Main screen for displaying Vedic special combinations (yogas)
class YogaScreen extends StatefulWidget {
  const YogaScreen({super.key});

  @override
  State<YogaScreen> createState() => _YogaScreenState();
}

class _YogaScreenState extends State<YogaScreen> {
  DateTime _selectedDate = DateTime.now();
  List<YogaResult>? _yogas;
  List<YogaResult>? _filteredYogas;
  List<YogaPurpose> _selectedPurposes = [];
  bool _isLoading = true;
  String? _errorMessage;
  
  // Location data from user profile
  double _latitude = 28.6139; // Default to Delhi
  double _longitude = 77.2090;
  double _timezone = 5.5;
  String _locationName = 'Delhi, India';
  
  final YogaDetectionService _yogaService = YogaDetectionService();
  final YogaFilterService _filterService = YogaFilterService();
  final HiveDatabaseService _db = HiveDatabaseService();
  
  // Debouncer for date changes (prevents rapid recalculations)
  late final Debouncer _dateChangeDebouncer;

  @override
  void initState() {
    super.initState();
    _dateChangeDebouncer = Debouncer(duration: const Duration(milliseconds: 300));
    _loadUserLocation();
    _fetchYogas();
  }

  @override
  void dispose() {
    _dateChangeDebouncer.dispose();
    super.dispose();
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

  /// Fetch yogas for the selected date and location
  Future<void> _fetchYogas() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final yogas = await _yogaService.detectYogas(
        date: _selectedDate,
        latitude: _latitude,
        longitude: _longitude,
        timezone: _timezone,
      );
      
      setState(() {
        _yogas = yogas;
        _applyFilters();
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
    } else if (error.contains('panchang')) {
      return 'Unable to calculate astrological data for this date and location. Please try a different date.';
    } else if (error.contains('network') || error.contains('connection')) {
      return 'Network connection error. Please check your internet connection and try again.';
    } else if (error.contains('timeout')) {
      return 'Request timed out. Please check your connection and try again.';
    } else {
      return 'Unable to detect yogas. Please try again or select a different date.';
    }
  }

  /// Apply purpose filters to the yoga list
  void _applyFilters() {
    if (_yogas == null) {
      _filteredYogas = null;
      return;
    }

    if (_selectedPurposes.isEmpty) {
      // No filters selected - show all yogas
      _filteredYogas = _yogas;
    } else {
      // Apply purpose filters
      _filteredYogas = _filterService.filterByPurposes(_yogas!, _selectedPurposes);
    }
  }

  /// Handle filter change from purpose filter widget
  void _onFilterChanged(List<YogaPurpose> purposes) {
    setState(() {
      _selectedPurposes = purposes;
      _applyFilters();
    });
  }

  /// Show date picker
  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AstroTheme.accentGold,
              onPrimary: Colors.black,
              surface: AstroTheme.cardBackground,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _isLoading = true; // Show loading immediately
      });
      
      // Debounce the actual fetch to avoid rapid API calls
      _dateChangeDebouncer.run(() {
        _fetchYogas();
      });
    }
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
              _buildDateSelector(),
              _buildLocationInfo(),
              PurposeFilterWidget(
                onFilterChanged: _onFilterChanged,
                initialSelection: _selectedPurposes,
              ),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AstroTheme.accentGold,
                        ),
                      )
                    : _errorMessage != null
                        ? _buildErrorState()
                        : _buildYogasList(),
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
              Icons.auto_awesome,
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
                  'Special Yogas',
                  style: AstroTheme.headingMedium,
                ),
                Text(
                  'Auspicious Combinations',
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

  /// Build date selector
  Widget _buildDateSelector() {
    final isToday = _selectedDate.year == DateTime.now().year &&
        _selectedDate.month == DateTime.now().month &&
        _selectedDate.day == DateTime.now().day;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: InkWell(
        onTap: _selectDate,
        borderRadius: BorderRadius.circular(16),
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
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AstroTheme.accentGold.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.calendar_today,
                  color: AstroTheme.accentGold,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isToday ? 'Today' : DateFormat('EEEE').format(_selectedDate),
                      style: const TextStyle(
                        color: AstroTheme.accentGold,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('MMMM d, yyyy').format(_selectedDate),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_drop_down,
                color: AstroTheme.accentGold.withOpacity(0.7),
              ),
            ],
          ),
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
              'Error Loading Yogas',
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
              onPressed: _fetchYogas,
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

  /// Build yogas list
  Widget _buildYogasList() {
    if (_filteredYogas == null || _filteredYogas!.isEmpty) {
      return _buildEmptyState();
    }

    // Separate auspicious and inauspicious yogas
    final auspiciousYogas = _filteredYogas!.where((y) => y.isAuspicious).toList();
    final inauspiciousYogas = _filteredYogas!.where((y) => !y.isAuspicious).toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (auspiciousYogas.isNotEmpty) ...[
          _buildSectionHeader(
            'Auspicious Yogas',
            Icons.check_circle,
            Colors.green,
            auspiciousYogas.length,
          ),
          const SizedBox(height: 12),
          ...auspiciousYogas.map((yoga) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildYogaCard(yoga),
              )),
          const SizedBox(height: 20),
        ],
        if (inauspiciousYogas.isNotEmpty) ...[
          _buildSectionHeader(
            'Inauspicious Yogas',
            Icons.warning,
            Colors.red,
            inauspiciousYogas.length,
          ),
          const SizedBox(height: 12),
          ...inauspiciousYogas.map((yoga) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildYogaCard(yoga),
              )),
        ],
        const SizedBox(height: 20),
      ],
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
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  /// Build yoga card using YogaCard widget
  Widget _buildYogaCard(YogaResult yoga) {
    return YogaCard(yoga: yoga);
  }

  /// Build empty state
  Widget _buildEmptyState() {
    final hasFilters = _selectedPurposes.isNotEmpty;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AstroTheme.primaryGradient.scale(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasFilters ? Icons.filter_alt_off : Icons.auto_awesome,
                color: AstroTheme.accentGold,
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              hasFilters ? 'No Matching Yogas' : 'No Special Yogas',
              style: AstroTheme.headingMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              hasFilters
                  ? 'There are no yogas matching the selected purposes for this date. Try adjusting your filters or selecting a different date.'
                  : 'There are no special yogas detected for this date. Try selecting a different date.',
              style: AstroTheme.bodyMedium.copyWith(
                color: Colors.white60,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
