import 'package:flutter/material.dart';
import 'package:flutter_extension/util/app_colors.dart';
import 'package:flutter_extension/views/base/app_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Filter chip: label already includes count text, e.g. "All (4)".
class SearchFilterChipData {
  const SearchFilterChipData({
    required this.id,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String id;
  final String label;
  final bool selected;
  final VoidCallback onTap;
}

/// Horizontal row of filter chips (scrollable).
class SearchFilterChipsRow extends StatelessWidget {
  const SearchFilterChipsRow({
    super.key,
    required this.chips,
    this.padding = EdgeInsets.zero,
  });

  final List<SearchFilterChipData> chips;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding,
      child: Row(
        children: <Widget>[
          for (int i = 0; i < chips.length; i++) ...<Widget>[
            if (i > 0) SizedBox(width: 10.w),
            _Chip(data: chips[i]),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.data});

  final SearchFilterChipData data;

  @override
  Widget build(BuildContext context) {
    final bool sel = data.selected;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: data.onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: sel ? null : AppColors.white,
            borderRadius: BorderRadius.circular(14.r),
            gradient: sel ?  const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: <Color>[
                Color(0xFF408E1A),
                Color(0xFF17B85F),
              ],
            ) : null,
            border: Border.all(
              color: sel ? AppColors.green500 : AppColors.grey50,
              width: 1,
            ),
          ),
          child: AppText.smd(
            data.label,
            fontSize: 13,
            color: sel ? AppColors.white : AppColors.grey500,
            useResponsiveSize: true,
          ),
        ),
      ),
    );
  }
}
