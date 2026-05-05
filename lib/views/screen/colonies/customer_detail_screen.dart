import 'package:flutter/material.dart';
import 'package:flutter_extension/controller/customer_detail_controller.dart';
import 'package:flutter_extension/helper/colony_flow_args.dart';
import 'package:flutter_extension/util/app_colors.dart';
import 'package:flutter_extension/views/screen/colonies/widgets/customer_detail/customer_detail_shell.dart';
import 'package:flutter_extension/views/screen/colonies/widgets/customer_detail/customer_detail_tab_pages.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class CustomerDetailScreen extends StatefulWidget {
  const CustomerDetailScreen({super.key});

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  @override
  void initState() {
    super.initState();
    final CustomerDetailArgs args = Get.arguments is CustomerDetailArgs
        ? Get.arguments as CustomerDetailArgs
        : const CustomerDetailArgs(
            name: 'Customer',
            category: '',
            email: '',
            phone: '',
            statusLabel: '',
            statusDateLabel: '',
          );
    Get.put(CustomerDetailController(args: args));
  }

  @override
  void dispose() {
    if (Get.isRegistered<CustomerDetailController>()) {
      Get.delete<CustomerDetailController>();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            GetBuilder<CustomerDetailController>(
              builder: (CustomerDetailController c) {
                return CustomerDetailAppBar(
                  args: c.args,
                  tabIndex: c.tabIndex,
                  onTab: c.setTab,
                );
              },
            ),
            GetBuilder<CustomerDetailController>(
              builder: (CustomerDetailController c) {
                final bool isCompactTab = c.tabIndex == 0;
                if (isCompactTab) {
                  return Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
                    child: _detailCard(),
                  );
                }
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
                    child: _detailCard(),
                  ),
                );
              },
            ),
            GetBuilder<CustomerDetailController>(
              builder: (CustomerDetailController c) {
                if (c.tabIndex == 0) {
                  return const Spacer();
                }
                return const SizedBox.shrink();
              },
            ),
            GetBuilder<CustomerDetailController>(
              builder: (CustomerDetailController c) {
                return CustomerDetailBottomBar(args: c.args);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: const CustomerDetailTabPages(),
    );
  }
}
