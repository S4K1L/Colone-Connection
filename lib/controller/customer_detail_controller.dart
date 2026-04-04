import 'package:flutter/material.dart';
import 'package:flutter_extension/helper/colony_flow_args.dart';
import 'package:flutter_extension/helper/route_helper.dart';
import 'package:get/get.dart';

class CustomerNoteEntry {
  CustomerNoteEntry({
    required this.id,
    required this.text,
    required this.dateLabel,
  });

  final String id;
  String text;
  final String dateLabel;
}

class CustomerMachineryEntry {
  CustomerMachineryEntry({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.note,
    this.type = 'CNC',
    this.brand = 'Acme',
    this.model = 'X200',
    this.purchaseYear = '2022',
    this.condition = 'Good',
    this.serial = 'SN-88921',
    this.nextService = '12 Apr, 2026',
  });

  final String id;
  String title;
  String subtitle;
  String note;
  String type;
  String brand;
  String model;
  String purchaseYear;
  String condition;
  String serial;
  String nextService;
}

class VisitHistoryEntry {
  const VisitHistoryEntry({
    required this.dateLabel,
    required this.summary,
    required this.status,
  });

  final String dateLabel;
  final String summary;
  final String status;
}

class CustomerDetailController extends GetxController {
  CustomerDetailController({required this.args});

  final CustomerDetailArgs args;

  int tabIndex = 0;

  bool contactEditing = false;
  late final TextEditingController emailCtrl;
  late final TextEditingController phoneCtrl;

  final List<CustomerNoteEntry> notes = <CustomerNoteEntry>[];
  String? editingNoteId;
  final TextEditingController newNoteCtrl = TextEditingController();
  final TextEditingController editNoteCtrl = TextEditingController();
  bool addNoteExpanded = true;

  final List<CustomerMachineryEntry> machinery = <CustomerMachineryEntry>[];
  String? editingMachineryId;
  bool addMachineryExpanded = true;

  final TextEditingController mTypeCtrl = TextEditingController();
  final TextEditingController mBrandCtrl = TextEditingController();
  final TextEditingController mModelCtrl = TextEditingController();
  final TextEditingController mYearCtrl = TextEditingController();
  final TextEditingController mConditionCtrl = TextEditingController();
  final TextEditingController mSerialCtrl = TextEditingController();
  final TextEditingController mNextCtrl = TextEditingController();
  final TextEditingController mNoteCtrl = TextEditingController();

  final List<VisitHistoryEntry> visits = <VisitHistoryEntry>[
    const VisitHistoryEntry(
      dateLabel: '5 March, 2026',
      summary: 'Routine visit — stock check completed',
      status: 'Visited',
    ),
    const VisitHistoryEntry(
      dateLabel: '12 Feb, 2026',
      summary: 'Follow-up on machinery order',
      status: 'Visited',
    ),
    const VisitHistoryEntry(
      dateLabel: '28 Jan, 2026',
      summary: 'Missed appointment',
      status: 'No show',
    ),
  ];

  static const List<String> machineryTypeOptions = <String>[
    'CNC',
    'Lathe',
    'Press',
    'Welder',
  ];
  static const List<String> machineryBrandOptions = <String>[
    'Acme',
    'TechPro',
    'SteelMax',
  ];
  static const List<String> conditionOptions = <String>[
    'Good',
    'Fair',
    'Needs service',
  ];

  @override
  void onInit() {
    super.onInit();
    emailCtrl = TextEditingController(text: args.email);
    phoneCtrl = TextEditingController(text: args.phone);
    notes.addAll(<CustomerNoteEntry>[
      CustomerNoteEntry(
        id: 'n1',
        text: 'Customer prefers morning visits.',
        dateLabel: '02 Feb, 2025',
      ),
      CustomerNoteEntry(
        id: 'n2',
        text: 'Follow up on spare parts order.',
        dateLabel: '15 Jan, 2025',
      ),
    ]);
    machinery.addAll(<CustomerMachineryEntry>[
      CustomerMachineryEntry(
        id: 'mac1',
        title: 'CNC Machine X200',
        subtitle: 'Model X200-PRO · Serial SN-88921',
        note: 'Running well after last service.',
      ),
      CustomerMachineryEntry(
        id: 'mac2',
        title: 'CNC Machine X200',
        subtitle: 'Model X200-PRO · Backup unit',
        note: 'Scheduled for belt inspection next month.',
      ),
    ]);
  }

