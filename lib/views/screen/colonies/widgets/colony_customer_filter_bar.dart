import 'package:flutter/material.dart';
import 'package:flutter_extension/controller/colony_customers_controller.dart';
import 'package:flutter_extension/util/app_colors.dart';
import 'package:flutter_extension/views/base/app_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ColonyCustomerFilterBar extends StatelessWidget {
  const ColonyCustomerFilterBar({
    super.key,
    required this.filter,
    required this.onFilterSelected,
  });

  final ColonyCustomerListFilter filter;
  final ValueChanged<ColonyCustomerListFilter> onFilterSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: <Widget>[
          _Chip(
            label: 'All',
            selected: filter == ColonyCustomerListFilter.all,
            onTap: () => onFilterSelected(ColonyCustomerListFilter.all),
          ),
          SizedBox(width: 8.w),
          _Chip(
            label: 'Visited',
            selected: filter == ColonyCustomerListFilter.visited,
            onTap: () => onFilterSelected(ColonyCustomerListFilter.visited),
          ),
          SizedBox(width: 8.w),
          _Chip(
            label: 'Overdue',
            selected: filter == ColonyCustomerListFilter.overdue,
            onTap: () => onFilterSelected(ColonyCustomerListFilter.overdue),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
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
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: selected ? AppColors.green500 : AppColors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: selected ? AppColors.green500 : AppColors.grey100,
            ),
          ),
          child: AppText.smd(
            label,
            fontSize: 13,
            color: selected ? AppColors.white : AppColors.grey500,
            useResponsiveSize: true,
          ),
        ),
      ),
    );
  }
}
