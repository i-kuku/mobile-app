import 'package:flutter/foundation.dart';
import 'package:ikuku/features/notifications/model/notifications_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationsProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;

  static const _vaccinationDelay = Duration(days: 90); // ~3 months
  static const _predictionDelay = Duration(days: 30);

List<NotificationModel> get unreadNotifications =>
    _notifications.where((n) => !n.isRead).toList();

    
  Future<void> fetchNotifications({
    required List lowStockFeeds,
    required bool hasRecordedToday,
    required List batches, // each item needs .id, .name, .createdAt
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }
      final userId = user.id;

      // 1. Low stock alerts
      for (final feed in lowStockFeeds) {
        final feedName = feed.name;
        final quantity = feed.quantity;
        final unit = feed.unit;

        await _safeInsert(
          () => _insertIfNotExists(
            userId: userId,
            type: 'low_stock',
            referenceKey: 'low_stock_${feed.id}',
            titleEn: 'Low Stock: $feedName',
            titleSw: 'Mali Ndogo: $feedName',
            messageEn: '$feedName is running low ($quantity $unit left). Restock soon!',
            messageSw: '$feedName inapungua ($quantity $unit zimebaki). Nunua zingine!',
          ),
          label: 'low_stock ($feedName)',
        );
      }

      // 2. Missing daily report
      if (!hasRecordedToday) {
        await _safeInsert(
          () => _insertIfNotExists(
            userId: userId,
            type: 'missing_record',
            referenceKey: 'missing_record_${DateTime.now().toIso8601String().split('T')[0]}',
            titleEn: 'Missing Daily Report',
            titleSw: 'Ripoti ya Kila Siku Haipo',
            messageEn: 'You haven\u2019t recorded today\u2019s batch metrics yet. Keep your data up to date!',
            messageSw: 'Hujaweka takwimu za makundi ya leo. Weka kumbukumbu zako sawa!',
          ),
          label: 'missing_record',
        );
      }

      // 3. Health tip — vaccination reminder, 3 months after each batch's creation.
      final now = DateTime.now();
      for (final batch in batches) {
        final batchId = batch.id;
        final batchName = batch.name;
        final DateTime createdAt = batch.createdAt;

        final dueDate = createdAt.add(_vaccinationDelay);
        if (now.isAfter(dueDate)) {
          await _safeInsert(
            () => _insertIfNotExists(
              userId: userId,
              type: 'health_tip',
              // one-time reminder per batch, not per-day, so it's keyed only by batch id
              referenceKey: 'vaccine_reminder_$batchId',
              titleEn: 'Health Tip',
              titleSw: 'Ushauri wa Afya',
              messageEn: 'Remember to vaccinate $batchName.',
              messageSw: 'Kumbuka kuchanja $batchName.',
              oncePerDay: false, 
            ),
            label: 'health_tip ($batchName)',
          );
        }
      }

      final accountCreatedAt =  DateTime.parse(user.createdAt );
      if (now.isAfter(accountCreatedAt.add(_predictionDelay))) {
        await _safeInsert(
          () => _insertIfNotExists(
            userId: userId,
            type: 'prediction',
            referenceKey: 'prediction_ready',
            titleEn: 'Prediction',
            titleSw: 'Utabiri',
            messageEn: 'Your monthly prediction is ready.',
            messageSw: 'Utabiri wako wa mwezi uko tayari.',
            oncePerDay: false,
          ),
          label: 'prediction',
        );
      }
      final response = await _supabase
          .from('user_notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(20);

      _notifications = (response as List)
          .map((data) => NotificationModel.fromJson(data as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _safeInsert(Future<void> Function() insert, {required String label}) async {
    try {
      await insert();
    } catch (e) {
      debugPrint('Insert failed for $label: $e');
    }
  }

  Future<void> _insertIfNotExists({
    required String userId,
    required String type,
    required String referenceKey,
    required String titleEn,
    required String titleSw,
    required String messageEn,
    required String messageSw,
    bool oncePerDay = true,
  }) async {
    var query = _supabase
        .from('user_notifications')
        .select('id')
        .eq('user_id', userId)
        .eq('type', type)
        .eq('reference_key', referenceKey);

    if (oncePerDay) {
      final todayStart = DateTime.now().toIso8601String().split('T')[0];
      query = query.gte('created_at', '${todayStart}T00:00:00');
    }

    final existing = await query.maybeSingle();

    if (existing == null) {
      await _supabase.from('user_notifications').insert({
        'user_id': userId,
        'type': type,
        'reference_key': referenceKey,
        'title_en': titleEn,
        'title_sw': titleSw,
        'message_en': messageEn,
        'message_sw': messageSw,
        'is_read': false,
      });
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _supabase
          .from('user_notifications')
          .update({'is_read': true})
          .eq('id', notificationId);

      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }
}
