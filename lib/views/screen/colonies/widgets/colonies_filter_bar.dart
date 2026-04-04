import 'package:flutter/material.dart';
import 'package:flutter_extension/controller/colonies_controller.dart';
import 'package:flutter_extension/util/app_colors.dart';
import 'package:flutter_extension/views/base/app_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ColoniesFilterBar extends StatelessWidget {
  const ColoniesFilterBar({
    super.key,
    required this.filter,
    required this.dateLabel,
    required this.onFilterSelected,
    required this.onPickDate,
  });

  final ColonyVisitFilter filter;
  final String dateLabel;
  final ValueChanged<ColonyVisitFilter> onFilterSelected;
  final VoidCallback onPickDate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _FilterChip(
                label: 'All',
                selected: filter == ColonyVisitFilter.all,
                onTap: () => onFilterSelected(ColonyVisitFilter.all),
              ),
              SizedBox(width: 8.w),
              _FilterChip(
                label: 'Visited',
                selected: filter == ColonyVisitFilter.visited,
                onTap: () => onFilterSelected(ColonyVisitFilter.visited),
              ),
              SizedBox(width: 8.w),
              _FilterChip(
                label: 'Not Visited',
                selected: filter == ColonyVisitFilter.notVisited,
                onTap: () => onFilterSelected(ColonyVisitFilter.notVisited),
              ),
              SizedBox(width: 40.w),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onPickDate,
                  borderRadius: BorderRadius.circular(12.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.grey100.withValues(alpha: 0.5),
                blurRadius: 10,
                offset: Offset(0, 2.h),
              ),
            ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        AppText.rg(
                          dateLabel,
                          fontSize: 10,
                          color: AppColors.grey500,
                          useResponsiveSize: true,
                        ),
                        SizedBox(width: 8.w),
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 18.sp,
                          color: AppColors.grey400,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      
            ],
          ),
        ),
        ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: selected ? AppColors.green500 : AppColors.white,
            borderRadius: BorderRadius.circular(20.r),
            // border: Border.all(
            //   color: selected ? AppColors.green500 : AppColors.grey100,
            // ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.grey100.withValues(alpha: 0.5),
                blurRadius: 10,
                offset: Offset(0, 2.h),
              ),
            ],
          ),
          child: AppText.smd(
            label,
            fontSize: 14,
            color: selected ? AppColors.white : AppColors.grey500,
            useResponsiveSize: true,
          ),
        ),
      ),
    );
  }
}
