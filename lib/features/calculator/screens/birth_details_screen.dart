import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/animated_cosmic_background.dart';
import '../../../shared/widgets/astro_card.dart';
import '../../../core/models/birth_details.dart';
import '../../../core/data/indian_cities_data.dart';
import '../../../core/database/hive_database_service.dart';
import '../../chart/screens/chart_loader_screen.dart';

class BirthDetailsScreen extends StatefulWidget {
  const BirthDetailsScreen({super.key});

  @override
  State<BirthDetailsScreen> createState() => _BirthDetailsScreenState();
}

class _BirthDetailsScreenState extends State<BirthDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  DateTime birthDate = DateTime.now();
  TimeOfDay birthTime = TimeOfDay.now();
  bool _isLoading = false;
  CityLocation? _selectedCity;

  @override
  void initState() {
    super.initState();
    // Set default city to Delhi
    _selectedCity = IndianCitiesData.cities.firstWhere(
      (city) => city.name == 'Delhi',
      orElse: () => IndianCitiesData.cities[0],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: birthDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
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
    if (picked != null) {
      setState(() => birthDate = picked);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: birthTime,
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
    if (picked != null) {
      setState(() => birthTime = picked);
    }
  }

  /// ⚡ INSTANT NAVIGATION - Navigate first, load data in background
  void _calculateChart() async {
    if (!_formKey.currentState!.validate()) return;

    // ✅ VALIDATION ONLY (fast checks before navigation)
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a city'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // ⚡ CREATE BIRTH DETAILS (minimal processing - no API calls)
    final birthDateTime = DateTime(
      birthDate.year,
      birthDate.month,
      birthDate.day,
      birthTime.hour,
      birthTime.minute,
    );

    final birthDetails = BirthDetails(
      name: _nameController.text.trim(),
      birthDateTime: birthDateTime,
      latitude: _selectedCity!.latitude,
      longitude: _selectedCity!.longitude,
      cityName: _selectedCity!.name,
      timezoneOffset: _selectedCity!.timezone,
    );

    // 💾 SAVE OR UPDATE PROFILE IN HIVE DATABASE
    final db = HiveDatabaseService();
    
    // Check if a profile with the same name already exists
    final existingProfiles = db.getAllProfiles();
    final existingProfile = existingProfiles.cast<dynamic>().firstWhere(
      (p) => p?.name.toLowerCase() == birthDetails.name.toLowerCase(),
      orElse: () => null,
    );

    if (existingProfile != null) {
      // ✏️ UPDATE existing profile if data has changed
      final hasChanges = 
          existingProfile.birthDateTime != birthDetails.birthDateTime ||
          existingProfile.birthPlace != birthDetails.cityName ||
          existingProfile.latitude != birthDetails.latitude ||
          existingProfile.longitude != birthDetails.longitude ||
          existingProfile.timezoneOffset != birthDetails.timezoneOffset;

      if (hasChanges) {
        await db.updateProfile(
          existingProfile.copyWith(
            birthDateTime: birthDetails.birthDateTime,
            birthPlace: birthDetails.cityName,
            latitude: birthDetails.latitude,
            longitude: birthDetails.longitude,
            timezoneOffset: birthDetails.timezoneOffset,
          ),
        );
        await db.setPrimaryProfile(existingProfile.id);
      }
    } else {
      // 🆕 CREATE new profile
      await db.createProfile(
        name: birthDetails.name,
        birthDateTime: birthDetails.birthDateTime,
        birthPlace: birthDetails.cityName,
        latitude: birthDetails.latitude,
        longitude: birthDetails.longitude,
        timezoneOffset: birthDetails.timezoneOffset,
        isPrimary: true,
      );
    }

    // 🚀 NAVIGATE IMMEDIATELY - No waiting!
    // UI never blocks, user sees instant response
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChartLoaderScreen(
          birthDetails: birthDetails,
          name: _nameController.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background fills the entire screen
          const Positioned.fill(
            child: AnimatedCosmicBackground(
              child: SizedBox.shrink(),
            ),
          ),
          
          // Scrollable content on top
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 30),
                  _buildInputForm(),
                ],
              ),
            ),
          ),

          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black87,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      color: AstroTheme.accentGold,
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Calculating your cosmic blueprint...',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This may take a few seconds',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        const SizedBox(height: 20),
        const Text(
          "Birth Details",
          style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
        ),
        const Text(
          "Reveal your celestial blueprint",
          style: TextStyle(color: Colors.white60, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildInputForm() {
    return AstroCard(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: _inputDecoration('Full Name', Icons.person),
              style: const TextStyle(color: Colors.white),
              validator: (v) => v!.isEmpty ? 'Enter name' : null,
            ),
            const SizedBox(height: 16),
            _pickerTile(
              "Birth Date",
              DateFormat('dd-MM-yyyy').format(birthDate),
              Icons.calendar_month,
              () => _selectDate(context),
            ),
            const SizedBox(height: 16),
            _pickerTile(
              "Birth Time",
              birthTime.format(context),
              Icons.access_time,
              () => _selectTime(context),
            ),
            const SizedBox(height: 16),
            _buildCityDropdown(),
            if (_selectedCity != null) ...[
              const SizedBox(height: 12),
              _buildCoordinatesDisplay(),
            ],
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading ? null : _calculateChart,
              style: ElevatedButton.styleFrom(
                backgroundColor: AstroTheme.accentGold,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 0,
              ),
              child: const Text(
                'GENERATE KUNDALI',
                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pickerTile(String title, String value, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AstroTheme.accentGold),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                  Text(
                    value, 
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.edit, size: 16, color: Colors.white24),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AstroTheme.accentGold, size: 20),
      labelStyle: const TextStyle(color: Colors.white38),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AstroTheme.accentGold),
      ),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
    );
  }

  Widget _buildCityDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_city, color: AstroTheme.accentGold, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<CityLocation>(
                value: _selectedCity,
                hint: const Text(
                  'Select City',
                  style: TextStyle(color: Colors.white38),
                ),
                isExpanded: true,
                dropdownColor: AstroTheme.cardBackground,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white54),
                items: IndianCitiesData.sortedCities.map((city) {
                  return DropdownMenuItem<CityLocation>(
                    value: city,
                    child: Text(
                      city.displayName,
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
                onChanged: (CityLocation? newCity) {
                  setState(() {
                    _selectedCity = newCity;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoordinatesDisplay() {
    if (_selectedCity == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AstroTheme.accentCyan.withOpacity(0.15),
            AstroTheme.accentCyan.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AstroTheme.accentCyan.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AstroTheme.accentCyan.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.my_location,
              color: AstroTheme.accentCyan,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Coordinates',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_selectedCity!.latitude.toStringAsFixed(4)}°N, ${_selectedCity!.longitude.toStringAsFixed(4)}°E',
                  style: const TextStyle(
                    color: AstroTheme.accentCyan,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
