// Runs the real app on a simulator or emulator against the dev backend and
// checks the offline flow end to end:
//
//   flutter drive --driver=test_driver/integration_test.dart \
//     --target=integration_test/offline_flow_test.dart -d <device> \
//     --dart-define=IKUKU_DEV_BACKEND=true --dart-define=IKUKU_DEV_RESET=true
//
// Screenshots of each step land in build/integration_test/screenshots/.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikuku/dev/dev_backend.dart';
import 'package:ikuku/dev/dev_tools.dart';
import 'package:ikuku/main.dart' as app;
import 'package:ikuku/shared/offline/offline_services.dart';
import 'package:ikuku/shared/widgets/feature_button.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpUntil(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final end = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(end)) {
      await tester.pump(const Duration(milliseconds: 250));
      if (finder.evaluate().isNotEmpty) return;
    }
    throw TestFailure('Timed out waiting for $finder');
  }

  var shots = 0;
  Future<void> screenshot(WidgetTester tester, String name) async {
    // Let animations, such as the banner sliding in, finish first.
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    shots++;
    await binding.takeScreenshot('${shots.toString().padLeft(2, '0')}_$name');
  }

  testWidgets('works offline and uploads what was entered on reconnect', (
    tester,
  ) async {
    expect(
      DevBackend.enabled,
      isTrue,
      reason: 'Run with --dart-define=IKUKU_DEV_BACKEND=true',
    );

    // A first launch, minus the home tour, which would cover the screen.
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await prefs.setBool('tutorials', true);
    if (Platform.isAndroid) await binding.convertFlutterSurfaceToImage();

    app.main();

    // Language and intro.
    await pumpUntil(tester, find.text('CONTINUE'));
    await screenshot(tester, 'language');
    await tester.tap(find.text('CONTINUE'));
    await pumpUntil(tester, find.text('Skip'));
    await tester.tap(find.text('Skip'));

    // Sign in as the seeded developer account.
    await pumpUntil(tester, find.byKey(DevSignInButton.buttonKey));
    await screenshot(tester, 'sign_in');
    await tester.tap(find.byKey(DevSignInButton.buttonKey));
    await pumpUntil(tester, find.text('Dev Farmer'));
    await pumpUntil(tester, find.text('450'));
    await screenshot(tester, 'home_online');

    // Go offline with the dev switch; the banner says so.
    await tester.tap(find.byKey(DevOfflineSwitch.switchKey));
    await pumpUntil(
      tester,
      find.text("You're offline. Everything you enter is saved on this phone."),
    );
    await screenshot(tester, 'home_offline');

    // Add a batch while offline.
    await tester.tap(find.text('Add Chick Batch'));
    await pumpUntil(tester, find.text('Layers A'));
    await tester.tap(find.byIcon(Icons.add_circle));
    await pumpUntil(tester, find.byType(FeatureButton));
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Offline Batch');
    await tester.enterText(fields.at(1), '25');
    await tester.enterText(fields.at(2), '2');
    await tester.enterText(fields.at(3), '5000');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    await tester.ensureVisible(find.byType(FeatureButton));
    await tester.tap(find.byType(FeatureButton));
    await pumpUntil(tester, find.text('Confirm'));
    await tester.tap(find.text('Confirm'));

    // It's in the list straight away, waiting to upload.
    await pumpUntil(tester, find.text('Offline Batch'));
    await pumpUntil(tester, find.textContaining('1 changes will upload'));
    expect(OfflineServices.instance.sync.pendingCount, 1);
    expect(
      DevBackend.instance!.rows('batches').map((r) => r['name']),
      isNot(contains('Offline Batch')),
    );
    await screenshot(tester, 'batch_saved_offline');

    // Home counts it too.
    await tester.tap(find.byIcon(Icons.arrow_back).first);
    await pumpUntil(tester, find.text('475'));
    await screenshot(tester, 'home_offline_totals');

    // Back online, the batch uploads and the banner goes.
    await tester.tap(find.byKey(DevOfflineSwitch.switchKey));
    final end = DateTime.now().add(const Duration(seconds: 30));
    while (OfflineServices.instance.sync.pendingCount > 0 &&
        DateTime.now().isBefore(end)) {
      await tester.pump(const Duration(milliseconds: 250));
    }
    await tester.pump(const Duration(seconds: 1));
    expect(OfflineServices.instance.sync.pendingCount, 0);
    expect(
      DevBackend.instance!.rows('batches').map((r) => r['name']),
      contains('Offline Batch'),
    );
    expect(find.textContaining("You're offline"), findsNothing);
    await screenshot(tester, 'home_back_online');
  });
}
