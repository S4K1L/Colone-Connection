import 'package:flutter/material.dart';
import 'package:flutter_extension/controller/customer_detail_controller.dart';
import 'package:flutter_extension/util/app_colors.dart';
import 'package:flutter_extension/views/base/app_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

/// White card inner content for the selected tab.
class CustomerDetailTabPages extends StatelessWidget {
  const CustomerDetailTabPages({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CustomerDetailController>(
      builder: (CustomerDetailController c) {
        switch (c.tabIndex) {
          case 1:
            return _NotesTab(c: c);
          case 2:
            return _MachineryTab(c: c);
          case 3:
            return _VisitHistoryTab(c: c);
          case 0:
          default:
            return _ContactTab(c: c);
        }
      },
    );
  }
}

class _ContactTab extends StatelessWidget {
  const _ContactTab({required this.c});

  final CustomerDetailController c;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(18.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AppText.smd(
            c.args.name,
            fontSize: 18,
            color: AppColors.grey500,
            useResponsiveSize: true,
          ),
          SizedBox(height: 4.h),
          AppText.rg(
            c.args.category,
            fontSize: 13,
            color: AppColors.grey300,
            useResponsiveSize: true,
          ),
          SizedBox(height: 18.h),
          if (!c.contactEditing) ...<Widget>[
            _ContactReadRow(
              text: c.emailCtrl.text,
              icon: Icons.mail_outline_rounded,
            ),
            SizedBox(height: 12.h),
            _ContactReadRow(
              text: c.phoneCtrl.text,
              icon: Icons.phone_outlined,
            ),
          ] else ...<Widget>[
            _ContactField(
              controller: c.emailCtrl,
              icon: Icons.mail_outline_rounded,
              hint: 'Email',
            ),
            SizedBox(height: 12.h),
            _ContactField(
              controller: c.phoneCtrl,
              icon: Icons.phone_outlined,
              hint: 'Phone',
              keyboard: TextInputType.phone,
            ),
          ],
          SizedBox(height: 22.h),
          _GreenActionButton(
            label: c.contactEditing ? 'Save Now' : 'Edit Now',
            onTap: () {
              if (c.contactEditing) {
                c.saveContact();
              } else {
                c.setContactEditing(true);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _ContactReadRow extends StatelessWidget {
  const _ContactReadRow({required this.text, required this.icon});

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: AppText.rg(
            text,
            fontSize: 14,
            color: AppColors.grey500,
            useResponsiveSize: true,
          ),
        ),
        Icon(icon, size: 20.sp, color: AppColors.grey300),
      ],
    );
  }
}

class _ContactField extends StatelessWidget {
  const _ContactField({
    required this.controller,
    required this.icon,
    required this.hint,
    this.keyboard,
  });

  final TextEditingController controller;
  final IconData icon;
  final String hint;
  final TextInputType? keyboard;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.grey300, size: 20.sp),
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.grey300, fontSize: 14.sp),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.grey100),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.grey100),
        ),
      ),
    );
  }
}

class _NotesTab extends StatelessWidget {
  const _NotesTab({required this.c});

  final CustomerDetailController c;

