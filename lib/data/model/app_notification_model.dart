import 'package:flutter/material.dart';

/// In-app notification row (alerts tab).
class AppNotificationModel {
  const AppNotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.timeAgo,
    required this.accentColor,
    this.isNew = true,
  });

  final String id;
  final String title;
  final String body;
  final String timeAgo;
  final Color accentColor;
  final bool isNew;
}
