import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/astro_card.dart';
import '../../../shared/widgets/astro_background.dart';
import '../../../core/constants/nakshatra_data.dart';
import '../../../core/models/models.dart';
import 'nakshatra_detail_screen.dart';

class NakshatraScreen extends StatefulWidget {
  const NakshatraScreen({super.key});

  @override
  State<NakshatraScreen> createState() => _NakshatraScreenState();
}

class _NakshatraScreenState extends State<NakshatraScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Dev', 'Human', 'Rakshasa'];

  @override
  Widget build(BuildContext context) {
    return AstroBackground(
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildFilterChips(),
            Expanded(
              child: _buildNakshatraGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: AstroTheme.goldGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AstroTheme.accentGold.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.stars,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nakshatra Explorer',
                  style: AstroTheme.headingMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  '27 Lunar Mansions • Subconscious Drivers',
                  style: AstroTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilter = filter),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  gradient: isSelected ? AstroTheme.primaryGradient : null,
                  color: isSelected ? null : AstroTheme.cardBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : Colors.white.withOpacity(0.1),
                  ),
                ),
                child: Center(
                  child: Text(
                    filter,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? Colors.white : Colors.white54,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNakshatraGrid() {
    final nakshatras = _selectedFilter == 'All'
        ? NakshatraData.nakshatras
        : NakshatraData.nakshatras
            .where((n) => n.gana == _selectedFilter)
            .toList();

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: nakshatras.length,
      itemBuilder: (context, index) {
        final nakshatra = nakshatras[index];
        return _buildNakshatraCard(nakshatra);
      },
    );
  }

  Widget _buildNakshatraCard(Nakshatra nakshatra) {
    final lordColor = AstroTheme.getPlanetColor(nakshatra.lord);
    
    return AstroCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NakshatraDetailScreen(nakshatraNumber: nakshatra.number),
          ),
        );
      },
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: lordColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${nakshatra.number}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: lordColor,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AstroTheme.cardBackgroundLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  nakshatra.lord,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white54,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nakshatra.name,
                style: AstroTheme.headingSmall.copyWith(fontSize: 16),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                nakshatra.symbol,
                style: AstroTheme.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          Row(
            children: [
              Icon(
                Icons.arrow_forward,
                size: 14,
                color: lordColor,
              ),
              const SizedBox(width: 4),
              Text(
                'Explore',
                style: TextStyle(
                  fontSize: 11,
                  color: lordColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
