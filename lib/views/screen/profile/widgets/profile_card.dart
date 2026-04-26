import 'package:flutter/material.dart';
import 'package:flutter_extension/model/user_profile_model.dart';
import 'package:flutter_extension/services/api_service.dart';
import 'package:flutter_extension/util/app_colors.dart';
import 'package:flutter_extension/util/app_svg_paths.dart';
import 'package:flutter_extension/views/base/app_svg_icon.dart';
import 'package:flutter_extension/views/base/app_text.dart';
import 'package:flutter_extension/views/screen/profile/widgets/profile_contact_line.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({
    super.key,
    required this.profile,
    required this.onEditProfile,
  });

  final UserProfileModel profile;
  final VoidCallback onEditProfile;

  @override
  Widget build(BuildContext context) {
    final String imageUrl = ApiService.getImgUrl(profile.image) ?? '';
    final bool hasImage = imageUrl.isNotEmpty;
    final String name = profile.fullName.isNotEmpty ? profile.fullName : 'Unknown User';
    final String jobTitle = profile.profile.jobTitle.isNotEmpty
        ? profile.profile.jobTitle
        : 'Not specified';
    final String company = profile.profile.company.isNotEmpty
        ? profile.profile.company
        : 'Not specified';
    final String location = _buildLocation(profile.profile.city, profile.profile.country);

    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.grey100),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.grey300.withValues(alpha: 0.16),
            blurRadius: 14,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 64.w,
                height: 64.w,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[Color(0xFF408E1A), Color(0xFF17B85F)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: hasImage
                    ? ClipOval(
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Padding(
                            padding: const EdgeInsets.all(16),
                            child: AppSvgIcon(
                              AppSvgPaths.profile,
                              size: 34.w,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(16),
                        child: AppSvgIcon(
                          AppSvgPaths.profile,
                          size: 34.w,
                          color: AppColors.white,
                        ),
                      ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: AppText.smd(
                            name,
                            fontSize: 18,
                            color: AppColors.grey500,
                            useResponsiveSize: true,
                          ),
                        ),
                        if (profile.isActive)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: const AppText.smd(
                              'Active',
                              fontSize: 11,
                              color: AppColors.green700,
                              useResponsiveSize: true,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    AppText.rg(
                      jobTitle,
                      fontSize: 14,
                      color: AppColors.grey300,
                      useResponsiveSize: true,
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 5.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.grey50,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: AppText.rg(
                        'ID: ${profile.id}',
                        fontSize: 12,
                        color: AppColors.grey400,
                        useResponsiveSize: true,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: const Divider(height: 1, color: AppColors.grey50),
          ),
          ProfileContactLine(
            svgPath: AppSvgPaths.mail,
            text: profile.email,
          ),
          SizedBox(height: 12.h),
          ProfileContactLine(
            svgPath: AppSvgPaths.map,
            text: profile.phone,
          ),
          SizedBox(height: 12.h),
          ProfileContactLine(
            svgPath: AppSvgPaths.colony,
            text: '$company${location.isNotEmpty ? ' • $location' : ''}',
          ),
          SizedBox(height: 18.h),
          Material(
            color: AppColors.green50,
            borderRadius: BorderRadius.circular(14.r),
            child: InkWell(
              onTap: onEditProfile,
              borderRadius: BorderRadius.circular(14.r),
              child: Container(
                width: double.infinity,
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                child: const AppText.smd(
                  'Edit Profile',
                  fontSize: 15,
                  color: AppColors.grey500,
                  useResponsiveSize: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _buildLocation(String city, String country) {
    final String cityText = city.trim();
    final String countryText = country.trim();
    if (cityText.isEmpty && countryText.isEmpty) return '';
    if (cityText.isEmpty) return countryText;
    if (countryText.isEmpty) return cityText;
    return '$cityText, $countryText';
  }
}
