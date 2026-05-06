import 'package:flutter/material.dart';
import 'package:flutter_extension/controller/colony_customers_controller.dart';
import 'package:flutter_extension/model/colony_customer_model.dart';
import 'package:flutter_extension/helper/colony_flow_args.dart';
import 'package:flutter_extension/helper/route_helper.dart';
import 'package:flutter_extension/util/app_colors.dart';
import 'package:flutter_extension/views/screen/colonies/widgets/colony_customer_card.dart';
import 'package:flutter_extension/views/screen/colonies/widgets/colony_customer_filter_bar.dart';
import 'package:flutter_extension/views/screen/colonies/widgets/colony_flow_header.dart';
import 'package:flutter_extension/views/base/app_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ColonyDetailsScreen extends StatefulWidget {
  const ColonyDetailsScreen({super.key});

  @override
  State<ColonyDetailsScreen> createState() => _ColonyDetailsScreenState();
}

class _ColonyDetailsScreenState extends State<ColonyDetailsScreen> {
  @override
  void initState() {
    super.initState();
    final ColonyCustomersArgs args = Get.arguments is ColonyCustomersArgs
        ? Get.arguments as ColonyCustomersArgs
        : const ColonyCustomersArgs(
            colonyId: '0',
            reportId: '0',
            colonyName: 'Colony',
            totalCustomers: 0,
            colonyArea: 'North Delhi',
          );
    Get.put(ColonyCustomersController(args: args));
  }

  @override
  void dispose() {
    if (Get.isRegistered<ColonyCustomersController>()) {
      Get.delete<ColonyCustomersController>();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.green25,
      body: SafeArea(
        child: GetBuilder<ColonyCustomersController>(
          builder: (ColonyCustomersController c) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                ColonyFlowHeader(
                  onBack: () => Get.back(),
                  title: c.args.colonyName,
                  subtitle: 'Total Customer: ${c.args.totalCustomers}',
                  trailingIcon: Icons.add,
                  onTrailingTap: () => Get.toNamed(
                    AppRoutes.addCustomer,
                    arguments: AddCustomerArgs(
                      colonyId: c.args.colonyId,
                      colonyName: c.args.colonyName,
                    ),
                  ),
                ),
                if (c.isLoading)
                  const LinearProgressIndicator(
                    color: AppColors.green500,
                    backgroundColor: AppColors.green25,
                  ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(26.r),
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
                          child: ColonyCustomerFilterBar(
                            filter: c.filter,
                            onFilterSelected: c.setFilter,
                          ),
                        ),
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: () => c.refreshData(),
                            color: AppColors.green500,
                            child: c.visibleCustomers.isEmpty
                                ? SingleChildScrollView(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    child: Container(
                                      height: 400.h,
                                      alignment: Alignment.center,
                                      child: const AppText.md(
                                        'No customers found for this colony.',
                                        color: AppColors.grey300,
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    padding: EdgeInsets.fromLTRB(
                                      16.w,
                                      8.h,
                                      16.w,
                                      24.h,
                                    ),
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    itemCount: c.visibleCustomers.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                          final ColonyCustomerItem item =
                                              c.visibleCustomers[index];
                                          return ColonyCustomerCard(
                                            item: item,
                                            colonyName: c.args.colonyName,
                                            colonyArea: c.args.colonyArea,
                                            reportId: c.args.reportId,
                                            onPrimaryAction: () {
                                              if (item.status ==
                                                  ColonyCustomerStatus
                                                      .visited) {
                                                Get.toNamed(
                                                  AppRoutes.customerDetail,
                                                  arguments: CustomerDetailArgs(
                                                    name: item.name,
                                                    category: item.category,
                                                    email: item.email,
                                                    phone: item.phone,
                                                    statusLabel: 'Visited',
                                                    statusDateLabel:
                                                        item.statusDateLabel,
                                                    role: item.role,
                                                    colonyName:
                                                        c.args.colonyName,
                                                    colonyArea:
                                                        c.args.colonyArea,
                                                    shouldShowMachinery: true,
                                                    customerId: item.id,
                                                    reportId: c.args.reportId,
                                                  ),
                                                );
                                              } else {
                                                c.markCustomerVisited(item.id);
                                              }
                                            },
                                            onSecondaryAction: () {
                                              Get.toNamed(
                                                AppRoutes.customerDetail,
                                                arguments: CustomerDetailArgs(
                                                  name: item.name,
                                                  category: item.category,
                                                  email: item.email,
                                                  phone: item.phone,
                                                  statusLabel:
                                                      item.status ==
                                                          ColonyCustomerStatus
                                                              .visited
                                                      ? 'Visited'
                                                      : 'Overdue',
                                                  statusDateLabel:
                                                      item.statusDateLabel,
                                                  role: item.role,
                                                  colonyName: c.args.colonyName,
                                                  colonyArea: c.args.colonyArea,
                                                  shouldShowNotes: true,
                                                  customerId: item.id,
                                                  reportId: c.args.reportId,
                                                ),
                                              );
                                            },
                                          );
                                        },
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
