import 'package:flutter/material.dart';
import 'package:flutter_extension/model/map_search_models.dart';
import 'package:flutter_extension/util/app_colors.dart';
import 'package:flutter_extension/views/base/app_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Colony row: title, district, divider, customers + last visit.
class ColonySearchResultCard extends StatelessWidget {
  const ColonySearchResultCard({
    super.key,
    required this.colony,
    this.onTap,
  });

  final SearchColonyResult colony;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: AppColors.grey50),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.grey300.withValues(alpha: 0.12),
                blurRadius: 8,
                offset: Offset(0, 2.h),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AppText.smd(
                colony.name,
                fontSize: 16,
                color: AppColors.grey500,
                useResponsiveSize: true,
              ),
              SizedBox(height: 4.h),
              AppText.rg(
                colony.district,
                fontSize: 13,
                color: AppColors.grey300,
                useResponsiveSize: true,
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: const Divider(height: 1, color: AppColors.grey50),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _FooterItem(
                      icon: Icons.person_outline,
                      text: '${colony.customers} customers',
                    ),
                  ),
                  Expanded(
                    child: _FooterItem(
                      icon: Icons.calendar_today_outlined,
                      text: 'Last visit: ${colony.lastVisitLabel}',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FooterItem extends StatelessWidget {
  const _FooterItem({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 16.w, color: AppColors.grey300),
        SizedBox(width: 6.w),
        Expanded(
          child: AppText.rg(
            text,
            fontSize: 12,
            color: AppColors.grey300,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            useResponsiveSize: true,
          ),
        ),
      ],
    );
  }
}
