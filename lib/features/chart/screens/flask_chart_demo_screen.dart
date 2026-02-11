import 'package:flutter/material.dart';
import '../widgets/svg_chart_viewer.dart';
import '../../../core/services/chart_api_service.dart';

/// Demo screen to test the Flask backend + Free Astrology API integration
class FlaskChartDemoScreen extends StatefulWidget {
  const FlaskChartDemoScreen({super.key});

  @override
  State<FlaskChartDemoScreen> createState() => _FlaskChartDemoScreenState();
}

class _FlaskChartDemoScreenState extends State<FlaskChartDemoScreen> {
  // Birth details form
  DateTime _selectedDate = DateTime(2003, 11, 22);
  TimeOfDay _selectedTime = const TimeOfDay(hour: 13, minute: 30);
  double _latitude = 14.8200;
  double _longitude = 74.1359;
  double _timezone = 5.5;
  
  // Selected chart
  DivisionalChart _selectedChart = DivisionalChart.d1;
  
  // Controllers
  final _latController = TextEditingController(text: '14.8200');
  final _lonController = TextEditingController(text: '74.1359');
  final _tzController = TextEditingController(text: '5.5');

  // Key to force rebuild of chart viewer
  int _chartKey = 0;

  BirthDetails get _birthDetails => BirthDetails(
    year: _selectedDate.year,
    month: _selectedDate.month,
    date: _selectedDate.day,
    hours: _selectedTime.hour,
    minutes: _selectedTime.minute,
    seconds: 0,
    latitude: _latitude,
    longitude: _longitude,
    timezone: _timezone,
  );

  @override
  void dispose() {
    _latController.dispose();
    _lonController.dispose();
    _tzController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        title: const Text(
          'Kundali Chart Generator',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF16213e),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInfoDialog,
            tooltip: 'API Info',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildServerStatus(),
            const SizedBox(height: 16),
            _buildBirthDetailsCard(),
            const SizedBox(height: 16),
            _buildChartSelector(),
            const SizedBox(height: 24),
            _buildSingleChartSection(),
            const SizedBox(height: 32),
            _buildMultipleChartsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildServerStatus() {
    return FutureBuilder<bool>(
      future: ChartApiService().healthCheck(),
      builder: (context, snapshot) {
        final isRunning = snapshot.data ?? false;
        final isLoading = snapshot.connectionState == ConnectionState.waiting;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isLoading
                  ? [Colors.grey.withOpacity(0.2), Colors.grey.withOpacity(0.1)]
                  : isRunning
                      ? [Colors.green.withOpacity(0.2), Colors.green.withOpacity(0.1)]
                      : [Colors.red.withOpacity(0.2), Colors.red.withOpacity(0.1)],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isLoading
                  ? Colors.grey.withOpacity(0.3)
                  : isRunning
                      ? Colors.green.withOpacity(0.5)
                      : Colors.red.withOpacity(0.5),
            ),
          ),
          child: Row(
            children: [
              Icon(
                isLoading
                    ? Icons.hourglass_empty
                    : isRunning
                        ? Icons.check_circle
                        : Icons.error_outline,
                color: isLoading
                    ? Colors.grey
                    : isRunning
                        ? Colors.green
                        : Colors.red,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isLoading
                          ? 'Checking server...'
                          : isRunning
                              ? 'Flask Server + Free Astrology API'
                              : 'Flask Server Not Running',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      isRunning
                          ? 'Connected to chart generation service'
                          : 'Run: python backend/app.py',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                        fontFamily: isRunning ? null : 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLoading)
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white70),
                  onPressed: () => setState(() {}),
                  tooltip: 'Refresh',
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBirthDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16213e),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF9D4EDD).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person, color: Color(0xFF9D4EDD), size: 20),
              const SizedBox(width: 8),
              const Text(
                'Birth Details',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _generateChart,
                icon: const Icon(Icons.auto_graph, size: 18),
                label: const Text('Generate'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF9D4EDD),
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white24),
          const SizedBox(height: 8),
          
