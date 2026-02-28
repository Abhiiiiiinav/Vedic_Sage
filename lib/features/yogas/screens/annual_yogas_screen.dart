import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/astro_background.dart';
import '../../../core/services/special_days_service.dart';
import '../../../core/models/yoga_models.dart';
import '../../../core/database/hive_database_service.dart';
import '../widgets/yoga_card.dart';

/// Screen displaying an annual list view of all special yoga days
/// 
/// Shows all special days for an entire year, grouped by month with
/// section headers. Includes filtering by yoga type and search
/// functionality for specific dates.
class AnnualYogasScreen extends StatefulWidget {
  const AnnualYogasScreen({super.key});

  @override
  State<AnnualYogasScreen> createState() => _AnnualYogasScreenState();
}

class _AnnualYogasScreenState extends State<AnnualYogasScreen> {
  int _selectedYear = DateTime.now().year;
  Map<DateTime, List<YogaResult>>? _annualYogas;
  bool _isLoading = true;
  String? _errorMessage;
  
  // Location data from user profile
  double _latitude = 28.6139; // Default to Delhi
  double _longitude = 77.2090;
  double _timezone = 5.5;
  String _locationName = 'Delhi, India';
  
  // Filtering state
  Set<YogaType> _selectedYogaTypes = {};
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  
  final SpecialDaysService _specialDaysService = SpecialDaysService();
  final HiveDatabaseService _db = HiveDatabaseService();

  @override
  void initState() {
    super.initState();
    _loadUserLocation();
    _fetchAnnualYogas();
  }

