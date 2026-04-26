import 'package:flutter/material.dart';
import 'package:flutter_extension/controller/colony_customers_controller.dart';
import 'package:flutter_extension/model/colony_customer_model.dart';
import 'package:flutter_extension/helper/colony_flow_args.dart';
import 'package:flutter_extension/helper/route_helper.dart';
import 'package:flutter_extension/util/app_colors.dart';
import 'package:flutter_extension/views/screen/colonies/widgets/colony_customer_card.dart';
import 'package:flutter_extension/views/screen/colonies/widgets/colony_customer_filter_bar.dart';
import 'package:flutter_extension/views/screen/colonies/widgets/colony_flow_header.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ColonyCustomersScreen extends StatefulWidget {
  const ColonyCustomersScreen({super.key});

  @override
  State<ColonyCustomersScreen> createState() => _ColonyCustomersScreenState();
}

class _ColonyCustomersScreenState extends State<ColonyCustomersScreen> {
  @override
  void initState() {
    super.initState();
    final ColonyCustomersArgs args = Get.arguments is ColonyCustomersArgs
        ? Get.arguments as ColonyCustomersArgs
        : const ColonyCustomersArgs(
            colonyId: '0',
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
                          child: ListView.builder(
                            padding: EdgeInsets.fromLTRB(
                              16.w,
                              8.h,
                              16.w,
                              24.h,
                            ),
                            itemCount: c.visibleCustomers.length,
                            itemBuilder: (BuildContext context, int index) {
                              final ColonyCustomerItem item =
                                  c.visibleCustomers[index];
                              return ColonyCustomerCard(
                                item: item,
                                colonyName: c.args.colonyName,
                                colonyArea: c.args.colonyArea,
                                onPrimaryAction: () => Get.snackbar(
                                  item.name,
                                  '${item.primaryActionLabel} (demo)',
                                ),
                                onSecondaryAction: () => Get.snackbar(
                                  item.name,
                                  '${item.secondaryActionLabel} (demo)',
                                ),
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
          },
        ),
      ),
    );
  }
}
