import 'package:flutter/material.dart';
import 'package:flutter_extension/controller/colonies_controller.dart';
import 'package:flutter_extension/model/colony_list_item_model.dart';
import 'package:flutter_extension/util/app_colors.dart';
import 'package:flutter_extension/views/base/app_text.dart';
import 'package:flutter_extension/views/screen/colonies/widgets/colonies_filter_bar.dart';
import 'package:flutter_extension/views/screen/colonies/widgets/colony_list_card.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ColoniesScreen extends StatelessWidget {
  const ColoniesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ColoniesController>(
      builder: (ColoniesController c) {
        return Scaffold(
          backgroundColor: AppColors.green25,
          body: SafeArea(
            bottom: false,
            child: _ColoniesBody(controller: c),
          ),
        );
      },
    );
  }
}

class _ColoniesBody extends StatelessWidget {
  const _ColoniesBody({required this.controller});

  final ColoniesController controller;

  @override
  Widget build(BuildContext context) {
    final double headerH = 128.h;
    final double overlap = 28.h;

    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: headerH,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(20.w, 8.h, 16.w, 40.h),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  Color(0xFF2EAD4B),
                  Color(0xFF4BC76A),
                ],
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const AppText.smd(
                        'Colony',
                        fontSize: 22,
                        color: AppColors.white,
                        useResponsiveSize: true,
                      ),
                      SizedBox(height: 6.h),
                      const AppText.rg(
                        'Total: ${ColoniesController.totalColonies} Colony',
                        fontSize: 14,
                        color: AppColors.white,
                        useResponsiveSize: true,
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),
                ),
                _HeaderIconButton(
                  icon: Icons.add,
                  onTap: controller.onAddColony,
                ),
                SizedBox(width: 10.w),
                _HeaderIconButton(
                  icon: Icons.search,
                  onTap: controller.onSearchColonies,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: headerH - overlap,
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(26.r),
                topRight: Radius.circular(26.r),
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: Offset(0, -2.h),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 8.h),
                  child: ColoniesFilterBar(
                    filter: controller.filter,
                    dateLabel: controller.formattedSelectedDate,
                    onFilterSelected: controller.setFilter,
                    onPickDate: controller.pickDate,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
                    itemCount: controller.visibleColonies.length,
                    itemBuilder: (BuildContext context, int index) {
                      final ColonyListItem item =
                          controller.visibleColonies[index];
                      return ColonyListCard(
                        item: item,
                        onViewDetails: () =>
                            controller.onViewDetails(item),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          width: 44.w,
          height: 44.w,
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(12.r),
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: AppColors.white,
            size: 22.sp,
          ),
        ),
      ),
    );
  }
}
