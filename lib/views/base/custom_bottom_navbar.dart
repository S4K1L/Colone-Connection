import 'package:flutter/material.dart';
import 'package:flutter_extension/util/app_colors.dart';
import 'package:flutter_extension/views/base/app_text.dart';
import 'package:flutter_extension/views/screen/home/home_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomBottomNavbar extends StatefulWidget {
  const CustomBottomNavbar({super.key});

  @override
  State<CustomBottomNavbar> createState() => _CustomBottomNavbarState();
}

class _CustomBottomNavbarState extends State<CustomBottomNavbar> {
  int currentIndex = 0;

  late final List<Widget> pages = <Widget>[
    const HomeScreen(),
    const _NavPlaceholder(title: 'Colonies'),
    const _NavPlaceholder(title: 'Alerts'),
    const _NavPlaceholder(title: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.green25,
      body: IndexedStack(index: currentIndex, children: pages),
      bottomNavigationBar: CustomBottomUi(
        currentIndex: currentIndex,
        onTap: (int index) => setState(() => currentIndex = index),
      ),
    );
  }
}

class CustomBottomUi extends StatelessWidget {
  const CustomBottomUi({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final List<String> iconPaths = <String>[
      'assets/icons/map.svg',
      'assets/icons/colone.svg',
      'assets/icons/alert.svg',
      'assets/icons/profile.svg',
    ];
    final List<String> labels = <String>['Map', 'Colonies', 'Alerts', 'Profile'];

    return Container(
      margin: EdgeInsets.fromLTRB(12.w, 0, 12.w, 8.h),
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: List<Widget>.generate(labels.length, (int index) {
          final bool selected = currentIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(index),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 9.h),
                decoration: BoxDecoration(
                  color: selected ? AppColors.green50 : AppColors.green25,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SvgPicture.asset(
                      iconPaths[index],
                      width: 20.w,
                      height: 20.w,
                      colorFilter: ColorFilter.mode(
                        selected ? AppColors.green600 : AppColors.grey400,
                        BlendMode.srcIn,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    AppText.rg(
                      labels[index],
                      fontSize: 11,
                      color: selected ? AppColors.green600 : AppColors.grey400,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NavPlaceholder extends StatelessWidget {
  const _NavPlaceholder({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AppText.smd('$title Screen', fontSize: 22, color: AppColors.grey400),
    );
  }
}