  @override
  void dispose() {
    _searchController.dispose();
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

  /// Fetch yogas for the selected year
  Future<void> _fetchAnnualYogas() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final yogas = await _specialDaysService.getSpecialDaysForYear(
        year: _selectedYear,
        latitude: _latitude,
        longitude: _longitude,
        timezone: _timezone,
      );
      
      setState(() {
        _annualYogas = yogas;
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
      return 'Selected year is out of valid range. Please choose a year between 1900 and 2100.';
    } else if (error.contains('panchang')) {
      return 'Unable to calculate astrological data for this year. Please try a different year.';
    } else if (error.contains('network') || error.contains('connection')) {
      return 'Network connection error. Please check your internet connection and try again.';
    } else if (error.contains('timeout')) {
      return 'Request timed out. This may take a while for annual data. Please try again.';
    } else {
      return 'Unable to load annual yogas. Please try again or select a different year.';
    }
  }

  /// Navigate to previous year
  void _previousYear() {
    setState(() {
      _selectedYear--;
    });
    _fetchAnnualYogas();
  }

  /// Navigate to next year
  void _nextYear() {
    setState(() {
      _selectedYear++;
    });
    _fetchAnnualYogas();
  }

  /// Toggle yoga type filter
  void _toggleYogaTypeFilter(YogaType type) {
    setState(() {
      if (_selectedYogaTypes.contains(type)) {
        _selectedYogaTypes.remove(type);
      } else {
        _selectedYogaTypes.add(type);
      }
    });
  }

  /// Clear all filters
  void _clearFilters() {
    setState(() {
      _selectedYogaTypes.clear();
      _searchQuery = '';
      _searchController.clear();
    });
  }

  /// Get filtered and grouped yogas
  Map<int, List<MapEntry<DateTime, List<YogaResult>>>> _getFilteredGroupedYogas() {
    if (_annualYogas == null) return {};
    
    // Filter by yoga type
    var filteredYogas = _annualYogas!.entries.where((entry) {
      if (_selectedYogaTypes.isEmpty) return true;
      
      return entry.value.any((yoga) => _selectedYogaTypes.contains(yoga.type));
    }).toList();
    
    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filteredYogas = filteredYogas.where((entry) {
        final dateStr = DateFormat('MMMM d, yyyy').format(entry.key).toLowerCase();
        final weekdayStr = DateFormat('EEEE').format(entry.key).toLowerCase();
        final yogaNames = entry.value.map((y) => y.definition.name.toLowerCase()).join(' ');
        
        final query = _searchQuery.toLowerCase();
        return dateStr.contains(query) || 
               weekdayStr.contains(query) || 
               yogaNames.contains(query);
      }).toList();
    }
    
    // Group by month
    final grouped = <int, List<MapEntry<DateTime, List<YogaResult>>>>{};
    for (final entry in filteredYogas) {
      final month = entry.key.month;
      grouped.putIfAbsent(month, () => []).add(entry);
    }
    
    return grouped;
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
              _buildYearSelector(),
              _buildLocationInfo(),
              _buildSearchBar(),
              _buildFilterChips(),
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
                Expanded(child: _buildYogasList()),
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
              Icons.event_note,
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
                  'Annual Yogas',
                  style: AstroTheme.headingMedium,
                ),
                Text(
                  'Special Days List',
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

  /// Build year selector with navigation
  Widget _buildYearSelector() {
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
              onPressed: _previousYear,
              icon: const Icon(
                Icons.chevron_left,
                color: AstroTheme.accentGold,
              ),
            ),
            Text(
              _selectedYear.toString(),
              style: const TextStyle(
                color: AstroTheme.accentGold,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              onPressed: _nextYear,
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
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
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

  /// Build search bar
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search by date, weekday, or yoga name...',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
          prefixIcon: Icon(
            Icons.search,
            color: AstroTheme.accentCyan.withOpacity(0.7),
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white54),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                      _searchController.clear();
                    });
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: AstroTheme.accentCyan.withOpacity(0.3),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: AstroTheme.accentCyan.withOpacity(0.3),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: AstroTheme.accentCyan,
            ),
          ),
        ),
      ),
    );
  }

  /// Build filter chips for yoga types
  Widget _buildFilterChips() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip(
                  'All',
                  _selectedYogaTypes.isEmpty,
                  () => _clearFilters(),
                  AstroTheme.accentGold,
                ),
                const SizedBox(width: 8),
                ...YogaType.values.map((type) {
                  final definition = YogaDefinitions.getDefinition(type);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildFilterChip(
                      _getYogaTypeShortName(type),
                      _selectedYogaTypes.contains(type),
                      () => _toggleYogaTypeFilter(type),
                      definition.isAuspicious ? Colors.green : Colors.red,
                    ),
                  );
                }),
              ],
            ),
          ),
          if (_selectedYogaTypes.isNotEmpty || _searchQuery.isNotEmpty)
            IconButton(
              onPressed: _clearFilters,
              icon: const Icon(
                Icons.filter_alt_off,
                color: Colors.white54,
              ),
              tooltip: 'Clear filters',
            ),
        ],
      ),
    );
  }

  /// Build individual filter chip
  Widget _buildFilterChip(
    String label,
    bool isSelected,
    VoidCallback onTap,
    Color color,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.3) : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.white.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? color : Colors.white.withOpacity(0.7),
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  /// Build yogas list grouped by month
  Widget _buildYogasList() {
    final groupedYogas = _getFilteredGroupedYogas();
    
    if (groupedYogas.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: groupedYogas.length,
      itemBuilder: (context, index) {
        final month = groupedYogas.keys.elementAt(index);
        final entries = groupedYogas[month]!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMonthHeader(month),
            const SizedBox(height: 12),
            ...entries.map((entry) => _buildDayCard(entry)),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  /// Build month section header
  Widget _buildMonthHeader(int month) {
    final monthName = DateFormat('MMMM').format(DateTime(_selectedYear, month));
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AstroTheme.accentPurple.withOpacity(0.3),
            AstroTheme.accentPurple.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AstroTheme.accentPurple.withOpacity(0.4),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_month,
            color: AstroTheme.accentPurple,
            size: 20,
          ),
          const SizedBox(width: 10),
          Text(
            monthName,
            style: const TextStyle(
              color: AstroTheme.accentPurple,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Build day card with date and yogas
  Widget _buildDayCard(MapEntry<DateTime, List<YogaResult>> entry) {
    final date = entry.key;
    final yogas = entry.value;
    
    // Filter yogas if specific types are selected
    final displayYogas = _selectedYogaTypes.isEmpty
        ? yogas
        : yogas.where((y) => _selectedYogaTypes.contains(y.type)).toList();
    
    if (displayYogas.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AstroTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AstroTheme.accentGold.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          // Date header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AstroTheme.accentGold.withOpacity(0.15),
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
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AstroTheme.accentGold.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      date.day.toString(),
                      style: const TextStyle(
                        color: AstroTheme.accentGold,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('EEEE').format(date),
                        style: const TextStyle(
                          color: AstroTheme.accentGold,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        DateFormat('MMMM d, yyyy').format(date),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AstroTheme.accentGold.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${displayYogas.length} ${displayYogas.length == 1 ? 'Yoga' : 'Yogas'}',
                    style: const TextStyle(
                      color: AstroTheme.accentGold,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Yogas list
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: displayYogas.map((yoga) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: YogaCard(yoga: yoga),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// Build empty state
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AstroTheme.accentCyan.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.event_busy,
                color: AstroTheme.accentCyan,
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Special Days Found',
              style: AstroTheme.headingMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              _selectedYogaTypes.isNotEmpty || _searchQuery.isNotEmpty
                  ? 'Try adjusting your filters or search query'
                  : 'No special yoga days found for this year',
              style: AstroTheme.bodyMedium.copyWith(
                color: Colors.white60,
              ),
              textAlign: TextAlign.center,
            ),
            if (_selectedYogaTypes.isNotEmpty || _searchQuery.isNotEmpty) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _clearFilters,
                icon: const Icon(Icons.filter_alt_off),
                label: const Text('CLEAR FILTERS'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AstroTheme.accentCyan,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ],
        ),
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
              'Error Loading Data',
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
              onPressed: _fetchAnnualYogas,
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

  /// Get short name for yoga type
  String _getYogaTypeShortName(YogaType type) {
    switch (type) {
      case YogaType.amritSiddhi:
        return 'Amrit Siddhi';
      case YogaType.siddha:
        return 'Siddha';
      case YogaType.mahasiddhi:
        return 'Mahasiddhi';
      case YogaType.sarvarthaSiddhi:
        return 'Sarvartha';
      case YogaType.guruPushya:
        return 'Guru Pushya';
      case YogaType.raviPushya:
        return 'Ravi Pushya';
      case YogaType.dagdha:
        return 'Dagdha';
      case YogaType.hutashana:
        return 'Hutashana';
      case YogaType.visha:
        return 'Visha';
      case YogaType.vishtiKarana:
        return 'Vishti';
    }
  }
}
