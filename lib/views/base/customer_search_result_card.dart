import 'package:flutter/material.dart';
import 'package:flutter_extension/model/map_search_models.dart';
import 'package:flutter_extension/util/app_colors.dart';
import 'package:flutter_extension/views/base/app_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Customer row: avatar initials + colony + role, divider, phone + email.
class CustomerSearchResultCard extends StatelessWidget {
  const CustomerSearchResultCard({
    super.key,
    required this.customer,
    this.onTap,
  });

  final SearchCustomerResult customer;
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 48.w,
                    height: 48.w,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.green500,
                      shape: BoxShape.circle,
                    ),
                    child: AppText.smd(
                      customer.initials,
                      fontSize: 14,
                      color: AppColors.white,
                      useResponsiveSize: true,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        AppText.smd(
                          customer.colonyName,
                          fontSize: 16,
                          color: AppColors.grey500,
                          useResponsiveSize: true,
                        ),
                        SizedBox(height: 4.h),
                        AppText.rg(
                          customer.role,
                          fontSize: 13,
                          color: AppColors.grey300,
                          useResponsiveSize: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: const Divider(height: 1, color: AppColors.grey50),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: _FooterItem(
                      icon: Icons.phone_outlined,
                      text: customer.phone,
                    ),
                  ),
                  Expanded(
                    child: _FooterItem(
                      icon: Icons.email_outlined,
                      text: customer.email,
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
      crossAxisAlignment: CrossAxisAlignment.start,
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
