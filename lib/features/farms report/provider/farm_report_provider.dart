import 'package:flutter/material.dart';
import 'package:ikuku/features/batches/model/chicken_batch_model.dart';
import 'package:ikuku/features/farms%20report/%20model/report_model.dart';
import 'package:ikuku/shared/offline/offline_services.dart';
import 'package:uuid/uuid.dart';

class FarmReportProvider extends ChangeNotifier {
  FarmReportProvider({SyncEngine? sync}) : _syncOverride = sync;

  final SyncEngine? _syncOverride;
  SyncEngine get _sync => _syncOverride ?? OfflineServices.instance.sync;

  bool _isloading = false;
  bool get isloading => _isloading;

  String? _editingReportId;
  String? _editingDailyRecordId;
  bool get isEditing => _editingReportId != null;
  int _chickensCurled = 0;
  int _chickensSold = 0;
  int _chickensDied = 0;
  int _chickensStolen = 0;
  int get chickensCurled => _chickensCurled;
  int get chickensSold => _chickensSold;
  int get chickensDied => _chickensDied;
  int get chickensStolen => _chickensStolen;

  int _eggsCollected = 0;
  int _eggsSmall = 0;
  int _eggsDeformed = 0;
  int _eggsStandard = 0;
  int _eggsBroken = 0;

  int get eggsCollected => _eggsCollected;
  int get eggsSmall => _eggsSmall;
  int get eggsDeformed => _eggsDeformed;
  int get eggsStandard => _eggsStandard;
  int get eggsBroken => _eggsBroken;

  bool _chickenReduction = false;
  bool _eggsCollection = false;
  bool _gradeEggs = false;
  String? _notes;
  String? get notes => _notes;

  List<Map<String, dynamic>> _feedsUsed = [];
  List<Map<String, dynamic>> _vaccinesUsed = [];
  List<Map<String, dynamic>> _otherMaterialsUsed = [];
  List<Map<String, dynamic>> _lossesBreakdown = [];

  List<Map<String, dynamic>> get feedsUsed => _feedsUsed;
  List<Map<String, dynamic>> get vaccinesUsed => _vaccinesUsed;
  List<Map<String, dynamic>> get otherMaterialsUsed => _otherMaterialsUsed;
  int _salesAmount = 0;
  int _gainsAmount = 0;
  int get salesAmount => _salesAmount;
  int get gainsAmount => _gainsAmount;

  void updateChicken({int? curled, int? sold, int? died, int? stolen}) {
    if (curled != null) _chickensCurled = curled;
    if (sold != null) _chickensSold = sold;
    if (died != null) _chickensDied = died;
    if (stolen != null) _chickensStolen = stolen;
    _chickenReduction =
        (_chickensCurled + _chickensSold + _chickensDied + _chickensStolen) > 0;
    notifyListeners();
  }

  void updateEggMetrics({
    int? collected,
    int? small,
    int? deformed,
    int? standard,
    int? broken,
    bool? grade,
  }) {
    if (collected != null) _eggsCollected = collected;
    if (small != null) _eggsSmall = small;
    if (deformed != null) _eggsDeformed = deformed;
    if (standard != null) _eggsStandard = standard;
    if (broken != null) _eggsBroken = broken;
    if (grade != null) _gradeEggs = grade;
    _eggsCollection = _eggsCollected > 0;
    notifyListeners();
  }

  void updateFeeds(List<Map<String, dynamic>> feeds) {
    _feedsUsed = feeds;
    notifyListeners();
  }

  ChickenBatch? _batch;
  ChickenBatch? get batch => _batch;

  void setBatch(ChickenBatch batch) {
    _batch = batch;
    notifyListeners();
  }

  void updateVaccines(List<Map<String, dynamic>> vaccines) {
    _vaccinesUsed = vaccines;
    notifyListeners();
  }

  void updateFinancialsAndNotes({int? sales, int? gains, String? notes}) {
    if (sales != null) _salesAmount = sales;
    if (gains != null) _gainsAmount = gains;
    if (notes != null) _notes = notes;
    notifyListeners();
  }

  DateTime _reportDate = DateTime.now();
  DateTime get reportDate => _reportDate;

  bool get gradeEggs => _gradeEggs;

  void setReportDate(DateTime date) {
    _reportDate = date;
    notifyListeners();
  }

  void updateOtherMaterials(List<Map<String, dynamic>> materials) {
    _otherMaterialsUsed = materials;
    notifyListeners();
  }