  static const Color _noteTint = Color(0xFFEEF8ED);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(18.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (final CustomerNoteEntry n in c.notes) ...<Widget>[
            if (c.editingNoteId == n.id)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: AppText.rg(
                          n.dateLabel,
                          fontSize: 11,
                          color: AppColors.grey300,
                          useResponsiveSize: true,
                        ),
                      ),
                      IconButton(
                        onPressed: () => c.saveNoteEdit(n.id),
                        icon: Icon(
                          Icons.check_rounded,
                          color: AppColors.green600,
                          size: 22.sp,
                        ),
                      ),
                    ],
                  ),
                  TextField(
                    controller: c.editNoteCtrl,
                    maxLines: 4,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(12.w),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(color: AppColors.grey100),
                      ),
                    ),
                  ),
                ],
              )
            else
              Container(
                margin: EdgeInsets.only(bottom: 12.h),
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: _noteTint,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: AppText.rg(
                            n.dateLabel,
                            fontSize: 11,
                            color: AppColors.grey400,
                            useResponsiveSize: true,
                          ),
                        ),
                        IconButton(
                          onPressed: () => c.deleteNote(n.id),
                          icon: Icon(
                            Icons.delete_outline_rounded,
                            size: 20.sp,
                            color: AppColors.grey300,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(
                            minWidth: 36.w,
                            minHeight: 36.w,
                          ),
                        ),
                        IconButton(
                          onPressed: () => c.beginEditNote(n.id),
                          icon: Icon(
                            Icons.edit_outlined,
                            size: 20.sp,
                            color: AppColors.grey400,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(
                            minWidth: 36.w,
                            minHeight: 36.w,
                          ),
                        ),
                      ],
                    ),
                    AppText.rg(
                      n.text,
                      fontSize: 13,
                      color: AppColors.grey500,
                      useResponsiveSize: true,
                    ),
                  ],
                ),
              ),
          ],
          _ExpansionHeader(
            title: 'Add New Note',
            expanded: c.addNoteExpanded,
            onTap: () => c.setAddNoteExpanded(!c.addNoteExpanded),
          ),
          if (c.addNoteExpanded) ...<Widget>[
            SizedBox(height: 10.h),
            TextField(
              controller: c.newNoteCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Write your note…',
                hintStyle: TextStyle(
                  color: AppColors.grey300,
                  fontSize: 14.sp,
                ),
                contentPadding: EdgeInsets.all(12.w),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: AppColors.grey100),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            _GreenActionButton(
              label: 'Save Now',
              onTap: c.saveNewNote,
            ),
          ],
        ],
      ),
    );
  }
}

class _MachineryTab extends StatelessWidget {
  const _MachineryTab({required this.c});

  final CustomerDetailController c;

  static const Color _noteTint = Color(0xFFEEF8ED);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(18.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (final CustomerMachineryEntry m in c.machinery)
            if (c.editingMachineryId == m.id)
              Padding(
                padding: EdgeInsets.only(bottom: 14.h),
                child: _MachineryForm(
                  c: c,
                  title: 'Edit machinery',
                  onSave: () => c.saveMachineryForm(),
                  onCancel: () => c.cancelMachineryForm(),
                ),
              )
            else
              Container(
                margin: EdgeInsets.only(bottom: 14.h),
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: AppColors.grey50),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              AppText.smd(
                                m.title,
                                fontSize: 15,
                                color: AppColors.grey500,
                                useResponsiveSize: true,
                              ),
                              SizedBox(height: 4.h),
                              AppText.rg(
                                m.subtitle,
                                fontSize: 12,
                                color: AppColors.grey300,
                                useResponsiveSize: true,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => c.deleteMachinery(m.id),
                          icon: Icon(
                            Icons.delete_outline_rounded,
                            size: 20.sp,
                            color: AppColors.grey300,
                          ),
                        ),
                        IconButton(
                          onPressed: () => c.beginEditMachinery(m.id),
                          icon: Icon(
                            Icons.edit_outlined,
                            size: 20.sp,
                            color: AppColors.grey400,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: _noteTint,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: AppText.rg(
                        'Note: ${m.note}',
                        fontSize: 12,
                        color: AppColors.grey500,
                        useResponsiveSize: true,
                      ),
                    ),
                  ],
                ),
              ),
          _ExpansionHeader(
            title: 'Add New Machineries',
            expanded: c.addMachineryExpanded,
            onTap: () => c.setAddMachineryExpanded(!c.addMachineryExpanded),
          ),
          if (c.addMachineryExpanded) ...<Widget>[
            SizedBox(height: 12.h),
            _MachineryForm(
              c: c,
              title: 'New machinery',
              onSave: () => c.saveMachineryForm(),
              onCancel: () {
                c.setAddMachineryExpanded(false);
                c.cancelMachineryForm();
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _MachineryForm extends StatelessWidget {
  const _MachineryForm({
    required this.c,
    required this.title,
    required this.onSave,
    required this.onCancel,
  });

  final CustomerDetailController c;
  final String title;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        AppText.smd(
          title,
          fontSize: 14,
          color: AppColors.grey400,
          useResponsiveSize: true,
        ),
        SizedBox(height: 10.h),
        _LabeledField(label: 'Type', child: _machineryDropdown(
          context,
          value: c.mTypeCtrl.text.isEmpty ? null : c.mTypeCtrl.text,
          items: CustomerDetailController.machineryTypeOptions,
          onChanged: (String? v) {
            c.mTypeCtrl.text = v ?? '';
            c.update();
          },
        )),
        _LabeledField(label: 'Brand', child: _machineryDropdown(
          context,
          value: c.mBrandCtrl.text.isEmpty ? null : c.mBrandCtrl.text,
          items: CustomerDetailController.machineryBrandOptions,
          onChanged: (String? v) {
            c.mBrandCtrl.text = v ?? '';
            c.update();
          },
        )),
        _LabeledField(
          label: 'Model',
          child: TextField(
            controller: c.mModelCtrl,
            decoration: _fieldDeco('Model'),
          ),
        ),
        _LabeledField(
          label: 'Purchase Year',
          child: TextField(
            controller: c.mYearCtrl,
            keyboardType: TextInputType.number,
            decoration: _fieldDeco('e.g. 2022'),
          ),
        ),
        _LabeledField(label: 'Condition', child: _machineryDropdown(
          context,
          value: c.mConditionCtrl.text.isEmpty ? null : c.mConditionCtrl.text,
          items: CustomerDetailController.conditionOptions,
          onChanged: (String? v) {
            c.mConditionCtrl.text = v ?? '';
            c.update();
          },
        )),
        _LabeledField(
          label: 'Serial Number',
          child: TextField(
            controller: c.mSerialCtrl,
            decoration: _fieldDeco('Serial number'),
          ),
        ),
        _LabeledField(
          label: 'Next Service',
          child: TextField(
            controller: c.mNextCtrl,
            decoration: _fieldDeco('e.g. 12 Apr, 2026'),
          ),
        ),
        _LabeledField(
          label: 'Note',
          child: TextField(
            controller: c.mNoteCtrl,
            maxLines: 3,
            decoration: _fieldDeco('Note'),
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: <Widget>[
            TextButton(onPressed: onCancel, child: const Text('Cancel')),
            const Spacer(),
          ],
        ),
        _GreenActionButton(label: 'Save Now', onTap: onSave),
      ],
    );
  }

  InputDecoration _fieldDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.grey300, fontSize: 13.sp),
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: AppColors.grey100),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: AppColors.grey100),
      ),
    );
  }

  Widget _machineryDropdown(
    BuildContext context, {
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final String? v = value != null && items.contains(value) ? value : null;
    return DropdownButtonFormField<String>(
      initialValue: v,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.grey100),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.grey100),
        ),
      ),
      items: items
          .map(
            (String e) => DropdownMenuItem<String>(
              value: e,
              child: Text(e),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AppText.smd(
            label,
            fontSize: 13,
            color: AppColors.grey500,
            useResponsiveSize: true,
          ),
          SizedBox(height: 6.h),
          child,
        ],
      ),
    );
  }
}

