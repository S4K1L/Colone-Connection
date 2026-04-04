import 'package:flutter/material.dart';
import 'package:flutter_extension/controller/colonies_controller.dart';
import 'package:flutter_extension/util/app_colors.dart';
import 'package:flutter_extension/views/base/app_text.dart';
import 'package:flutter_extension/views/screen/colonies/widgets/colony_flow_header.dart';
import 'package:flutter_extension/views/screen/colonies/widgets/colonies_filter_bar.dart';
import 'package:flutter_extension/views/screen/colonies/widgets/form_map_preview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class AddColonyScreen extends StatefulWidget {
  const AddColonyScreen({super.key});

  @override
  State<AddColonyScreen> createState() => _AddColonyScreenState();
}

class _AddColonyScreenState extends State<AddColonyScreen> {
  final TextEditingController _nameCtrl = TextEditingController();
  ColonyVisitFilter _filter = ColonyVisitFilter.all;
  DateTime _selectedDate = DateTime(2026, 3, 5);
  String? _region;

  static const List<String> _regions = <String>[
    'North District',
    'East Zone',
    'West Block',
    'Central Area',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) {
    const List<String> months = <String>[
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${d.day} ${months[d.month - 1]}, ${d.year}';
  }

  Future<void> _pickDate() async {
    final BuildContext? ctx = Get.context;
    if (ctx == null) return;
    final DateTime? picked = await showDatePicker(
      context: ctx,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.green25,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ColonyFlowHeader(
              onBack: () => Get.back(),
              title: 'Add Colony',
              subtitle: 'Create a new colony',
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(26.r),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 0),
                      child: ColoniesFilterBar(
                        filter: _filter,
                        dateLabel: _formatDate(_selectedDate),
                        onFilterSelected: (ColonyVisitFilter v) =>
                            setState(() => _filter = v),
                        onPickDate: _pickDate,
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 20.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            const AppText.smd(
                              'Colony Name',
                              fontSize: 14,
                              color: AppColors.grey500,
                              useResponsiveSize: true,
                            ),
                            SizedBox(height: 8.h),
                            TextField(
                              controller: _nameCtrl,
                              decoration: InputDecoration(
                                hintText: 'Enter Colony name',
                                hintStyle: TextStyle(
                                  color: AppColors.grey300,
                                  fontSize: 14.sp,
                                ),
                                filled: true,
                                fillColor: AppColors.white,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 14.w,
                                  vertical: 14.h,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide: const BorderSide(
                                    color: AppColors.grey100,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide: const BorderSide(
                                    color: AppColors.grey100,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 18.h),
                            const AppText.smd(
                              'Region / District',
                              fontSize: 14,
                              color: AppColors.grey500,
                              useResponsiveSize: true,
                            ),
                            SizedBox(height: 8.h),
                            DropdownButtonFormField<String>(
                              initialValue: _region,
                              hint: Text(
                                'Select a sales representative',
                                style: TextStyle(
                                  color: AppColors.grey300,
                                  fontSize: 14.sp,
                                ),
                              ),
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 14.w,
                                  vertical: 14.h,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide: const BorderSide(
                                    color: AppColors.grey100,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide: const BorderSide(
                                    color: AppColors.grey100,
                                  ),
                                ),
                              ),
                              items: _regions
                                  .map(
                                    (String e) => DropdownMenuItem<String>(
                                      value: e,
                                      child: Text(e),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (String? v) =>
                                  setState(() => _region = v),
                            ),
                            SizedBox(height: 18.h),
                            const AppText.smd(
                              'GPS Location',
                              fontSize: 14,
                              color: AppColors.grey500,
                              useResponsiveSize: true,
                            ),
                            SizedBox(height: 8.h),
                            const FormMapPreview(),
                            SizedBox(height: 24.h),
                            _FormBottomBar(
                              onCancel: () => Get.back(),
                              onSave: () {
                                Get.back();
                                Get.snackbar(
                                  'Colonies',
                                  'Colony saved (demo).',
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormBottomBar extends StatelessWidget {
  const _FormBottomBar({
    required this.onCancel,
    required this.onSave,
  });

  final VoidCallback onCancel;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 3,
          child: OutlinedButton(
            onPressed: onCancel,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.grey500,
              side: const BorderSide(color: AppColors.grey100),
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: const AppText.smd(
              'Cancel',
              fontSize: 15,
              color: AppColors.grey500,
              useResponsiveSize: true,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          flex: 6,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onSave,
              borderRadius: BorderRadius.circular(12.r),
              child: Ink(
                padding: EdgeInsets.symmetric(vertical: 14.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  gradient: const LinearGradient(
                    colors: <Color>[
                      Color(0xFF2EAD4B),
                      Color(0xFF4BC76A),
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const AppText.smd(
                      'Save Now',
                      fontSize: 15,
                      color: AppColors.white,
                      useResponsiveSize: true,
                    ),
                    SizedBox(width: 6.w),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.white,
                      size: 20.sp,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
