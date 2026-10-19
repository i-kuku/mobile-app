import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:ikuku/features/notifications/model/notifications_model.dart';
import 'package:ikuku/shared/offline/local_store.dart';
import 'package:ikuku/shared/offline/sync_engine.dart';

class NotificationsProvider extends ChangeNotifier {
  NotificationsProvider({required SyncEngine sync})
      : _sync = sync,
        _store = sync.store {
    _sub = _store.changes
        .where((t) => t == LocalTables.userNotifications)
        .listen((_) {
      if (!_generating) _loadFromStore();
    });
    _loadFromStore();
  }

  final SyncEngine _sync;
  final LocalStore _store;
  StreamSubscription<String>? _sub;

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  bool _generating = false;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  List<NotificationModel> get unreadNotifications =>
      _notifications.where((n) => !n.isRead).toList();

  static const _vaccinationDelay = Duration(days: 90);
  static const _predictionDelay = Duration(days: 30);

  void _loadFromStore() {
    final userId = _sync.currentUserId;
    if (userId == null) return;
    DateTime when(Map<String, dynamic> r) =>
        DateTime.tryParse('${r['created_at']}') ??
        DateTime.fromMillisecondsSinceEpoch(0);

    final rows = _store
        .rows(LocalTables.userNotifications)
        .where((r) => r['user_id'] == userId)
        .toList()
      ..sort((a, b) => when(b).compareTo(when(a)));

    _notifications = rows.take(20).map(NotificationModel.fromJson).toList();
    notifyListeners();
  }

  Future<void> fetchNotifications({
    required List lowStockFeeds,
    required bool hasRecordedToday,
    required List batches,
  }) async {
    final userId = _sync.currentUserId; // works offline (saved session)
    if (userId == null) return;

    _isLoading = true;
    _generating = true;
    notifyListeners();

    try {
      // First run: get the server's copy first so we don't create a
      // duplicate of something that already exists there.
      if (_sync.lastPulledAt == null && _sync.isOnline) {
        await _sync.refresh();
      }
      final now = DateTime.now();

      for (final feed in lowStockFeeds) {
        await _create(
          userId: userId,
          type: 'low_stock',
          referenceKey:
          'low_stock_${feed.id}_${now.toIso8601String().split('T')[0]}',  
          titleEn: 'Low Stock: ${feed.name}',
          titleSw: 'Mali Ndogo: ${feed.name}',
          messageEn:
              '${feed.name} is running low (${feed.quantity} ${feed.unit} left). Restock soon!',
          messageSw:
              '${feed.name} inapungua (${feed.quantity} ${feed.unit} zimebaki). Nunua zingine!',
        );
      }


      if (!hasRecordedToday) {
        await _create(
          userId: userId,
          type: 'missing_record',
          referenceKey: 'missing_record_${now.toIso8601String().split('T')[0]}',
          titleEn: 'Missing Daily Report',
          titleSw: 'Ripoti ya Kila Siku Haipo',
          messageEn:
              'You haven\u2019t recorded today\u2019s batch metrics yet. Keep your data up to date!',
          messageSw:
              'Hujaweka takwimu za makundi ya leo. Weka kumbukumbu zako sawa!',
        );
      }

      for (final batch in batches) {
        final DateTime createdAt = batch.createdAt;
        if (now.isAfter(createdAt.add(_vaccinationDelay))) {
          await _create(
            userId: userId,
            type: 'health_tip',
            referenceKey: 'vaccine_reminder_${batch.id}',
            titleEn: 'Health Tip',
            titleSw: 'Ushauri wa Afya',
            messageEn: 'Remember to vaccinate ${batch.name}.',
            messageSw: 'Kumbuka kuchanja ${batch.name}.',
            oncePerDay: false,
          );
        }
      }

      // currentUser comes from the saved session, no network needed.
      final createdStr = Supabase.instance.client.auth.currentUser?.createdAt;
      final accountCreatedAt =
          createdStr == null ? null : DateTime.tryParse(createdStr);
      if (accountCreatedAt != null &&
          now.isAfter(accountCreatedAt.add(_predictionDelay))) {
        await _create(
          userId: userId,
          type: 'prediction',
          referenceKey: 'prediction_ready',
          titleEn: 'Prediction',
          titleSw: 'Utabiri',
          messageEn: 'Your monthly prediction is ready.',
          messageSw: 'Utabiri wako wa mwezi uko tayari.',
          oncePerDay: false,
        );
      }
    } catch (e) {
      debugPrint('Error generating notifications: $e');
    } finally {
      _generating = false;
      _isLoading = false;
      _loadFromStore();
    }
  }

 bool _exists(String userId, String type, String key) =>
    _store.rows(LocalTables.userNotifications).any((r) =>
        r['user_id'] == userId && r['reference_key'] == key);

  Future<void> _create({
    required String userId,
    required String type,
    required String referenceKey,
    required String titleEn,
    required String titleSw,
    required String messageEn,
    required String messageSw,
    bool oncePerDay = true,
  }) async {
    if (_exists(userId, type, referenceKey)) return;
    try {
      // Client-made uuid, so saveRow is an idempotent upsert.
      await _sync.saveRow(LocalTables.userNotifications, {
        'id': const Uuid().v4(),
        'user_id': userId,
        'type': type,
        'reference_key': referenceKey,
        'title_en': titleEn,
        'title_sw': titleSw,
        'message_en': messageEn,
        'message_sw': messageSw,
        'is_read': false,
        'created_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Could not create $type notification: $e');
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _sync.updateRow(
        LocalTables.userNotifications,
        localId: notificationId,
        values: {'is_read': true},
        match: {'id': notificationId},
      );
      // The store's change event refreshes the list.
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}