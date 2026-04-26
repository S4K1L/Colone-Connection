import 'package:flutter/material.dart';

class AppNotificationModel {
  AppNotificationModel({
    required this.id,
    required this.title,
    required this.content,
    required this.noteType,
    required this.accentColor,
    this.timeAgo = 'Just now',
    this.isNew = true,
  });

  final String id;
  final String title;
  final String content;
  final String noteType;
  final String timeAgo;
  final Color accentColor;
  final bool isNew;

  factory AppNotificationModel.fromJson(
    Map<String, dynamic> json, {
    required Color accentColor,
  }) {
    return AppNotificationModel(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
      noteType: (json['note_type'] ?? '').toString(),
      accentColor: accentColor,
      timeAgo: 'Just now',
      isNew: true,
    );
  }
}