class _VisitHistoryTab extends StatelessWidget {
  const _VisitHistoryTab({required this.c});

  final CustomerDetailController c;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.all(18.w),
      itemCount: c.visits.length,
      separatorBuilder: (_, __) => Divider(height: 24.h, color: AppColors.grey50),
      itemBuilder: (BuildContext context, int i) {
        final VisitHistoryEntry v = c.visits[i];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                AppText.smd(
                  v.dateLabel,
                  fontSize: 13,
                  color: AppColors.grey500,
                  useResponsiveSize: true,
                ),
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: AppColors.green50,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: AppText.rg(
                    v.status,
                    fontSize: 11,
                    color: AppColors.green700,
                    useResponsiveSize: true,
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            AppText.rg(
              v.summary,
              fontSize: 13,
              color: AppColors.grey300,
              useResponsiveSize: true,
            ),
          ],
        );
      },
    );
  }
}

class _ExpansionHeader extends StatelessWidget {
  const _ExpansionHeader({
    required this.title,
    required this.expanded,
    required this.onTap,
  });

  final String title;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.grey50,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          child: Row(
            children: <Widget>[
              Expanded(
                child: AppText.smd(
                  title,
                  fontSize: 14,
                  color: AppColors.grey500,
                  useResponsiveSize: true,
                ),
              ),
              Icon(
                expanded
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                color: AppColors.grey400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GreenActionButton extends StatelessWidget {
  const _GreenActionButton({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
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
              AppText.smd(
                label,
                fontSize: 15,
                color: AppColors.white,
                useResponsiveSize: true,
              ),
              SizedBox(width: 8.w),
              Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.white,
                size: 20.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
