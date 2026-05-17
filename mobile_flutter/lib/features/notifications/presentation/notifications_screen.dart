import 'package:flutter/material.dart';

import '../../../shared/navigation/app_tab_controller.dart';
import '../data/notifications_controller.dart';
import '../domain/app_notification.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _controller = NotificationsController.instance;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onUpdate);
    if (_controller.items.isEmpty) {
      _controller.refresh();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onUpdate);
    super.dispose();
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final items = _controller.items;
    final unread = _controller.unreadCount;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          if (unread > 0)
            TextButton(
              onPressed: () => _controller.markAllRead(),
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: Column(
        children: [
          if (!_controller.usesLiveApi)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: _SourceBanner(isDark: isDark),
            ),
          Expanded(child: _inboxBody(isDark: isDark, items: items)),
        ],
      ),
    );
  }

  Widget _inboxBody({required bool isDark, required List<AppNotification> items}) {
    if (_controller.loading && items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_controller.error != null && items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(_controller.error!, textAlign: TextAlign.center),
        ),
      );
    }
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_off_outlined,
                size: 48, color: isDark ? Colors.white38 : Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'No notifications yet',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white70 : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _controller.refresh,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final n = items[index];
          return _NotificationTile(
            notification: n,
            isDark: isDark,
            onTap: () => _onTap(n),
          );
        },
      ),
    );
  }

  Future<void> _onTap(AppNotification n) async {
    await _controller.markRead(n.id);
    if (!mounted) return;
    switch (n.type) {
      case AppNotificationType.groupInvitation:
        Navigator.pop(context);
        AppTabController.instance.selectTab(0);
        break;
      case AppNotificationType.reservationReminder:
        Navigator.pop(context);
        AppTabController.instance.selectTab(1);
        break;
      case AppNotificationType.moderationWarning:
      case AppNotificationType.moderationRestriction:
      case AppNotificationType.system:
        break;
    }
  }
}

class _SourceBanner extends StatelessWidget {
  const _SourceBanner({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E3A5F) : const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? const Color(0xFF3B82F6) : const Color(0xFFBFDBFE)),
      ),
      child: const Text(
        'Demo inbox — GET /notifications not on server yet. Admin warnings sync when your email matches a demo student.',
        style: TextStyle(fontSize: 11, height: 1.35, color: Color(0xFF1E40AF)),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.isDark,
    required this.onTap,
  });

  final AppNotification notification;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final n = notification;
    final (icon, color) = _style(n.type);
    return Material(
      color: isDark ? const Color(0xFF1F2937) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: n.read
                  ? (isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB))
                  : color.withValues(alpha: 0.45),
              width: n.read ? 1 : 1.5,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            n.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: isDark ? Colors.white : const Color(0xFF111827),
                            ),
                          ),
                        ),
                        if (!n.read)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      n.body,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.35,
                        color: isDark ? Colors.white70 : const Color(0xFF4B5563),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _timeAgo(n.createdAt),
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? Colors.white38 : const Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  (IconData, Color) _style(AppNotificationType type) {
    switch (type) {
      case AppNotificationType.groupInvitation:
        return (Icons.group_rounded, const Color(0xFF9333EA));
      case AppNotificationType.reservationReminder:
        return (Icons.schedule_rounded, const Color(0xFF2563EB));
      case AppNotificationType.moderationWarning:
        return (Icons.warning_amber_rounded, const Color(0xFFD97706));
      case AppNotificationType.moderationRestriction:
        return (Icons.block_rounded, const Color(0xFFDC2626));
      case AppNotificationType.system:
        return (Icons.info_outline_rounded, const Color(0xFF6B7280));
    }
  }

  String _timeAgo(DateTime at) {
    final diff = DateTime.now().difference(at);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inHours < 48) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
