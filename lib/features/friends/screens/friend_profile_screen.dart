import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme.dart';
import '../../../core/models/friend_model.dart';
import '../../../core/services/friends_service.dart';
import 'chart_comparison_screen.dart';
import 'compatibility_report_screen.dart';
import 'pet_profile_screen.dart';
import 'pet_interaction_screen.dart';

class FriendProfileScreen extends StatefulWidget {
  final FriendProfile friend;

  const FriendProfileScreen({super.key, required this.friend});

  @override
  State<FriendProfileScreen> createState() => _FriendProfileScreenState();
}

class _FriendProfileScreenState extends State<FriendProfileScreen> {
  late FriendProfile _friend;

  @override
  void initState() {
    super.initState();
    _friend = widget.friend;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AstroTheme.scaffoldBackground,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Hero Header ──
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AstroTheme.scaffoldBackground,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.white54),
                onPressed: _editRelationship,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: _confirmDelete,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF667eea).withOpacity(0.5),
                      const Color(0xFF764ba2).withOpacity(0.3),
                      AstroTheme.scaffoldBackground,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Avatar
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF667eea).withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            _friend.initials,
                            style: GoogleFonts.outfit(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Name
                      Text(
                        _friend.name,
                        style: GoogleFonts.outfit(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Relationship badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF667eea).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF667eea).withOpacity(0.4),
                          ),
                        ),
                        child: Text(
                          '${_friend.relationship.icon} ${_friend.relationship.label}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Astro Summary ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionLabel('ASTRO SNAPSHOT'),
                  const SizedBox(height: 12),
                  _buildAstroGrid(),
                  const SizedBox(height: 28),
                  _buildSectionLabel('BIRTH DETAILS'),
                  const SizedBox(height: 12),
                  _buildBirthDetails(),
                  const SizedBox(height: 28),
                  _buildSectionLabel('ACTIONS'),
                  const SizedBox(height: 12),
                  _buildActionsList(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Section Label ──
  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.quicksand(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AstroTheme.accentGold.withOpacity(0.7),
        letterSpacing: 1.5,
      ),
    );
  }

  // ── Astro Grid (2x2) ──
  Widget _buildAstroGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.8,
      children: [
        _buildAstroCard('🔱', 'Ascendant', _friend.ascendantSign ?? '—'),
        _buildAstroCard('🌙', 'Moon Sign', _friend.moonSign ?? '—'),
        _buildAstroCard('☀️', 'Sun Sign', _friend.sunSign ?? '—'),
        _buildAstroCard('⭐', 'Nakshatra', _friend.moonNakshatra ?? '—'),
      ],
    );
  }

  Widget _buildAstroCard(String emoji, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ],
          ),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: value == '—' ? Colors.white24 : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ── Birth Details ──
  Widget _buildBirthDetails() {
    final dob = _friend.dateOfBirth;
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
    final hour =
        dob.hour > 12 ? dob.hour - 12 : (dob.hour == 0 ? 12 : dob.hour);
    final amPm = dob.hour >= 12 ? 'PM' : 'AM';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          _buildDetailRow(Icons.calendar_today, 'Date',
              '${months[dob.month - 1]} ${dob.day}, ${dob.year}'),
          const Divider(color: Colors.white10, height: 20),
          _buildDetailRow(Icons.access_time, 'Time',
              '$hour:${dob.minute.toString().padLeft(2, '0')} $amPm'),
          const Divider(color: Colors.white10, height: 20),
          _buildDetailRow(
              Icons.location_on_outlined, 'Place', _friend.placeOfBirth),
          if (_friend.friendCode != null) ...[
            const Divider(color: Colors.white10, height: 20),
            _buildDetailRow(Icons.tag, 'Friend Code', _friend.friendCode!),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.white38),
        const SizedBox(width: 12),
        SizedBox(
          width: 60,
          child: Text(label,
              style: const TextStyle(color: Colors.white38, fontSize: 12)),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  // ── Actions ──
  Widget _buildActionsList() {
    return Column(
      children: [
        _buildActionTile(
          icon: Icons.compare_arrows,
          label: 'Compare Charts',
          subtitle: 'Side-by-side chart comparison',
          color: AstroTheme.accentCyan,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChartComparisonScreen(friend: _friend),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        _buildActionTile(
          icon: Icons.favorite,
          label: 'Compatibility Report',
          subtitle: 'Ashtakoot Guna Milan analysis',
          color: AstroTheme.accentPink,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CompatibilityReportScreen(friend: _friend),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        _buildActionTile(
          icon: Icons.timeline,
          label: 'Compare Dasha Periods',
          subtitle: 'Timeline overlay of both charts',
          color: AstroTheme.accentGold,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('⏳ Dasha comparison coming soon!'),
                backgroundColor: AstroTheme.accentGold.withOpacity(0.8),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        _buildActionTile(
          icon: Icons.pets,
          label: 'View Astro Pet',
          subtitle: 'RPG companion from their chart',
          color: AstroTheme.accentPurple,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PetProfileScreen(friend: _friend),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        _buildActionTile(
          icon: Icons.bolt,
          label: 'Pet Interaction',
          subtitle: 'See how your pets help each other',
          color: const Color(0xFFff6b9d),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PetInteractionScreen(friend: _friend),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      )),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(color: Colors.white38, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }

  // ── Edit Relationship ──
  void _editRelationship() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A3E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Change Relationship',
            style: TextStyle(color: Colors.white, fontSize: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: RelationshipType.values.map((type) {
            final isSelected = _friend.relationship == type;
            return ListTile(
              leading: Text(type.icon, style: const TextStyle(fontSize: 20)),
              title: Text(type.label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white60,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  )),
              selected: isSelected,
              selectedTileColor: const Color(0xFF667eea).withOpacity(0.15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              onTap: () async {
                final updated = _friend.copyWith(relationship: type);
                await FriendsService().updateFriend(updated);
                setState(() => _friend = updated);
                if (ctx.mounted) Navigator.pop(ctx);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  // ── Delete ──
  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A3E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title:
            const Text('Remove Friend?', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to remove ${_friend.name}? This cannot be undone.',
          style: const TextStyle(color: Colors.white60),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () async {
              await FriendsService().deleteFriend(_friend.id);
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
