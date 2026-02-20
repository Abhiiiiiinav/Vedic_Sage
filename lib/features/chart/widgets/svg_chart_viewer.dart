import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/services/chart_api_service.dart';

/// Helper function to preprocess SVG for crisp rendering
/// Fixes common SVG issues for flutter_svg compatibility
String preprocessSvg(String svg) {
  // Check if viewBox is already present, add if missing
  if (!svg.contains('viewBox')) {
    final widthMatch = RegExp(r'width="(\d+)"').firstMatch(svg);
    final heightMatch = RegExp(r'height="(\d+)"').firstMatch(svg);
    
    if (widthMatch != null && heightMatch != null) {
      final width = widthMatch.group(1);
      final height = heightMatch.group(1);
      
      svg = svg.replaceFirst(
        RegExp(r'<svg\s'),
        '<svg viewBox="0 0 $width $height" ',
      );
    }
  }
  
  // Remove external font imports (flutter_svg doesn't support @import)
  svg = svg.replaceAll(
    RegExp(r"@import url\([^)]+\);"),
    '',
  );
  
  // Remove the entire defs/style block that references external fonts
  svg = svg.replaceAll(
    RegExp(r'<defs><style>.*?</style></defs>', dotAll: true),
    '',
  );
  
  // Fix null opacity values (flutter_svg doesn't handle these)
  svg = svg.replaceAll('fill-opacity="null"', '');
  svg = svg.replaceAll('stroke-opacity="null"', '');
  svg = svg.replaceAll('opacity="null"', '');
  
  // Fix undefined stroke/fill linecap/linejoin
  svg = svg.replaceAll('stroke-linecap="undefined"', '');
  svg = svg.replaceAll('stroke-linecap="null"', '');
  svg = svg.replaceAll('stroke-linejoin="undefined"', '');
  svg = svg.replaceAll('stroke-linejoin="null"', '');
  
  // Replace Roboto font with sans-serif (system font)
  svg = svg.replaceAll('font-family="Roboto"', 'font-family="sans-serif"');
  
  return svg;
}

/// Widget that displays SVG charts from the Free Astrology API via Flask backend
class SvgChartViewer extends StatefulWidget {
  final BirthDetails birthDetails;
  final DivisionalChart chartType;
  final double size;
  final bool showLoading;
  final bool showTitle;

  const SvgChartViewer({
    super.key,
    required this.birthDetails,
    this.chartType = DivisionalChart.d1,
    this.size = 350,
    this.showLoading = true,
    this.showTitle = false,
  });

  @override
  State<SvgChartViewer> createState() => _SvgChartViewerState();
}

class _SvgChartViewerState extends State<SvgChartViewer> {
  final ChartApiService _apiService = ChartApiService();

  String? _svgContent;
  String? _chartName;
  bool _isLoading = true;
  String? _error;
  bool _isServerAvailable = false;

  double get _alignedSize => widget.size.floorToDouble();

  @override
  void initState() {
    super.initState();
    _checkServerAndLoadChart();
  }

  @override
  void didUpdateWidget(SvgChartViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload chart if parameters change
    if (oldWidget.birthDetails != widget.birthDetails ||
        oldWidget.chartType != widget.chartType) {
      _loadChart();
    }
  }

  Future<void> _checkServerAndLoadChart() async {
    final isAvailable = await _apiService.healthCheck();
    setState(() {
      _isServerAvailable = isAvailable;
    });

    if (isAvailable) {
      await _loadChart();
    } else {
      setState(() {
        _isLoading = false;
        _error = 'Chart server is not running.\n'
            'Start with: python backend/app.py';
      });
    }
  }

  Future<void> _loadChart() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final response = await _apiService.getChartByDivision(
      widget.birthDetails,
      int.parse(widget.chartType.code.substring(1)), // Extract number from "D9"
    );

    if (!mounted) return;
    
