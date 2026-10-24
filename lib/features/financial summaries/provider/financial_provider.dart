import 'package:flutter/material.dart';
import 'package:ikuku/features/financial%20summaries/model/financial_summary_model.dart';
import 'package:ikuku/shared/offline/offline_services.dart';

/// The financial summary, which the server works out. The last one fetched
/// is kept on the device and shown, with its date, when offline.
class FinancialSummaryProvider extends ChangeNotifier {
  FinancialSummaryProvider({SyncEngine? sync}) : _syncOverride = sync;

  final SyncEngine? _syncOverride;
  SyncEngine get _sync => _syncOverride ?? OfflineServices.instance.sync;

  FinancialSummaryModel? _summary;
  bool _isLoading = false;
  String? _selectedBatchId;
  String _selectedTimeframe = '3 months';
  DateTime? _updatedAt;
  bool _isFresh = false;

  FinancialSummaryModel? get summary => _summary;
  bool get isLoading => _isLoading;
  String? get selectedBatchId => _selectedBatchId;
  String get selectedTimeframe => _selectedTimeframe;

  /// When the figures shown were worked out by the server.
  DateTime? get updatedAt => _updatedAt;

  /// Whether the figures shown are a saved copy because the server couldn't
  /// be reached.
  bool get isSavedCopy => !_isFresh;

  /// Whether this phone has entries the server hasn't counted yet.
  bool get hasUnsentChanges => _sync.pendingCount > 0;

  String get _cacheKey => 'financial_summary:${_selectedBatchId ?? 'all'}';

  Future<void> load() async {
    final key = _cacheKey;
    final saved = _sync.store.cached(key);
    if (saved != null) _apply(saved.value, saved.savedAt, fresh: false);
    // Only an empty screen waits on the server; a saved copy shows at once.
    _isLoading = saved == null;
    notifyListeners();

    try {
      // The server does the sums, so send it this phone's entries first.
      await _sync.sync(pull: false);
      final result = await _sync.cachedQuery(
        key,
        (client) => client.rpc(
          'get_financial_summary',
          params: {'p_batch_id': _selectedBatchId},
        ),
      );
      // The filter may have changed while this was loading.
      if (key != _cacheKey) return;
      if (result.isFresh || saved == null) {
        _apply(result.value, result.savedAt, fresh: result.isFresh);
      }
    } catch (e) {
      debugPrint('Error loading financial summary: $e');
    } finally {
      if (key == _cacheKey) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void _apply(Object? value, DateTime? updatedAt, {required bool fresh}) {
    final rows = value is List ? value : const [];
    try {
      _summary = rows.isEmpty
          ? null
          : FinancialSummaryModel.fromJson(
              Map<String, dynamic>.from(rows.first as Map),
            );
    } catch (e) {
      debugPrint('Unreadable financial summary: $e');
      _summary = null;
    }
    _updatedAt = updatedAt;
    _isFresh = fresh;
  }

  // Refreshes data
  Future<void> refresh() async {
    await load();
  }

  void setBatch(String? batchId) {
    if (_selectedBatchId != batchId) {
      _selectedBatchId = batchId;
      _summary = null;
      load();
    }
  }
  void setTimeframe(String timeframe) {
    if (_selectedTimeframe != timeframe) {
      _selectedTimeframe = timeframe;
      notifyListeners();
    }
  }
}