  @override
  void onClose() {
    emailCtrl.dispose();
    phoneCtrl.dispose();
    newNoteCtrl.dispose();
    editNoteCtrl.dispose();
    mTypeCtrl.dispose();
    mBrandCtrl.dispose();
    mModelCtrl.dispose();
    mYearCtrl.dispose();
    mConditionCtrl.dispose();
    mSerialCtrl.dispose();
    mNextCtrl.dispose();
    mNoteCtrl.dispose();
    super.onClose();
  }

  void setTab(int index) {
    tabIndex = index;
    update();
  }

  void setContactEditing(bool value) {
    contactEditing = value;
    if (!value) {
      emailCtrl.text = args.email;
      phoneCtrl.text = args.phone;
    }
    update();
  }

  void saveContact() {
    contactEditing = false;
    Get.snackbar('Contact', 'Saved (demo).');
    update();
  }

  void deleteNote(String id) {
    notes.removeWhere((CustomerNoteEntry e) => e.id == id);
    if (editingNoteId == id) editingNoteId = null;
    update();
  }

  void beginEditNote(String id) {
    editingNoteId = id;
    final CustomerNoteEntry n =
        notes.firstWhere((CustomerNoteEntry e) => e.id == id);
    editNoteCtrl.text = n.text;
    addNoteExpanded = false;
    update();
  }

  void saveNoteEdit(String id) {
    final CustomerNoteEntry n =
        notes.firstWhere((CustomerNoteEntry e) => e.id == id);
    n.text = editNoteCtrl.text.trim();
    editingNoteId = null;
    Get.snackbar('Notes', 'Note updated (demo).');
    update();
  }

  void setAddNoteExpanded(bool value) {
    addNoteExpanded = value;
    if (value) editingNoteId = null;
    update();
  }

  void saveNewNote() {
    final String t = newNoteCtrl.text.trim();
    if (t.isEmpty) return;
    notes.insert(
      0,
      CustomerNoteEntry(
        id: 'n${DateTime.now().millisecondsSinceEpoch}',
        text: t,
        dateLabel: 'Today',
      ),
    );
    newNoteCtrl.clear();
    Get.snackbar('Notes', 'Note added (demo).');
    update();
  }

  void deleteMachinery(String id) {
    machinery.removeWhere((CustomerMachineryEntry e) => e.id == id);
    if (editingMachineryId == id) {
      editingMachineryId = null;
      _clearMachineryForm();
    }
    update();
  }

  void _clearMachineryForm() {
    mTypeCtrl.clear();
    mBrandCtrl.clear();
    mModelCtrl.clear();
    mYearCtrl.clear();
    mConditionCtrl.clear();
    mSerialCtrl.clear();
    mNextCtrl.clear();
    mNoteCtrl.clear();
  }

  void _fillMachineryForm(CustomerMachineryEntry m) {
    mTypeCtrl.text = m.type;
    mBrandCtrl.text = m.brand;
    mModelCtrl.text = m.model;
    mYearCtrl.text = m.purchaseYear;
    mConditionCtrl.text = m.condition;
    mSerialCtrl.text = m.serial;
    mNextCtrl.text = m.nextService;
    mNoteCtrl.text = m.note;
  }

  void beginEditMachinery(String id) {
    editingMachineryId = id;
    addMachineryExpanded = false;
    final CustomerMachineryEntry m =
        machinery.firstWhere((CustomerMachineryEntry e) => e.id == id);
    _fillMachineryForm(m);
    update();
  }

  void cancelMachineryForm() {
    editingMachineryId = null;
    _clearMachineryForm();
    update();
  }

