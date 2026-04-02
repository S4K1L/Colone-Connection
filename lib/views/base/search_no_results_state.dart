import 'package:flutter/material.dart';
import 'package:flutter_extension/util/app_colors.dart';
import 'package:flutter_extension/views/base/app_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Empty search: icon + title + subtitle with highlighted query.
class SearchNoResultsState extends StatelessWidget {
  const SearchNoResultsState({
    super.key,
    required this.query,
  });

  final String query;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 88.w,
              height: 88.w,
              decoration: const BoxDecoration(
                color: AppColors.green500,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search,
                color: AppColors.white,
                size: 40.w,
              ),
            ),
            SizedBox(height: 24.h),
            const AppText.smd(
              'No Results Found',
              fontSize: 18,
              color: AppColors.grey500,
              textAlign: TextAlign.center,
              useResponsiveSize: true,
            ),
            SizedBox(height: 12.h),
            AppText.rg(
              "We couldn't find any colonies or customers matching '$query'. "
              'Try a different search term.',
              fontSize: 14,
              color: AppColors.grey300,
              textAlign: TextAlign.center,
              useResponsiveSize: true,
            ),
          ],
        ),
      ),
    );
  }
}