          // Date and Time Row
          Row(
            children: [
              Expanded(
                child: _buildInfoTile(
                  'Date',
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  Icons.calendar_today,
                  onTap: _selectDate,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoTile(
                  'Time',
                  '${_selectedTime.hour}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                  Icons.access_time,
                  onTap: _selectTime,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Location Row
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  'Latitude',
                  _latController,
                  (value) {
                    _latitude = double.tryParse(value) ?? _latitude;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  'Longitude',
                  _lonController,
                  (value) {
                    _longitude = double.tryParse(value) ?? _longitude;
                  },
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 80,
                child: _buildTextField(
                  'TZ',
                  _tzController,
                  (value) {
                    _timezone = double.tryParse(value) ?? _timezone;
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          // Quick Location Presets
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _buildLocationChip('Hyderabad', 17.38333, 78.4666),
              _buildLocationChip('Delhi', 28.6139, 77.2090),
              _buildLocationChip('Mumbai', 19.0760, 72.8777),
              _buildLocationChip('Bangalore', 12.9716, 77.5946),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white54, size: 18),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.white54, fontSize: 10),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, Function(String) onChanged) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54, fontSize: 12),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF9D4EDD)),
        ),
      ),
      onChanged: onChanged,
    );
  }

  Widget _buildLocationChip(String name, double lat, double lon) {
    return ActionChip(
      label: Text(name, style: const TextStyle(fontSize: 11)),
      backgroundColor: const Color(0xFF9D4EDD).withOpacity(0.2),
      labelStyle: const TextStyle(color: Colors.white70),
      side: BorderSide(color: const Color(0xFF9D4EDD).withOpacity(0.3)),
      onPressed: () {
        setState(() {
          _latitude = lat;
          _longitude = lon;
          _latController.text = lat.toString();
          _lonController.text = lon.toString();
        });
      },
    );
  }

  Widget _buildChartSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16213e),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Chart',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildChartChip(DivisionalChart.d1),
                _buildChartChip(DivisionalChart.d2),
                _buildChartChip(DivisionalChart.d3),
                _buildChartChip(DivisionalChart.d9),
                _buildChartChip(DivisionalChart.d10),
                _buildChartChip(DivisionalChart.d12),
                _buildChartChip(DivisionalChart.d60),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedChart.description,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildChartChip(DivisionalChart chart) {
    final isSelected = _selectedChart == chart;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(chart.code),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            setState(() {
              _selectedChart = chart;
              _chartKey++;
            });
          }
        },
        selectedColor: const Color(0xFF9D4EDD),
        backgroundColor: Colors.white.withOpacity(0.1),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildSingleChartSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF9D4EDD),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _selectedChart.code,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              _selectedChart.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Center(
          child: SvgChartViewer(
            key: ValueKey('${_selectedChart.code}-$_chartKey'),
            birthDetails: _birthDetails,
            chartType: _selectedChart,
            size: 380,
          ),
        ),
      ],
    );
  }

  Widget _buildMultipleChartsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.grid_view, color: Color(0xFF9D4EDD)),
            SizedBox(width: 8),
            Text(
              'Main Divisional Charts',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'D1 (Rasi) + D9 (Navamsa) + D10 (Dasamsa) - fetched in single API call',
          style: TextStyle(color: Colors.white54, fontSize: 12),
        ),
        const SizedBox(height: 16),
        HorizontalChartViewer(
          key: ValueKey('batch-$_chartKey'),
          birthDetails: _birthDetails,
          charts: const [
            DivisionalChart.d1,
            DivisionalChart.d9,
            DivisionalChart.d10,
          ],
          chartSize: 280,
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF9D4EDD),
              surface: Color(0xFF16213e),
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF9D4EDD),
              surface: Color(0xFF16213e),
            ),
          ),
          child: child!,
        );
      },
    );
    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  void _generateChart() {
    setState(() {
      _chartKey++;
    });
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16213e),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.api, color: Color(0xFF9D4EDD)),
            SizedBox(width: 8),
            Text('API Information', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Architecture',
              style: TextStyle(
                color: Color(0xFF9D4EDD),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Flutter App → Flask Backend → Free Astrology API',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            SizedBox(height: 16),
            Text(
              'Available Charts',
              style: TextStyle(
                color: Color(0xFF9D4EDD),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '• D1 Rasi (Birth Chart)\n'
              '• D2 Hora (Wealth)\n'
              '• D3 Drekkana (Siblings)\n'
              '• D9 Navamsa (Marriage)\n'
              '• D10 Dasamsa (Career)\n'
              '• D12 Dwadasamsa (Parents)\n'
              '• ... and more (D1-D60)',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            SizedBox(height: 16),
            Text(
              'Start Server',
              style: TextStyle(
                color: Color(0xFF9D4EDD),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'cd backend\npython app.py',
              style: TextStyle(
                color: Colors.white70,
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: Color(0xFF9D4EDD)),
            ),
          ),
        ],
      ),
    );
  }
}
