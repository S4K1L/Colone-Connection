import 'package:flutter/material.dart';
import 'package:flutter_extension/model/app_notification_model.dart';
import 'package:flutter_extension/services/api_service.dart';
import 'package:flutter_extension/util/api_constant.dart';
import 'package:flutter_extension/views/base/custom_snackbar.dart';
import 'package:get/get.dart';

abstract final class NotificationAccentColors {
  static const Color lightGreen = Color(0xFFB8E8C4);
  static const Color lightBlue = Color(0xFFA8D4F0);
  static const Color mint = Color(0xFFC4E8D4);
  static const Color paleOlive = Color(0xFFD4E0B8);
}

class NotificationsController extends GetxController {
  final List<AppNotificationModel> _items = <AppNotificationModel>[];
  bool isLoading = false;

  List<AppNotificationModel> get notifications =>
      List<AppNotificationModel>.unmodifiable(_items);

  int get newCount => _items.where((AppNotificationModel e) => e.isNew).length;

  String get subtitleText =>
      newCount == 0 ? 'No new notifications' : '$newCount new';

  bool get hasNotifications => _items.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    getNotifications();
  }

  Future<void> getNotifications() async {
    isLoading = true;
    update();
    try {
      final response = await ApiService().get(
        ApiConstant.GET_NOTIFICATIONS,
        authReq: true,
      );
      final dynamic rawData = response.data;
      final List<dynamic> dataList = rawData is Map<String, dynamic>
          ? (rawData['data'] as List<dynamic>? ?? <dynamic>[])
          : <dynamic>[];

      _items.clear();
      for (final dynamic item in dataList) {
        if (item is! Map<String, dynamic>) continue;
        final String noteType = (item['note_type'] ?? '').toString();
        _items.add(
          AppNotificationModel.fromJson(
            item,
            accentColor: _accentColorFromType(noteType),
          ),
        );
      }
      update();
    } catch (e) {
      showCustomSnackBar(e.toString(), getXSnackBar: true);
    } finally {
      isLoading = false;
      update();
    }
  }

  Color _accentColorFromType(String noteType) {
    switch (noteType.toLowerCase()) {
      case 'success':
        return NotificationAccentColors.lightGreen;
      case 'warning':
        return NotificationAccentColors.paleOlive;
      case 'error':
      case 'danger':
        return const Color(0xFFF3B8B8);
      case 'info':
      default:
        return NotificationAccentColors.lightBlue;
    }
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
