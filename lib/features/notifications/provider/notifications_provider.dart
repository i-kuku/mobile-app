import 'package:flutter/foundation.dart';
import 'package:ikuku/features/notifications/model/notifications_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationsProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  List _notifications = [];
  bool _isLoading = false;

  List get notifications => _notifications;
  bool get isLoading => _isLoading;

  /// Fetches the last 6 historical notifications and evaluates dynamic triggers
  Future fetchNotifications({
    required List lowStockFeeds,
    required bool hasRecordedToday,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      // 1. Loop through each low stock feed item and register a notification if not already sent today
      for (final feed in lowStockFeeds) {
        final feedName = feed.name;
        final quantity = feed.quantity;
        final unit = feed.unit;
        
        // Use a unique reference key per item so each feed gets its own alert
        final referenceKey = 'low_stock_${feed.id}';

        await _insertNotificationForSpecificItemIfNotExists(
          userId: userId,
          type: 'low_stock',
          referenceKey: referenceKey,
          titleEn: 'Low Stock: $feedName',
          titleSw: 'Mali Ndogo: $feedName',
          messageEn: '\(feedName is running low (\)quantity $unit left). Restock soon!',
          messageSw: '\(feedName inapungua (\)quantity $unit zimebaki). Nunua zingine!',
        );
      }
      if (!hasRecordedToday) {
        await _insertNotificationIfNotExists(
          userId: userId,
          type: 'missing_record',
          titleEn: 'Missing Daily Report',
          titleSw: 'Ripoti ya Kila Siku Haipo',
          messageEn: 'You haven’t recorded today’s batch metrics yet. Keep your data up to date!',
          messageSw: 'Hujaweka takwimu za makundi ya leo. Weka kumbukumbu zako sawa!',
        );
      }

      // 3. Fetch the latest 6 notifications for this user ordered by creation date descending
      final response = await _supabase
          .from('user_notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(6);
        debugPrint('Fetched notifications response:');
      _notifications = (response as List)
          .map((data) => NotificationModel.fromJson(data))
          .toList();
          
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
   
  }
  

  /// Helper to prevent duplicate alerts for specific items on the same calendar day
  Future _insertNotificationForSpecificItemIfNotExists({
    required String userId,
    required String type,
    required String referenceKey,
    required String titleEn,
    required String titleSw,
    required String messageEn,
    required String messageSw,
  }) async {
    final todayStart = DateTime.now().toIso8601String().split('T')[0];
    
    final existing = await _supabase
        .from('user_notifications')
        .select('id')
        .eq('user_id', userId)
        .eq('type', type)
        .eq('reference_key', referenceKey)
        .gte('created_at', '${todayStart}T00:00:00')
        .maybeSingle();

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

  /// Helper to prevent inserting general duplicate alerts of the same type on the same calendar day
  Future _insertNotificationIfNotExists({
    required String userId,
    required String type,
    required String titleEn,
    required String titleSw,
    required String messageEn,
    required String messageSw,
  }) async {
    final todayStart = DateTime.now().toIso8601String().split('T')[0];
    
    final existing = await _supabase
        .from('user_notifications')
        .select('id')
        .eq('user_id', userId)
        .eq('type', type)
        .gte('created_at', '${todayStart}T00:00:00')
        .maybeSingle();

    if (existing == null) {
      await _supabase.from('user_notifications').insert({
        'user_id': userId,
        'type': type,
        'title_en': titleEn,
        'title_sw': titleSw,
        'message_en': messageEn,
        'message_sw': messageSw,
        'is_read': false,
      });
    }
  }
}