    setState(() {
      _isLoading = false;
      if (response.success && response.svg != null) {
        _svgContent = response.svg;
        _chartName = response.name ?? widget.chartType.name;
      } else {
        _error = response.error ?? 'Failed to generate chart';
      }
    });
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showTitle && _chartName != null) ...[
          Text(
            _chartName!,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (_isLoading && widget.showLoading)
          _buildLoadingState()
        else if (_error != null)
          _buildErrorState()
        else if (_svgContent != null)
          _buildChartView()
        else
          const SizedBox.shrink(),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Container(
      width: _alignedSize,
      height: _alignedSize,
      decoration: BoxDecoration(
        color: const Color(0xFF16213e),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF9D4EDD).withOpacity(0.45),
          width: 1.2,
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9D4EDD)),
            ),
            SizedBox(height: 16),
            Text(
              'Generating Chart...',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      width: _alignedSize,
      height: _alignedSize,
      decoration: BoxDecoration(
        color: const Color(0xFF16213e),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.45), width: 1.2),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isServerAvailable ? Icons.error_outline : Icons.cloud_off,
                color: Colors.orange,
                size: 40,
              ),
              const SizedBox(height: 12),
              Text(
                _error ?? 'Error loading chart',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  _apiService.useNextApiKey();
                  _checkServerAndLoadChart();
                },
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9D4EDD),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartView() {
    return Container(
      width: _alignedSize,
      height: _alignedSize,
      decoration: BoxDecoration(
        color: const Color(0xFF0F1A3A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF9D4EDD).withOpacity(0.35),
          width: 1.0,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SvgPicture.string(
          preprocessSvg(_svgContent!),
          width: _alignedSize,
          height: _alignedSize,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}


/// Widget for displaying multiple divisional charts
class DivisionalChartsGrid extends StatefulWidget {
  final BirthDetails birthDetails;
  final List<DivisionalChart> charts;
  final double chartSize;
  final int crossAxisCount;

  const DivisionalChartsGrid({
    super.key,
    required this.birthDetails,
    this.charts = const [
      DivisionalChart.d1,
      DivisionalChart.d9,
      DivisionalChart.d10,
      DivisionalChart.d7,
    ],
    this.chartSize = 180,
    this.crossAxisCount = 2,
  });

  @override
  State<DivisionalChartsGrid> createState() => _DivisionalChartsGridState();
}

class _DivisionalChartsGridState extends State<DivisionalChartsGrid> {
  final ChartApiService _apiService = ChartApiService();
  
  Map<String, ChartData>? _charts;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCharts();
  }

  Future<void> _loadCharts() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final chartCodes = widget.charts.map((c) => c.code.toLowerCase()).toList();
    
    final response = await _apiService.getMultipleCharts(
      widget.birthDetails,
      charts: chartCodes,
    );

    if (!mounted) return;
    
    setState(() {
      _isLoading = false;
      if (response.success && response.charts != null) {
        _charts = response.charts;
      } else {
        _error = response.error ?? 'Failed to generate charts';
      }
    });
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9D4EDD)),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.orange, size: 40),
            const SizedBox(height: 12),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadCharts,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9D4EDD),
              ),
            ),
          ],
        ),
      );
    }

    if (_charts == null || _charts!.isEmpty) {
      return const SizedBox.shrink();
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: _charts!.length,
      itemBuilder: (context, index) {
        final entry = _charts!.entries.elementAt(index);
        return _buildChartCard(entry.key, entry.value);
      },
    );
  }

  Widget _buildChartCard(String chartCode, ChartData chartData) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF16213e),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF9D4EDD).withOpacity(0.4),
          width: 1.0,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              '${chartCode.toUpperCase()} - ${chartData.name}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SvgPicture.string(
                  preprocessSvg(chartData.svg),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


/// Horizontal scrollable chart viewer
class HorizontalChartViewer extends StatefulWidget {
  final BirthDetails birthDetails;
  final List<DivisionalChart> charts;
  final double chartSize;

  const HorizontalChartViewer({
    super.key,
    required this.birthDetails,
    this.charts = const [
      DivisionalChart.d1,
      DivisionalChart.d9,
      DivisionalChart.d10,
    ],
    this.chartSize = 300,
  });

  @override
  State<HorizontalChartViewer> createState() => _HorizontalChartViewerState();
}

class _HorizontalChartViewerState extends State<HorizontalChartViewer> {
  final ChartApiService _apiService = ChartApiService();
  
  Map<String, ChartData>? _charts;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCharts();
  }

  Future<void> _loadCharts() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final chartCodes = widget.charts.map((c) => c.code.toLowerCase()).toList();
    
    final response = await _apiService.getMultipleCharts(
      widget.birthDetails,
      charts: chartCodes,
    );

    if (!mounted) return;
    
    setState(() {
      _isLoading = false;
      if (response.success && response.charts != null) {
        _charts = response.charts;
      } else {
        _error = response.error ?? 'Failed to generate charts';
      }
    });
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SizedBox(
        height: widget.chartSize + 50,
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9D4EDD)),
          ),
        ),
      );
    }

    if (_error != null) {
      return SizedBox(
        height: widget.chartSize + 50,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.orange),
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: Colors.white70)),
              TextButton(
                onPressed: _loadCharts,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_charts == null || _charts!.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: widget.chartSize + 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _charts!.length,
        itemBuilder: (context, index) {
          final entry = _charts!.entries.elementAt(index);
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Column(
              children: [
                Text(
                  '${entry.key.toUpperCase()} - ${entry.value.name}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: widget.chartSize,
                  height: widget.chartSize,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F1A3A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF9D4EDD).withOpacity(0.35),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SvgPicture.string(
                      preprocessSvg(entry.value.svg),
                      width: widget.chartSize,
                      height: widget.chartSize,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
