import 'package:flutter/material.dart';
import 'package:flutter_extension/helper/colony_flow_args.dart';
import 'package:flutter_extension/helper/route_helper.dart';
import 'package:flutter_extension/model/sales_team_report_details_model.dart';
import 'package:flutter_extension/services/api_service.dart';
import 'package:flutter_extension/views/base/custom_snackbar.dart';
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
    this.isoNextService = '',
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
  String isoNextService;
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
  final ApiService apiService = ApiService();

  int tabIndex = 0;
  bool contactEditing = false;
  bool isLoading = false;

  late final TextEditingController emailCtrl;
  late final TextEditingController phoneCtrl;

  // Notes
  final List<CustomerNoteEntry> notes = <CustomerNoteEntry>[];
  String? editingNoteId;
  final TextEditingController newNoteCtrl = TextEditingController();
  final TextEditingController editNoteCtrl = TextEditingController();
  bool addNoteExpanded = true;

  // Machinery
  final List<CustomerMachineryEntry> machinery = <CustomerMachineryEntry>[];
  String? editingMachineryId;
  bool addMachineryExpanded = false;

  final TextEditingController mTypeCtrl = TextEditingController();
  final TextEditingController mBrandCtrl = TextEditingController();
  final TextEditingController mModelCtrl = TextEditingController();
  final TextEditingController mYearCtrl = TextEditingController();
  final TextEditingController mConditionCtrl = TextEditingController();
  final TextEditingController mSerialCtrl = TextEditingController();
  final TextEditingController mNextCtrl = TextEditingController();
  final TextEditingController mNoteCtrl = TextEditingController();
  // ISO date string (YYYY-MM-DD) set when user picks from date picker
  String _mNextIsoDate = '';

  final List<VisitHistoryEntry> visits = <VisitHistoryEntry>[];

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

  static const List<String> machineryModelOptions = <String>[
    'X100',
    'X150',
    'X200',
    'X200-PRO',
    'X300',
    'X500',
    'Elite',
    'Pro Series',
  ];

  static List<String> get yearOptions {
    final int current = DateTime.now().year;
    return List<String>.generate(30, (int i) => '${current - i}');
  }

  static const List<String> _monthNames = <String>[
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

  @override
  void onInit() {
    super.onInit();
    _initContactControllers();
    _seedDataFromReport();
    addMachineryExpanded = machinery.isEmpty;
  }

  void _initContactControllers() {
    final primary = _primaryCustomer();
    emailCtrl = TextEditingController(
      text: _getValidString(primary?.email, args.email),
    );
    phoneCtrl = TextEditingController(
      text: _getValidString(primary?.phone, args.phone),
    );
  }

  String _getValidString(String? val, String fallback) {
    return (val?.trim().isNotEmpty ?? false) ? val! : fallback;
  }

  SalesTeamReportCustomerModel? _primaryCustomer() {
    final report = args.reportDetails;
    return (report?.pendingCustomers?.isNotEmpty ?? false)
        ? report!.pendingCustomers!.first
        : (report?.completedCustomers?.isNotEmpty ?? false)
        ? report!.completedCustomers!.first
        : null;
  }

  void _seedDataFromReport() {
    final report = args.reportDetails;
    if (report == null) {
      _seedDummyData();
      return;
    }

    final List<SalesTeamReportCustomerModel> allCustomers = [
      ...?report.pendingCustomers,
      ...?report.completedCustomers,
    ];

    final String date = report.date ?? 'N/A';

    for (int i = 0; i < allCustomers.length; i++) {
      final c = allCustomers[i];
      _addNoteFromCustomer(c, date, i);
      _addMachineryFromCustomer(c, i);
    }

    if (notes.isEmpty) {
      notes.add(
        CustomerNoteEntry(
          id: 'n_api_empty',
          text: 'No customer records found.',
          dateLabel: date,
        ),
      );
    }

    visits.add(
      VisitHistoryEntry(
        dateLabel: date,
        summary:
            'Pending: ${report.pendingCount ?? 0}, Completed: ${report.completedCount ?? 0}, Total: ${report.totalCustomers ?? 0}',
        status: (report.isVisited ?? false) ? 'Visited' : 'Not Visited',
      ),
    );
  }

  void _addNoteFromCustomer(
    SalesTeamReportCustomerModel c,
    String date,
    int index,
  ) {
    final owner = (c.ownerName ?? '').trim();
    final company = (c.companyName ?? '').trim();
    final location = [
      c.city,
      c.state,
      c.country,
    ].where((s) => s != null && s.trim().isNotEmpty).join(', ');

    notes.add(
      CustomerNoteEntry(
        id: 'n_api_${c.id ?? index}',
        text:
            '${owner.isEmpty ? "Customer" : owner} · ${company.isEmpty ? "-" : company}\n'
            'Status: ${c.status ?? "-"}\n'
            'Location: ${location.isEmpty ? "-" : location}',
        dateLabel: date,
      ),
    );
  }

  void _addMachineryFromCustomer(SalesTeamReportCustomerModel c, int index) {
    final serialBase = c.id?.toString() ?? '${index + 1}';
    final company = (c.companyName ?? '').trim();

    machinery.add(
      CustomerMachineryEntry(
        id: 'mac_api_$serialBase',
        title: 'CNC Machine X200',
        subtitle: 'Model: X200-2023',
        note:
            'Customer: ${c.ownerName ?? '-'}. ${company.isEmpty ? '' : 'Company: $company.'}',
        type: 'CNC',
        brand: company.isEmpty ? 'Select Brand' : company,
        model: 'X200',
        purchaseYear: '2010',
        condition: 'Good',
        serial: 'SN-$serialBase',
        nextService: '25 February',
      ),
    );
  }

  void _seedDummyData() {
    notes.addAll([
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
    visits.addAll([
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
    ]);
    machinery.addAll([
      CustomerMachineryEntry(
        id: 'mac1',
        title: 'CNC Machine X200',
        subtitle: 'Model X200-PRO · Serial SN-88921',
        note: 'Running well.',
      ),
      CustomerMachineryEntry(
        id: 'mac2',
        title: 'CNC Machine X200',
        subtitle: 'Model X200-PRO · Backup unit',
        note: 'Scheduled for belt inspection.',
      ),
    ]);
  }

  @override
  void onClose() {
    for (var controller in [
      emailCtrl,
      phoneCtrl,
      newNoteCtrl,
      editNoteCtrl,
      mTypeCtrl,
      mBrandCtrl,
      mModelCtrl,
      mYearCtrl,
      mConditionCtrl,
      mSerialCtrl,
      mNextCtrl,
      mNoteCtrl,
    ]) {
      controller.dispose();
    }
    super.onClose();
  }

  void setTab(int index) {
    tabIndex = index;
    if (tabIndex == 2 && machinery.isEmpty) addMachineryExpanded = true;
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
    update();
  }

  Future<void> pickNextServiceDate(BuildContext context) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (date != null) {
      // Human-readable display in the text field
      mNextCtrl.text =
          '${date.day} ${_monthNames[date.month - 1]}, ${date.year}';
      // ISO-8601 stored for API submission
      _mNextIsoDate =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      update();
    }
  }

  Future<void> saveMachineryApi(CustomerMachineryEntry m) async {
    final int? reportId = args.reportDetails?.id;
    final int? cId = _primaryCustomer()?.id;
    if (reportId == null) return;
    // Format purchase_year: year string → 'YYYY-01-01'
    final String purchaseYearIso = '${m.purchaseYear}-01-01';
    // Use the ISO date captured during date-picker or stored in entry
    final String nextServiceIso =
        _mNextIsoDate.isNotEmpty ? _mNextIsoDate : m.isoNextService;
    try {
      await apiService.put('/sales_team/report/$reportId', <String, dynamic>{
        'mechineries': <Map<String, dynamic>>[
          <String, dynamic>{
            'customer_id': cId ?? 0,
            'type': m.type,
            'brand': m.brand,
            'model': m.model,
            'serial_number': m.serial,
            'purchase_year': purchaseYearIso,
            'condition': m.condition,
            'next_nervice': nextServiceIso,
            'note': m.note,
          },
        ],
      }, authReq: true);
      showCustomSnackBar('Machinery saved.', isError: false);
    } catch (_) {
      showCustomSnackBar('Failed to save machinery.', isError: true);
    }
  }

  // --- Notes Operations ---

  void deleteNote(String id) {
    notes.removeWhere((e) => e.id == id);
    if (editingNoteId == id) editingNoteId = null;
    update();
  }

  void beginEditNote(String id) {
    editingNoteId = id;
    final n = notes.firstWhere((e) => e.id == id);
    editNoteCtrl.text = n.text;
    addNoteExpanded = false;
    update();
  }

  void saveNoteEdit(String id) {
    final n = notes.firstWhere((e) => e.id == id);
    n.text = editNoteCtrl.text.trim();
    editingNoteId = null;
    showCustomSnackBar('Note updated.', isError: false);
    update();
  }

  void setAddNoteExpanded(bool value) {
    addNoteExpanded = value;
    if (value) editingNoteId = null;
    update();
  }

  Future<void> saveNewNote() async {
    final String text = newNoteCtrl.text.trim();
    if (text.isEmpty) return;

    final CustomerNoteEntry newNote = CustomerNoteEntry(
      id: 'n${DateTime.now().millisecondsSinceEpoch}',
      text: text,
      dateLabel: 'Today',
    );

    notes.insert(0, newNote);
    newNoteCtrl.clear();
    addNoteExpanded = false;
    update();

    final int? reportId = args.reportDetails?.id;
    final int? cId = _primaryCustomer()?.id;
    if (reportId != null) {
      try {
        await apiService.put('/sales_team/report/$reportId', <String, dynamic>{
          'notes': <Map<String, dynamic>>[
            <String, dynamic>{'customer_id': cId ?? 0, 'note': text},
          ],
        }, authReq: true);
        showCustomSnackBar('Note saved to server.', isError: false);
      } catch (_) {
        showCustomSnackBar('Failed to save note to server.', isError: true);
      }
    }
  }

  // --- Machinery Operations ---

  void deleteMachinery(String id) {
    machinery.removeWhere((e) => e.id == id);
    if (editingMachineryId == id) cancelMachineryForm();
    update();
  }

  void _clearMachineryForm() {
    for (var c in [
      mTypeCtrl,
      mBrandCtrl,
      mModelCtrl,
      mYearCtrl,
      mConditionCtrl,
      mSerialCtrl,
      mNextCtrl,
      mNoteCtrl,
    ]) {
      c.clear();
    }
    _mNextIsoDate = '';
  }

  void beginEditMachinery(String id) {
    editingMachineryId = id;
    addMachineryExpanded = false;
    final m = machinery.firstWhere((e) => e.id == id);
    mTypeCtrl.text = m.type;
    mBrandCtrl.text = m.brand;
    mModelCtrl.text = m.model;
    mYearCtrl.text = m.purchaseYear;
    mConditionCtrl.text = m.condition;
    mSerialCtrl.text = m.serial;
    mNextCtrl.text = m.nextService;
    _mNextIsoDate = m.isoNextService;
    mNoteCtrl.text = m.note;
    update();
  }

  void cancelMachineryForm() {
    editingMachineryId = null;
    _clearMachineryForm();
    update();
  }

  void saveMachineryForm() {
    final String type = mTypeCtrl.text.trim().isEmpty
        ? 'CNC'
        : mTypeCtrl.text.trim();
    final String model = mModelCtrl.text.trim().isEmpty
        ? 'X200'
        : mModelCtrl.text.trim();
    final String brand = mBrandCtrl.text.trim().isEmpty
        ? 'Acme'
        : mBrandCtrl.text.trim();

    if (editingMachineryId != null) {
      final CustomerMachineryEntry m = machinery.firstWhere(
        (CustomerMachineryEntry e) => e.id == editingMachineryId,
      );
      m.type = type;
      m.brand = brand;
      m.model = model;
      m.purchaseYear = mYearCtrl.text.trim().isEmpty
          ? m.purchaseYear
          : mYearCtrl.text.trim();
      m.condition = mConditionCtrl.text.trim().isEmpty
          ? m.condition
          : mConditionCtrl.text.trim();
      m.serial = mSerialCtrl.text.trim().isEmpty
          ? m.serial
          : mSerialCtrl.text.trim();
      m.nextService = mNextCtrl.text.trim().isEmpty
          ? m.nextService
          : mNextCtrl.text.trim();
      m.note = mNoteCtrl.text.trim().isEmpty ? m.note : mNoteCtrl.text.trim();
      m.title = '$type Machine $model';
      m.subtitle = 'Model: $model-${m.purchaseYear}';
      editingMachineryId = null;
      showCustomSnackBar('Machinery updated.', isError: false);
      _clearMachineryForm();
      update();
      saveMachineryApi(m);
    } else {
      final CustomerMachineryEntry entry = CustomerMachineryEntry(
        id: 'mac${DateTime.now().millisecondsSinceEpoch}',
        title: '$type Machine $model',
        subtitle:
            'Model: $model-${mYearCtrl.text.trim().isEmpty ? '2024' : mYearCtrl.text.trim()}',
        note: mNoteCtrl.text.trim().isEmpty ? '—' : mNoteCtrl.text.trim(),
        type: type,
        brand: brand,
        model: model,
        purchaseYear: mYearCtrl.text.trim().isEmpty
            ? '2024'
            : mYearCtrl.text.trim(),
        condition: mConditionCtrl.text.trim().isEmpty
            ? 'Good'
            : mConditionCtrl.text.trim(),
        serial: mSerialCtrl.text.trim().isEmpty
            ? 'TBD'
            : mSerialCtrl.text.trim(),
        nextService: mNextCtrl.text.trim().isEmpty
            ? 'Not set'
            : mNextCtrl.text.trim(),
        isoNextService: _mNextIsoDate,
      );
      machinery.insert(0, entry);
      addMachineryExpanded = false;
      showCustomSnackBar('Machinery added.', isError: false);
      _clearMachineryForm();
      update();
      saveMachineryApi(entry);
    }
  }

  void setAddMachineryExpanded(bool value) {
    addMachineryExpanded = value;
    if (value) {
      editingMachineryId = null;
      _clearMachineryForm();
    }
    update();
  }

  Future<void> markVisited(int id) async {
    try {
      await apiService.put("/sales_team/report/$id", {
        'is_visited': true,
      }, authReq: true);
      showCustomSnackBar("Marked as visited", isError: false);
      update();
    } catch (e) {
      showCustomSnackBar("Failed to mark as visited", isError: true);
    }
  }

  void navigateToCustomer() {
    Get.toNamed(
      AppRoutes.colonyNavigate,
      arguments: ColonyNavigateArgs(
        titleFull: args.colonyName.isNotEmpty
            ? args.colonyName
            : 'Green Valley Colony',
        area: args.colonyArea.isNotEmpty ? args.colonyArea : 'North Delhi',
        distanceKm: '1',
        etaMinutes: '6',
      ),
    );
  }
}
