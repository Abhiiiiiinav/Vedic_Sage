import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/user_session.dart';
import '../../../core/astro/accurate_kundali_engine.dart';

/// Debug panel to verify divisional chart calculations
/// Shows planetary degrees and calculated varga positions
class VargaDebugPanel extends StatelessWidget {
  const VargaDebugPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final session = UserSession();
    final vargas = session.birthChart?['vargas'] as Map<String, dynamic>?;
    final apiPlanets = session.birthChart?['apiPlanets'] as Map<String, dynamic>?;

    if (vargas == null || apiPlanets == null) {
      return const Center(
        child: Text('No chart data available'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Varga Calculations Debug',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 16),
            _buildPlanetaryDegreesSection(apiPlanets),
            const SizedBox(height: 16),
            _buildVargaCalculationsSection(vargas, apiPlanets),
            const SizedBox(height: 16),
            _buildVargottamaSection(vargas),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Verification Guide',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'This panel shows the raw calculations for divisional charts. '
              'Compare these values with reference software like Jagannatha Hora '
              'to verify accuracy.',
              style: GoogleFonts.quicksand(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanetaryDegreesSection(Map<String, dynamic> apiPlanets) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📐 Planetary Degrees (Source Data)',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Divider(),
            ...apiPlanets.entries.map((entry) {
              final planet = entry.key;
              final data = entry.value;
              
              if (data is! Map) return const SizedBox.shrink();
              
              final fullDegree = _toDouble(data['fullDegree'] ?? data['full_degree']);
              final sign = _toInt(data['current_sign'] ?? data['sign_num']);
              final signDegree = fullDegree % 30;
              
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 80,
                      child: Text(
                        planet,
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${fullDegree.toStringAsFixed(2)}° '
                        '(Sign: $sign, ${signDegree.toStringAsFixed(2)}° in sign)',
                        style: GoogleFonts.jetBrainsMono(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildVargaCalculationsSection(
    Map<String, dynamic> vargas,
    Map<String, dynamic> apiPlanets,
  ) {
    final divisions = ['D1', 'D2', 'D3', 'D9', 'D10', 'D12'];
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🔢 Varga Calculations',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Divider(),
            ...divisions.map((div) {
              final vargaData = vargas[div];
              if (vargaData == null) return const SizedBox.shrink();
              
              return ExpansionTile(
                title: Text(
                  div,
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'Ascendant: ${_getSignName(vargaData['ascendantSign'])}',
                  style: GoogleFonts.quicksand(fontSize: 12),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: _buildVargaPlanetsList(vargaData, apiPlanets, div),
                  ),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildVargaPlanetsList(
    Map<String, dynamic> vargaData,
    Map<String, dynamic> apiPlanets,
    String division,
  ) {
    final planetSigns = vargaData['planetSigns'] as Map<String, dynamic>?;
    if (planetSigns == null) return const SizedBox.shrink();

    return Column(
      children: planetSigns.entries.map((entry) {
        final planet = entry.key;
        final sign = _toInt(entry.value);
        final signName = _getSignName(sign);
        
        // Get source degree
        final planetData = apiPlanets[planet];
        final sourceDegree = planetData is Map
            ? _toDouble(planetData['fullDegree'] ?? planetData['full_degree'])
            : 0.0;
        
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  planet,
                  style: GoogleFonts.outfit(fontSize: 12),
                ),
              ),
              Expanded(
                child: Text(
                  '$signName ($sign) ← ${sourceDegree.toStringAsFixed(2)}°',
                  style: GoogleFonts.jetBrainsMono(fontSize: 11),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildVargottamaSection(Map<String, dynamic> vargas) {
    final d1 = vargas['D1'];
    if (d1 == null) return const SizedBox.shrink();
    
    final d1Planets = d1['planetSigns'] as Map<String, dynamic>?;
    if (d1Planets == null) return const SizedBox.shrink();

    final vargottamaPlanets = <String, List<String>>{};
    
    // Check D9 (most important)
    final d9 = vargas['D9'];
    if (d9 != null) {
      final d9Planets = d9['planetSigns'] as Map<String, dynamic>?;
      if (d9Planets != null) {
        d1Planets.forEach((planet, d1Sign) {
          final d9Sign = d9Planets[planet];
          if (d1Sign == d9Sign) {
            vargottamaPlanets[planet] = ['D9'];
          }
        });
      }
    }

    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.star, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Vargottama Planets',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Planets in same sign in D1 and divisional chart (powerful placement)',
              style: GoogleFonts.quicksand(fontSize: 12),
            ),
            const Divider(),
            if (vargottamaPlanets.isEmpty)
              Text(
                'No Vargottama planets in D9',
                style: GoogleFonts.quicksand(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              )
            else
              ...vargottamaPlanets.entries.map((entry) {
                final planet = entry.key;
                final divisions = entry.value;
                final sign = _toInt(d1Planets[planet]);
                
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, 
                        color: Colors.green.shade700, 
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$planet in ${_getSignName(sign)} (${divisions.join(", ")})',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade900,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  String _getSignName(int sign) {
    const signs = [
      'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
      'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'
    ];
    if (sign < 1 || sign > 12) return 'Unknown';
    return signs[sign - 1];
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
