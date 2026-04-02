import 'package:flutter/material.dart';
import 'package:flutter_extension/util/app_colors.dart';
import 'package:flutter_extension/views/base/app_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RouteStatItem {
  const RouteStatItem({required this.value, required this.label});

  final String value;
  final String label;
}

/// White card with top radius; row of stats with optional vertical dividers.
class RouteStatsCard extends StatelessWidget {
  const RouteStatsCard({
    super.key,
    required this.items,
    this.topRadius = 26,
  });

  final List<RouteStatItem> items;
  final double topRadius;

  @override
  Widget build(BuildContext context) {
    final double r = topRadius.r;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(r),
          topRight: Radius.circular(r),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        child: IntrinsicHeight(
          child: Row(
            children: <Widget>[
              for (int i = 0; i < items.length; i++) ...<Widget>[
                if (i > 0)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: Container(
                      width: 1,
                      color: AppColors.grey100.withValues(alpha: 0.55),
                    ),
                  ),
                Expanded(child: _StatCell(item: items[i])),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.item});

  final RouteStatItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        AppText.smd(
          item.value,
          fontSize: 22,
          color: AppColors.grey500,
          textAlign: TextAlign.center,
          useResponsiveSize: true,
        ),
        SizedBox(height: 4.h),
        AppText.rg(
          item.label,
          fontSize: 12,
          color: AppColors.grey300,
          textAlign: TextAlign.center,
          useResponsiveSize: true,
        ),
      ],
    );
  }
}
