import 'package:flutter/material.dart';
import 'package:flutter_extension/model/colony_customer_model.dart';
import 'package:flutter_extension/helper/colony_flow_args.dart';
import 'package:flutter_extension/helper/route_helper.dart';
import 'package:flutter_extension/util/app_colors.dart';
import 'package:flutter_extension/views/base/app_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ColonyCustomerCard extends StatelessWidget {
  const ColonyCustomerCard({
    super.key,
    required this.item,
    this.colonyName = '',
    this.colonyArea = '',
    required this.onPrimaryAction,
    required this.onSecondaryAction,
  });

  final ColonyCustomerItem item;
  final String colonyName;
  final String colonyArea;
  final VoidCallback onPrimaryAction;
  final VoidCallback onSecondaryAction;

  static const Color _visitedBg = Color(0xFFE0F2F1);
  static const Color _visitedText = Color(0xFF00897B);
  static const Color _overdueBg = Color(0xFFFFF3E0);
  static const Color _overdueText = Color(0xFFFB8C00);
  static const Color _linkGreen = Color(0xFF438C3F);

  @override
  Widget build(BuildContext context) {
    final bool visited = item.status == ColonyCustomerStatus.visited;

    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.grey50),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: AppText.smd(
                  item.name,
                  fontSize: 16,
                  color: AppColors.grey500,
                  useResponsiveSize: true,
                ),
              ),
              _StatusBadge(item: item),
            ],
          ),
          SizedBox(height: 6.h),
          AppText.rg(
            item.category,
            fontSize: 13,
            color: AppColors.grey300,
            useResponsiveSize: true,
          ),
          SizedBox(height: 12.h),
          _ContactRow(
            text: item.email,
            icon: Icons.mail_outline_rounded,
          ),
          SizedBox(height: 8.h),
          _ContactRow(
            text: item.phone,
            icon: Icons.phone_outlined,
          ),
          SizedBox(height: 14.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: <Widget>[
                    _OutlinedMiniButton(
                      label: item.primaryActionLabel,
                      onTap: onPrimaryAction,
                    ),
                    _OutlinedMiniButton(
                      label: item.secondaryActionLabel,
                      onTap: onSecondaryAction,
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Get.toNamed(
                  AppRoutes.customerDetail,
                  arguments: CustomerDetailArgs(
                    name: item.name,
                    category: item.category,
                    email: item.email,
                    phone: item.phone,
                    statusLabel:
                        visited ? 'Visited' : 'Overdue',
                    statusDateLabel: item.statusDateLabel,
                    role: item.role,
                    colonyName: colonyName,
                    colonyArea: colonyArea,
                  ),
                ),
                behavior: HitTestBehavior.opaque,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const AppText.smd(
                      'View Details',
                      fontSize: 13,
                      color: _linkGreen,
                      useResponsiveSize: true,
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 20.sp,
                      color: _linkGreen,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.item});

  final ColonyCustomerItem item;

  @override
  Widget build(BuildContext context) {
    final bool visited = item.status == ColonyCustomerStatus.visited;
    if (visited) {
      return Container(
        padding: EdgeInsets.fromLTRB(8.w, 5.h, 8.w, 5.h),
        decoration: BoxDecoration(
          color: ColonyCustomerCard._visitedBg,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AppText.rg(
              item.statusDateLabel,
              fontSize: 10,
              color: AppColors.grey400,
              useResponsiveSize: true,
            ),
            SizedBox(width: 6.w),
            const AppText.smd(
              'Visited',
              fontSize: 11,
              color: ColonyCustomerCard._visitedText,
              useResponsiveSize: true,
            ),
          ],
        ),
      );
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: ColonyCustomerCard._overdueBg,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: const AppText.smd(
        'Overdue',
        fontSize: 11,
        color: ColonyCustomerCard._overdueText,
        useResponsiveSize: true,
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.text,
    required this.icon,
  });

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: AppText.rg(
            text,
            fontSize: 12,
            color: AppColors.grey500,
            useResponsiveSize: true,
          ),
        ),
        Icon(
          icon,
          size: 18.sp,
          color: AppColors.grey300,
        ),
      ],
    );
  }
}

class _OutlinedMiniButton extends StatelessWidget {
  const _OutlinedMiniButton({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.grey500,
        side: const BorderSide(color: AppColors.grey100),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
      child: AppText.smd(
        label,
        fontSize: 12,
        color: AppColors.grey500,
        useResponsiveSize: true,
      ),
    );
  }
}
