import 'package:flutter/material.dart';
import 'package:flutter_extension/data/model/app_notification_model.dart';
import 'package:get/get.dart';

/// Pastel accent dots for notification list items.
abstract final class NotificationAccentColors {
  static const Color lightGreen = Color(0xFFB8E8C4);
  static const Color lightBlue = Color(0xFFA8D4F0);
  static const Color mint = Color(0xFFC4E8D4);
  static const Color paleOlive = Color(0xFFD4E0B8);
}

class NotificationsController extends GetxController {
  final List<AppNotificationModel> _items = <AppNotificationModel>[];

  List<AppNotificationModel> get notifications =>
      List<AppNotificationModel>.unmodifiable(_items);

  int get newCount => _items.where((AppNotificationModel e) => e.isNew).length;

  String get subtitleText =>
      newCount == 0 ? 'No new notifications' : '$newCount new';

  bool get hasNotifications => _items.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    _items.addAll(_seedNotifications());
  }

  /// Replace with API / repository when available.
  List<AppNotificationModel> _seedNotifications() {
    return <AppNotificationModel>[
      const AppNotificationModel(
        id: '1',
        title: 'New Colony Assigned',
        body: 'You have been assigned to Riverside Gardens.',
        timeAgo: '5 min ago',
        accentColor: NotificationAccentColors.lightGreen,
      ),
      const AppNotificationModel(
        id: '2',
        title: 'Route Updated',
        body: 'Your route now includes 3 new colony.',
        timeAgo: '1 hour ago',
        accentColor: NotificationAccentColors.lightBlue,
      ),
      const AppNotificationModel(
        id: '3',
        title: 'Visit Reminder',
        body: 'Don’t forget to mark Green Valley as visited today.',
        timeAgo: '3 hours ago',
        accentColor: NotificationAccentColors.mint,
      ),
      const AppNotificationModel(
        id: '4',
        title: 'Weekly Summary',
        body: 'You completed 12 visits this week. Great work!',
        timeAgo: 'Yesterday',
        accentColor: NotificationAccentColors.paleOlive,
        isNew: false,
      ),
    ];
  }

  void dismissNotification(String id) {
    _items.removeWhere((AppNotificationModel e) => e.id == id);
    update();
  }

  /// Clears the list (e.g. after “clear all” from API).
  void clearAll() {
    _items.clear();
    update();
  }
}
