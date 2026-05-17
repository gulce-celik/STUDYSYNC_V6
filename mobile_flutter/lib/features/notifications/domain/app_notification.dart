/// In-app notification item (inbox — not SnackBar toasts).
enum AppNotificationType {
  groupInvitation,
  reservationReminder,
  moderationWarning,
  moderationRestriction,
  system,
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.read = false,
    this.actionLabel,
    this.relatedId,
  });

  final String id;
  final AppNotificationType type;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool read;
  final String? actionLabel;
  final String? relatedId;

  AppNotification copyWith({bool? read}) => AppNotification(
        id: id,
        type: type,
        title: title,
        body: body,
        createdAt: createdAt,
        read: read ?? this.read,
        actionLabel: actionLabel,
        relatedId: relatedId,
      );

  static AppNotificationType typeFromApi(String? raw) {
    switch (raw?.toUpperCase()) {
      case 'GROUP_INVITATION':
      case 'INVITATION':
        return AppNotificationType.groupInvitation;
      case 'RESERVATION_REMINDER':
      case 'REMINDER':
        return AppNotificationType.reservationReminder;
      case 'MODERATION_WARNING':
      case 'WARNING':
        return AppNotificationType.moderationWarning;
      case 'MODERATION_RESTRICTION':
      case 'RESTRICTION':
        return AppNotificationType.moderationRestriction;
      default:
        return AppNotificationType.system;
    }
  }

  static String typeToApi(AppNotificationType type) {
    switch (type) {
      case AppNotificationType.groupInvitation:
        return 'GROUP_INVITATION';
      case AppNotificationType.reservationReminder:
        return 'RESERVATION_REMINDER';
      case AppNotificationType.moderationWarning:
        return 'MODERATION_WARNING';
      case AppNotificationType.moderationRestriction:
        return 'MODERATION_RESTRICTION';
      case AppNotificationType.system:
        return 'SYSTEM';
    }
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final created = json['createdAt'] ?? json['created_at'];
    DateTime at;
    if (created is String) {
      at = DateTime.tryParse(created) ?? DateTime.now();
    } else {
      at = DateTime.now();
    }
    final readVal = json['read'] ?? json['isRead'] ?? json['readAt'] != null;
    return AppNotification(
      id: json['id']?.toString() ?? '',
      type: typeFromApi(json['type']?.toString()),
      title: json['title']?.toString() ?? 'Notification',
      body: json['body']?.toString() ?? json['message']?.toString() ?? '',
      createdAt: at,
      read: readVal == true,
      actionLabel: json['actionLabel']?.toString(),
      relatedId: json['relatedId']?.toString() ?? json['related_id']?.toString(),
    );
  }
}
