import 'package:flutter/material.dart';
import 'package:ikuku/features/farms%20report/%20model/report_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FarmReportProvider extends ChangeNotifier {
  bool _isloading = false;
  bool get isloading => _isloading;
  
//temporary state holders
  int _chickensCurled = 0;
  int _chickensSold = 0;
  int _chickensDied = 0;
  int _chickensStolen = 0;
 
 int _eggsCollected = 0;
  int _eggsSmall = 0;
  int _eggsDeformed = 0;
  int _eggsStandard = 0;
  int _eggsBroken = 0;

  bool _chickenReduction = false;
  bool _eggsCollection = false;
  bool _gradeEggs = false;
  String? _notes;

 List<Map<String, dynamic>> _feedsUsed = [];
  List<Map<String, dynamic>> _vaccinesUsed = [];
  List<Map<String, dynamic>> _otherMaterialsUsed = [];
  List<Map<String, dynamic>> _lossesBreakdown = [];

  int _salesAmount = 0;
  int _gainsAmount = 0;

  void updateChicken({int? curled, int? sold, int? died, int? stolen}) {
    if (curled != null) _chickensCurled = curled;
    if (sold != null) _chickensSold = sold;
    if (died != null) _chickensDied = died;
    if (stolen != null) _chickensStolen = stolen;
    _chickenReduction = (_chickensCurled + _chickensSold + _chickensDied + _chickensStolen) > 0;
    notifyListeners();
  }

  void updateEggMetrics({int? collected, int? small, int? deformed, int? standard, int? broken, bool? grade}) {
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

  // 3. Database Action: Handles Parent and Child Insert Transactions Sequential logic
  Future<bool> submitDailyReport({required String batchId}) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return false;

    _isloading = true;
    notifyListeners();

    try {
      final todayStr = DateTime.now().toIso8601String().split('T')[0];

      // STEP A: Insert Parent entry into 'daily_records' table
      final parentResponse = await Supabase.instance.client
          .from('daily_records')
          .insert({
            'user_id': userId,
            'record_date': todayStr,
            'report_date': todayStr,
          })
          .select('id')
          .single();

      final String generatedDailyRecordId = parentResponse['id'] as String;
      final reportPayload = Report.empty(
        batchId: batchId,
        dailyRecordId: generatedDailyRecordId, 
        id: 'id',
      );

      final finalReport = Report(
        id: reportPayload.id,
        dailyRecordId: reportPayload.dailyRecordId,
        batchId: reportPayload.batchId,
        chickenReduction: _chickenReduction,
        chickensCurled: _chickensCurled,
        chickensSold: _chickensSold,
        chickensDied: _chickensDied,
        chickensStolen: _chickensStolen,
        eggsCollection: _eggsCollection,
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

      // Send the payload straight into your final farm reports table!
      await Supabase.instance.client
          .from('batch_records') 
          .insert(finalReport.toJson());

      // Clear form memory states 
      resetForm();
      return true;
    } catch (e) {
      debugPrint('Error executing database submission transaction: $e');
      return false;
    } finally {
      _isloading = false;
      notifyListeners();
    }
  }

  void resetForm() {
    _chickensCurled = 0; _chickensSold = 0; _chickensDied = 0; _chickensStolen = 0;
    _eggsCollected = 0; _eggsSmall = 0; _eggsDeformed = 0; _eggsStandard = 0; _eggsBroken = 0;
    _chickenReduction = false; _eggsCollection = false; _gradeEggs = false; _notes = null;
    _feedsUsed = []; _vaccinesUsed = []; _otherMaterialsUsed = []; _lossesBreakdown = [];
    _salesAmount = 0; _gainsAmount = 0;
  }
}