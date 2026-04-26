import 'package:flutter/material.dart';
import 'package:flutter_extension/model/colony_list_item_model.dart';
import 'package:flutter_extension/util/app_colors.dart';
import 'package:flutter_extension/views/base/app_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ColonyListCard extends StatelessWidget {
  const ColonyListCard({
    super.key,
    required this.item,
    required this.onViewDetails,
  });

  final ColonyListItem item;
  final VoidCallback onViewDetails;

  /// Design tokens (reference mock).
  static const Color _statBlue = Color(0xFFF0F7FF);
  static const Color _statGreen = Color(0xFFF0F9F0);
  static const Color _statPeach = Color(0xFFFFF0EE);
  static const Color _badgeVisitedOuter = Color(0xFFEEF8ED);
  static const Color _badgeVisitedInner = Color(0xFFD8F0DA);
  static const Color _visitedLabelColor = Color(0xFF2D6B45);
  static const Color _badgeNotVisitedOuter = Color(0xFFFDF0E7);
  static const Color _badgeNotVisitedInner = Color(0xFFF5E0D0);
  static const Color _actionGreen = Color(0xFF438C3F);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: Offset(0, 4.h),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    AppText.smd(
                      item.name,
                      fontSize: 16,
                      color: AppColors.grey500,
                      useResponsiveSize: true,
                    ),
                    SizedBox(height: 4.h),
                    AppText.rg(
                      item.area,
                      fontSize: 13,
                      color: AppColors.grey300,
                      useResponsiveSize: true,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              _StatusBadge(item: item),
            ],
          ),
          SizedBox(height: 16.h),
          _StatsRow(item: item),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: const Divider(height: 1, color: AppColors.grey50),
          ),
          Row(
            children: <Widget>[
              Icon(
                Icons.calendar_today_outlined,
                size: 16.sp,
                color: AppColors.grey300,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style: TextStyle(
                      fontSize: 12.sp,
                      height: 1.3,
                      color: AppColors.grey300,
                    ),
                    children: <TextSpan>[
                      const TextSpan(text: 'Last visit: '),
                      TextSpan(
                        text: item.lastVisitLabel,
                        style: const TextStyle(
                          color: AppColors.grey500,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: onViewDetails,
                behavior: HitTestBehavior.opaque,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const AppText.smd(
                      'View Details',
                      fontSize: 13,
                      color: _actionGreen,
                      useResponsiveSize: true,
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 20.sp,
                      color: _actionGreen,
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

  final ColonyListItem item;

  @override
  Widget build(BuildContext context) {
    if (item.isVisited) {
      return Container(
        padding: EdgeInsets.fromLTRB(10.w, 6.h, 6.h, 6.h),
        decoration: BoxDecoration(
          color: ColonyListCard._badgeVisitedOuter,
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AppText.rg(
              item.statusDateLabel,
              fontSize: 11,
              color: AppColors.grey500,
              useResponsiveSize: true,
            ),
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: ColonyListCard._badgeVisitedInner,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: const AppText.smd(
                'Visited',
                fontSize: 10,
                color: ColonyListCard._visitedLabelColor,
                useResponsiveSize: true,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.fromLTRB(10.w, 6.h, 6.h, 6.h),
      decoration: BoxDecoration(
        color: ColonyListCard._badgeNotVisitedOuter,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AppText.rg(
            item.statusDateLabel,
            fontSize: 11,
            color: AppColors.grey500,
            useResponsiveSize: true,
          ),
          SizedBox(width: 8.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: ColonyListCard._badgeNotVisitedInner,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: const AppText.smd(
              'Not Visited',
              fontSize: 10,
              color: Color(0xFFC27A2E),
              useResponsiveSize: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.item});

  final ColonyListItem item;

  @override
  Widget build(BuildContext context) {
    if (item.showsOnlyCustomers) {
      return _StatBox(
        value: '${item.customers}',
        label: 'Customers',
        background: ColonyListCard._statBlue,
        expand: true,
      );
    }
    if (item.showsTwoStats) {
      return Row(
        children: <Widget>[
          Expanded(
            child: _StatBox(
              value: '${item.customers}',
              label: 'Customers',
              background: ColonyListCard._statBlue,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: _StatBox(
              value: '${item.visitedCount}',
              label: 'Visited',
              background: ColonyListCard._statGreen,
            ),
          ),
        ],
      );
    }
    return Row(
      children: <Widget>[
        Expanded(
          child: _StatBox(
            value: '${item.customers}',
            label: 'Customers',
            background: ColonyListCard._statBlue,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _StatBox(
            value: '${item.visitedCount}',
            label: 'Visited',
            background: ColonyListCard._statGreen,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _StatBox(
            value: '${item.overdueCount}',
            label: 'Overdue',
            background: ColonyListCard._statPeach,
          ),
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.value,
    required this.label,
    required this.background,
    this.expand = false,
  });

  final String value;
  final String label;
  final Color background;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: expand ? double.infinity : null,
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 6.w),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14.r),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AppText.smd(
            value,
            fontSize: 16,
            color: AppColors.grey500,
            useResponsiveSize: true,
          ),
          SizedBox(height: 2.h),
          AppText.rg(
            label,
            fontSize: 11,
            color: AppColors.grey500,
            useResponsiveSize: true,
          ),
        ],
      ),
    );
  }
}
