import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Sign-up details collected before the account could be created, usually
/// because the phone was offline. They are sent once a connection returns.
///
/// The password is deliberately not part of this; it stays in memory only
/// and is asked for again if the app was closed in between.
@immutable
class PendingRegistration {
  const PendingRegistration({
    required this.email,
    this.fullName,
    this.phone,
    this.farmName,
    this.farmLocation,
    this.recoveryQuestion,
    this.recoveryAnswer,
  });

  final String email;
  final String? fullName;
  final String? phone;
  final String? farmName;
  final String? farmLocation;
  final String? recoveryQuestion;
  final String? recoveryAnswer;

  bool get hasFarmDetails => farmName != null && farmLocation != null;
  bool get hasRecovery => recoveryQuestion != null && recoveryAnswer != null;

  /// The sign-up screen to continue from.
  String get nextStep {
    if (!hasFarmDetails) return '/create-farm';
    if (!hasRecovery) return '/recovery-setup';
    return '/finish-signup';
  }

  /// The same details under another [email], e.g. after fixing a typo.
  PendingRegistration withEmail(String email) => PendingRegistration(
    email: email,
    fullName: fullName,
    phone: phone,
    farmName: farmName,
    farmLocation: farmLocation,
    recoveryQuestion: recoveryQuestion,
    recoveryAnswer: recoveryAnswer,
  );

  PendingRegistration copyWith({
    String? fullName,
    String? phone,
    String? farmName,
    String? farmLocation,
    String? recoveryQuestion,
    String? recoveryAnswer,
  }) => PendingRegistration(
    email: email,
    fullName: fullName ?? this.fullName,
    phone: phone ?? this.phone,
    farmName: farmName ?? this.farmName,
    farmLocation: farmLocation ?? this.farmLocation,
    recoveryQuestion: recoveryQuestion ?? this.recoveryQuestion,
    recoveryAnswer: recoveryAnswer ?? this.recoveryAnswer,
  );

  Map<String, dynamic> toJson() => {
    'email': email,
    'full_name': fullName,
    'phone': phone,
    'farm_name': farmName,
    'farm_location': farmLocation,
    'recovery_question': recoveryQuestion,
    'recovery_answer': recoveryAnswer,
  };

  factory PendingRegistration.fromJson(Map<String, dynamic> json) =>
      PendingRegistration(
        email: json['email'] as String,
        fullName: json['full_name'] as String?,
        phone: json['phone'] as String?,
        farmName: json['farm_name'] as String?,
        farmLocation: json['farm_location'] as String?,
        recoveryQuestion: json['recovery_question'] as String?,
        recoveryAnswer: json['recovery_answer'] as String?,
      );
}

/// Keeps the [PendingRegistration] across app restarts. Separate from the
/// local data store, which belongs to a signed-in user.
abstract final class PendingRegistrationStore {
  static const _key = 'pending_registration';

  static Future<PendingRegistration?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json == null) return null;
    try {
      return PendingRegistration.fromJson(
        jsonDecode(json) as Map<String, dynamic>,
      );
    } catch (e) {
      debugPrint('[PendingRegistration] Dropping unreadable draft: $e');
      await clear();
      return null;
    }
  }

  static Future<void> save(PendingRegistration registration) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(registration.toJson()));
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
