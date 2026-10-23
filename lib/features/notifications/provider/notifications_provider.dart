import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:ikuku/features/notifications/model/notifications_model.dart';
import 'package:ikuku/shared/offline/offline_services.dart';

class NotificationsProvider extends ChangeNotifier {
  NotificationsProvider({SyncEngine? sync})
      : _sync = sync ?? OfflineServices.instance.sync,
        _store = (sync ?? OfflineServices.instance.sync).store {
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
    if (userId == null) {
      // Signed out: don't leave the last user's notifications showing.
      if (_notifications.isNotEmpty) {
        _notifications = [];
        notifyListeners();
      }
      return;
    }
    DateTime when(Map<String, dynamic> r) =>
        DateTime.tryParse('${r['created_at']}') ??
        DateTime.fromMillisecondsSinceEpoch(0);

    final rows = _store
        .rows(LocalTables.userNotifications)
        .where((r) => r['user_id'] == userId)
        .toList()
      ..sort((a, b) => when(b).compareTo(when(a)));

    final loaded = <NotificationModel>[];
    for (final row in rows) {
      if (loaded.length == 20) break;
      try {
        loaded.add(NotificationModel.fromJson(row));
      } catch (e) {
        debugPrint('Skipping unreadable notification ${row['id']}: $e');
      }
    }
    _notifications = loaded;
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
      // Notifications are only made once the server's copy is on this
      // phone; otherwise ones that already exist there would be made again.
      if (!_sync.hasPulled(LocalTables.userNotifications)) {
        await _sync.refresh(force: true);
        if (!_sync.hasPulled(LocalTables.userNotifications)) return;
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

  bool _exists(String userId, String key) => _store
      .rows(LocalTables.userNotifications)
      .any((r) => r['user_id'] == userId && r['reference_key'] == key);

  Future<void> _create({
    required String userId,
    required String type,
    required String referenceKey,
    required String titleEn,
    required String titleSw,
    required String messageEn,
    required String messageSw,
  }) async {
    // Keys carry the date for notifications that may repeat daily.
    if (_exists(userId, referenceKey)) return;
    try {
      // Client-made uuid, so sending twice is harmless. If the server
      // already has this reference key under another id, the copy is
      // dropped rather than retried.
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
      }, dropIfDuplicate: true);
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