  //load a previously-saved report into the form for editing
  void loadReportForEditing(Map<String, dynamic> data) {
    _editingReportId = data['id'] as String?;
    _editingDailyRecordId = data['daily_record_id'] as String?;

    _chickenReduction = data['chicken_reduction'] as bool? ?? false;
    _chickensCurled = _toInt(data['chickens_curled']);
    _chickensSold = _toInt(data['chickens_sold']);
    _chickensDied = _toInt(data['chickens_died']);
    _chickensStolen = _toInt(data['chickens_stolen']);

    _eggsCollection = data['egg_collection'] as bool? ?? false;
    _eggsCollected = _toInt(data['eggs_collected']);
    _gradeEggs = data['grade_eggs'] as bool? ?? false;
    _eggsSmall = _toInt(data['eggs_small']);
    _eggsDeformed = _toInt(data['eggs_deformed']);
    _eggsStandard = _toInt(data['eggs_standard']);
    _eggsBroken = _toInt(data['eggs_broken']);

    _notes = data['notes'] as String?;
    _feedsUsed = List<Map<String, dynamic>>.from(data['feeds_used'] ?? []);
    _vaccinesUsed = List<Map<String, dynamic>>.from(
      data['vaccines_used'] ?? [],
    );
    _otherMaterialsUsed = List<Map<String, dynamic>>.from(
      data['other_materials_used'] ?? [],
    );
    _salesAmount = _toInt(data['sales_amount']);
    _lossesBreakdown = List<Map<String, dynamic>>.from(
      data['losses_breakdown'] ?? [],
    );
    _gainsAmount = _toInt(data['gains_amount']);

    final dailyRecord = data['daily_records'] as Map<String, dynamic>?;
    final rawDate = dailyRecord?['report_date'] as String?;
    if (rawDate != null) {
      _reportDate = DateTime.parse(rawDate);
    }

    notifyListeners();
  }

  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  /// Saves the report on the device and queues it for the server, so it
  /// works the same offline. Returns false only if nobody is signed in or
  /// the device itself failed to save.
  Future<bool> submitDailyReport({required String batchId}) async {
    final userId = _sync.currentUserId;
    if (userId == null) return false;

    _isloading = true;
    notifyListeners();

    try {
      final dateStr = _reportDate.toIso8601String().split('T')[0];
      final editingReportId = _editingReportId;
      final editingDailyRecordId = _editingDailyRecordId;
      final dailyRecordId = editingDailyRecordId ?? const Uuid().v4();

      final report = Report(
        id: editingReportId ?? const Uuid().v4(),
        dailyRecordId: dailyRecordId,
        batchId: batchId,
        chickenReduction: _chickenReduction,
        chickensCurled: _chickensCurled,
        chickensSold: _chickensSold,
        chickensDied: _chickensDied,
        chickensStolen: _chickensStolen,
        eggCollection: _eggsCollection,
        eggsCollected: _eggsCollected,
        gradeEggs: _gradeEggs,
        eggsSmall: _eggsSmall,
        eggsDeformed: _eggsDeformed,
        eggsStandard: _eggsStandard,
        eggsBroken: _eggsBroken,
        notes: _notes,
        feedsUsed: _feedsUsed,
        vaccinesUsed: _vaccinesUsed,
        otherMaterialsUsed: _otherMaterialsUsed,
        salesAmount: _salesAmount,
        lossesBreakdown: _lossesBreakdown,
        gainsAmount: _gainsAmount,
      );

      if (editingReportId != null && editingDailyRecordId != null) {
        await _sync.updateRow(
          LocalTables.dailyRecords,
          localId: editingDailyRecordId,
          values: {'record_date': dateStr, 'report_date': dateStr},
          match: {'id': editingDailyRecordId},
        );
        await _sync.updateRow(
          LocalTables.batchRecords,
          localId: editingReportId,
          values: report.toJson(),
          match: {'id': editingReportId},
        );
      } else {
        await _sync.saveRow(LocalTables.dailyRecords, {
          'id': dailyRecordId,
          'user_id': userId,
          'record_date': dateStr,
          'report_date': dateStr,
        });
        await _sync.saveRow(LocalTables.batchRecords, report.toJson());
      }

      resetForm();
      return true;
    } catch (e) {
      debugPrint('Error saving the daily report: $e');
      return false;
    } finally {
      _isloading = false;
      notifyListeners();
    }
  }

  void resetForm() {
    _chickensCurled = 0;
    _chickensSold = 0;
    _chickensDied = 0;
    _chickensStolen = 0;
    _eggsCollected = 0;
    _eggsSmall = 0;
    _eggsDeformed = 0;
    _eggsStandard = 0;
    _eggsBroken = 0;
    _chickenReduction = false;
    _eggsCollection = false;
    _gradeEggs = false;
    _notes = null;
    _feedsUsed = [];
    _vaccinesUsed = [];
    _otherMaterialsUsed = [];
    _lossesBreakdown = [];
    _salesAmount = 0;
    _gainsAmount = 0;
    _editingReportId = null;
    _editingDailyRecordId = null;
    _batch = null;
    notifyListeners();
  }

  /// Whether a report is dated today, checked on the device so it works
  /// offline and counts reports that haven't been uploaded yet.
  Future<bool> hasRecordedToday() async {
    final userId = _sync.currentUserId;
    if (userId == null) return false;

    final todayStr = DateTime.now().toIso8601String().split('T')[0];
    return _sync.store
        .rows(LocalTables.dailyRecords)
        .any(
          (record) =>
              record['user_id'] == userId &&
              (record['record_date'] as String?)?.startsWith(todayStr) == true,
        );
  }
}
