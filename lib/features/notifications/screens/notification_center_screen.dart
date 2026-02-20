import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme.dart';
import '../../../core/services/daily_tasks_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../shared/widgets/astro_background.dart';

class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  State<NotificationCenterScreen> createState() =>
      _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen>
    with TickerProviderStateMixin {
  final _tasksService = DailyTasksService();
  final _notifService = NotificationService();
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    // Mark all notifications as read when opening
    _notifService.markAllRead();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AstroBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Notifications',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          actions: [
            if (_notifService.notifications.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.done_all_rounded, color: Colors.white54),
                tooltip: 'Mark all read',
                onPressed: () {
                  _notifService.markAllRead();
                  setState(() {});
                },
              ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          physics: const BouncingScrollPhysics(),
          children: [
            _buildTasksOfTheDay(),
            const SizedBox(height: 24),
            _buildNotificationsSection(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ─── Pinned Tasks of the Day ───

  Widget _buildTasksOfTheDay() {
    final tasks = _tasksService.tasks;
    final progress = _tasksService.progress;
    final completed = _tasksService.completedCount;
    final total = _tasksService.totalCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFf5a623), Color(0xFFf7931e)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.push_pin_rounded,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TASKS OF THE DAY',
                    style: GoogleFonts.quicksand(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AstroTheme.accentGold.withOpacity(0.8),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$completed of $total completed',
                    style: GoogleFonts.quicksand(
                      fontSize: 13,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
            // Progress Ring
            _buildProgressRing(progress),
          ],
        ),
        const SizedBox(height: 16),

        // Tasks Card
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1E2145).withOpacity(0.9),
                const Color(0xFF151830).withOpacity(0.9),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AstroTheme.accentGold.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AstroTheme.accentGold.withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              children: [
                // Gradient top accent bar
                Container(
                  height: 3,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFf5a623),
                        Color(0xFFff6b9d),
                        Color(0xFF7B61FF),
                        Color(0xFF00d4ff),
                      ],
                    ),
                  ),
                ),
                // Tasks list
                ...tasks.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final task = entry.value;
                  final isLast = idx == tasks.length - 1;
                  return _buildTaskItem(task, isLast);
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressRing(double progress) {
    return AnimatedBuilder(
      animation: _progressController,
      builder: (context, child) {
        final animatedProgress = progress * _progressController.value;
        return SizedBox(
          width: 48,
          height: 48,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 44,
                height: 44,
                child: CircularProgressIndicator(
                  value: animatedProgress,
                  strokeWidth: 3.5,
                  backgroundColor: Colors.white.withOpacity(0.08),
                  valueColor: AlwaysStoppedAnimation(
                    progress >= 1.0
                        ? AstroTheme.accentGreen
                        : AstroTheme.accentGold,
                  ),
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color:
                      progress >= 1.0 ? AstroTheme.accentGreen : Colors.white70,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTaskItem(DailyTask task, bool isLast) {
    return InkWell(
      onTap: () async {
        await _tasksService.toggleTask(task.id);
        _progressController.reset();
        _progressController.forward();
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.06),
                  ),
                ),
        ),
        child: Row(
          children: [
            // Animated checkbox
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                gradient: task.isCompleted
                    ? LinearGradient(
                        colors: [task.color, task.color.withOpacity(0.7)])
                    : null,
                color: task.isCompleted ? null : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: task.isCompleted
                      ? Colors.transparent
                      : task.color.withOpacity(0.4),
                  width: 2,
                ),
              ),
              child: task.isCompleted
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 16)
                  : null,
            ),
            const SizedBox(width: 14),

            // Task icon
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: task.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(task.icon, color: task.color, size: 18),
            ),
            const SizedBox(width: 12),

            // Task details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: task.isCompleted ? Colors.white38 : Colors.white,
                      decoration:
                          task.isCompleted ? TextDecoration.lineThrough : null,
                      decorationColor: Colors.white38,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    task.description,
                    style: GoogleFonts.quicksand(
                      fontSize: 11,
                      color: task.isCompleted ? Colors.white24 : Colors.white54,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Category badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: task.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                task.category.toUpperCase(),
                style: GoogleFonts.quicksand(
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  color: task.color.withOpacity(0.7),
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Notifications List ───

  Widget _buildNotificationsSection() {
    final notifications = _notifService.notifications;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AstroTheme.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.notifications_rounded,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Text(
              'RECENT',
              style: GoogleFonts.quicksand(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AstroTheme.accentPurple.withOpacity(0.8),
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (notifications.isEmpty)
          _buildEmptyState()
        else
          ...notifications.map(_buildNotificationCard),
      ],
    );
  }

  Widget _buildNotificationCard(AppNotification notif) {
    final timeAgo = _formatTimeAgo(notif.timestamp);

    return Dismissible(
      key: Key(notif.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        _notifService.removeNotification(notif.id);
        setState(() {});
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.red, size: 22),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AstroTheme.cardBackground.withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notif.isRead
                ? Colors.white.withOpacity(0.05)
                : notif.color.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: notif.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(notif.icon, color: notif.color, size: 20),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (!notif.isRead)
                        Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            color: notif.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                      Expanded(
                        child: Text(
                          notif.title,
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Text(
                        timeAgo,
                        style: GoogleFonts.quicksand(
                          fontSize: 10,
                          color: Colors.white30,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notif.message,
                    style: GoogleFonts.quicksand(
                      fontSize: 12,
                      color: Colors.white54,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 56,
            color: Colors.white.withOpacity(0.12),
          ),
          const SizedBox(height: 16),
          Text(
            'All caught up!',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white38,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No new notifications. Keep exploring the cosmos ✨',
            style: GoogleFonts.quicksand(
              fontSize: 13,
              color: Colors.white24,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${timestamp.day}/${timestamp.month}';
  }
}