  void saveMachineryForm() {
    if (editingMachineryId != null) {
      final CustomerMachineryEntry m = machinery
          .firstWhere((CustomerMachineryEntry e) => e.id == editingMachineryId);
      m.type = mTypeCtrl.text.trim().isEmpty ? m.type : mTypeCtrl.text.trim();
      m.brand = mBrandCtrl.text.trim().isEmpty ? m.brand : mBrandCtrl.text.trim();
      m.model = mModelCtrl.text.trim().isEmpty ? m.model : mModelCtrl.text.trim();
      m.purchaseYear =
          mYearCtrl.text.trim().isEmpty ? m.purchaseYear : mYearCtrl.text.trim();
      m.condition = mConditionCtrl.text.trim().isEmpty
          ? m.condition
          : mConditionCtrl.text.trim();
      m.serial = mSerialCtrl.text.trim().isEmpty ? m.serial : mSerialCtrl.text.trim();
      m.nextService =
          mNextCtrl.text.trim().isEmpty ? m.nextService : mNextCtrl.text.trim();
      m.note = mNoteCtrl.text.trim().isEmpty ? m.note : mNoteCtrl.text.trim();
      m.title = '${m.type} Machine ${m.model}';
      m.subtitle = 'Model ${m.model}-PRO · Serial ${m.serial}';
      editingMachineryId = null;
      Get.snackbar('Machinery', 'Updated (demo).');
    } else {
      final String brand = mBrandCtrl.text.trim().isEmpty ? 'Acme' : mBrandCtrl.text.trim();
      final String model = mModelCtrl.text.trim().isEmpty ? 'X200' : mModelCtrl.text.trim();
      final String type = mTypeCtrl.text.trim().isEmpty ? 'CNC' : mTypeCtrl.text.trim();
      machinery.insert(
        0,
        CustomerMachineryEntry(
          id: 'mac${DateTime.now().millisecondsSinceEpoch}',
          title: '$type Machine $model',
          subtitle:
              'Model $model-PRO · Serial ${mSerialCtrl.text.trim().isEmpty ? "TBD" : mSerialCtrl.text.trim()}',
          note: mNoteCtrl.text.trim().isEmpty ? '—' : mNoteCtrl.text.trim(),
          type: type,
          brand: brand,
          model: model,
          purchaseYear:
              mYearCtrl.text.trim().isEmpty ? '2024' : mYearCtrl.text.trim(),
          condition: mConditionCtrl.text.trim().isEmpty
              ? 'Good'
              : mConditionCtrl.text.trim(),
          serial: mSerialCtrl.text.trim().isEmpty ? 'TBD' : mSerialCtrl.text.trim(),
          nextService: mNextCtrl.text.trim().isEmpty
              ? 'Not set'
              : mNextCtrl.text.trim(),
        ),
      );
      addMachineryExpanded = false;
      Get.snackbar('Machinery', 'Added (demo).');
    }
    _clearMachineryForm();
    update();
  }

  void setAddMachineryExpanded(bool value) {
    addMachineryExpanded = value;
    if (value) {
      editingMachineryId = null;
      _clearMachineryForm();
      mTypeCtrl.text = 'CNC';
      mBrandCtrl.text = 'Acme';
      mModelCtrl.text = 'X200';
      mYearCtrl.text = '2022';
      mConditionCtrl.text = 'Good';
    }
    update();
  }

  void markVisited() {
    Get.snackbar('Visit', 'Marked as visited (demo).');
  }

  void navigateToCustomer() {
    final String full = args.colonyName.isNotEmpty
        ? args.colonyName
        : 'Green Valley Colony';
    final String area =
        args.colonyArea.isNotEmpty ? args.colonyArea : 'North Delhi';
    final String typo = full.replaceAll('Colony', 'Colone');
    Get.toNamed(
      AppRoutes.colonyNavigate,
      arguments: ColonyNavigateArgs(
        titleTypo: typo,
        titleFull: full,
        area: area,
        distanceKm: '1',
        etaMinutes: '6',
      ),
    );
  }
}
