// Runs the real app on a simulator or emulator against the dev backend and
// checks a farmer's day works offline end to end: adding a batch, filing a
// farm report, stocking the store and recording a sale, then everything
// uploading once the connection is back.
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
import 'package:ikuku/dev/dev_seed.dart';
import 'package:ikuku/dev/dev_tools.dart';
import 'package:ikuku/features/shop/presentation/widgets/record_sale_button.dart';
import 'package:ikuku/main.dart' as app;
import 'package:ikuku/shared/offline/offline_services.dart';
import 'package:ikuku/shared/widgets/feature_button.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  /// Pumps frames for [time], e.g. to let a page transition finish so the
  /// page underneath is no longer on screen.
  Future<void> settle(
    WidgetTester tester, [
    Duration time = const Duration(milliseconds: 1200),
  ]) async {
    final end = DateTime.now().add(time);
    while (DateTime.now().isBefore(end)) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  /// Waits until [finder] matches something the user could tap.
  Future<void> waitFor(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final end = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(end)) {
      await tester.pump(const Duration(milliseconds: 250));
      if (finder.hitTestable().evaluate().isNotEmpty) return;
    }
    throw TestFailure('Timed out waiting for $finder');
  }

  /// Taps [target], lets the screen change, then waits for [next].
  Future<void> tapThen(WidgetTester tester, Finder target, Finder next) async {
    // Scrolled into view first: off-screen widgets can't be hit yet.
    await tester.ensureVisible(target.first);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(target.hitTestable().first);
    await settle(tester);
    await waitFor(tester, next);
  }

  var shots = 0;
  Future<void> screenshot(WidgetTester tester, String name) async {
    // Let animations, such as the banner sliding in, finish first.
    await settle(tester, const Duration(milliseconds: 600));
    shots++;
    await binding.takeScreenshot('${shots.toString().padLeft(2, '0')}_$name');
  }

  SyncEngine sync() => OfflineServices.instance.sync;
  Iterable<Object?> serverValues(String table, String column) =>
      DevBackend.instance!.rows(table).map((row) => row[column]);

  final continueButton = find.widgetWithText(FeatureButton, 'CONTINUE');
  final home = find.text('Quick Actions');
  final offlineBanner = find.textContaining("You're offline");

  testWidgets('a farmer\'s day works offline and uploads on reconnect', (
    tester,
  ) async {
    expect(
      DevBackend.enabled,
      isTrue,
      reason: 'Run with --dart-define=IKUKU_DEV_BACKEND=true',
    );
    // The counts checked below are the seed's.
    expect(
      DevBackend.resetOnStart,
      isTrue,
      reason: 'Run with --dart-define=IKUKU_DEV_RESET=true',
    );

    // A first launch, minus the home tour, which would cover the screen.
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await prefs.setBool('tutorials', true);
    if (Platform.isAndroid) await binding.convertFlutterSurfaceToImage();

    app.main();

    // Language and intro.
    await waitFor(tester, find.text('CONTINUE'));
    await screenshot(tester, 'language');
    await tapThen(tester, find.text('CONTINUE'), find.text('Skip'));
    await tapThen(
      tester,
      find.text('Skip'),
      find.byKey(DevSignInButton.buttonKey),
    );

    // Sign in as the seeded developer account; its farm comes down.
    await screenshot(tester, 'sign_in');
    await tapThen(
      tester,
      find.byKey(DevSignInButton.buttonKey),
      find.text(DevSeed.fullName),
    );
    await waitFor(tester, find.text('450'));
    await screenshot(tester, 'home_online');

    // --- Offline from here ---------------------------------------------------
    await tester.tap(find.byKey(DevOfflineSwitch.switchKey));
    // Notifications the seed triggers may still be waiting to upload.
    await waitFor(tester, offlineBanner);
    await screenshot(tester, 'home_offline');
    final pendingAtStart = sync().pendingCount;

    // 1. A new batch.
    await tapThen(
      tester,
      find.text('Add Chick Batch'),
      find.text('Manage Batches'),
    );
    await tapThen(
      tester,
      find.byIcon(Icons.add_circle),
      find.byType(FeatureButton),
    );
    final batchFields = find.byType(TextFormField);
    await tester.enterText(batchFields.at(0), 'Offline Batch');
    await tester.enterText(batchFields.at(1), '25');
    await tester.enterText(batchFields.at(2), '2');
    await tester.enterText(batchFields.at(3), '5000');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tapThen(tester, find.byType(FeatureButton), find.text('Confirm'));
    // Confirming shows a one-second message, then the batch list.
    await tester.tap(find.text('Confirm'));
    await settle(tester, const Duration(seconds: 3));
    await waitFor(tester, find.text('Add New Batch'));
    await waitFor(tester, find.text('Offline Batch'));
    final pending = sync().pendingCount;
    expect(pending, pendingAtStart + 1);
    await waitFor(
      tester,
      find.textContaining(
        pending == 1 ? '1 change will upload' : '$pending changes will upload',
      ),
    );
    await screenshot(tester, 'batch_saved_offline');

    await tapThen(tester, find.byIcon(Icons.arrow_back), home);
    await waitFor(tester, find.text('475'));
    await screenshot(tester, 'home_birds_updated');

    // 2. Today's farm report for Layers A, with 240 eggs.
    await tapThen(
      tester,
      find.text('Farm report'),
      find.widgetWithText(FeatureButton, 'ADD FARM REPORT'),
    );
    await screenshot(tester, 'reports_offline');
    await tapThen(
      tester,
      find.widgetWithText(FeatureButton, 'ADD FARM REPORT'),
      find.text('Select the batch you are reporting for'),
    );
    await tapThen(
      tester,
      find.text('Layers A'),
      find.text('Select Report Date'),
    );
    await tapThen(tester, continueButton, continueButton); // reductions
    await tapThen(
      tester,
      continueButton,
      find.text('Have you collected eggs today ?'),
    );
    await tester.tap(find.text('Yes').hitTestable().first);
    await waitFor(tester, find.byType(TextField));
    await tester.enterText(find.byType(TextField).first, '240');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tapThen(tester, continueButton, continueButton); // feeds
    await tapThen(tester, continueButton, continueButton); // vaccines
    await tapThen(tester, continueButton, continueButton); // other items
    await tapThen(tester, continueButton, continueButton); // notes
    await tapThen(tester, continueButton, find.text('Farm Report Entry'));
    final finish = find.text('FINISH REPORTING');
    await tester.scrollUntilVisible(
      finish,
      300,
      scrollable: find.byType(Scrollable).hitTestable().first,
    );
    await screenshot(tester, 'report_summary_offline');
    await tapThen(tester, finish, find.text('Back to Dashboard'));
    await screenshot(tester, 'report_saved_offline');
    await tapThen(tester, find.text('Back to Dashboard'), home);
    await waitFor(tester, find.text('994'));
    await screenshot(tester, 'home_eggs_updated');

    // 3. A new feed in the farm store.
    await tapThen(tester, find.text('Farm Store'), find.text('My Inventory'));
    await tapThen(tester, find.text('Feeds'), find.text('Layers Mash'));
    await tapThen(
      tester,
      find.byType(FloatingActionButton),
      find.text('Add Item'),
    );
    final itemFields = find.byType(TextFormField);
    await tester.enterText(itemFields.at(0), 'Growers Mash');
    await tester.enterText(itemFields.at(1), '50');
    await tester.enterText(itemFields.at(2), '80');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tapThen(tester, find.text('Add Item'), find.text('Growers Mash'));
    await screenshot(tester, 'store_item_offline');

    // 4. An eggs sale in the shop.
    for (var i = 0; i < 4 && home.hitTestable().evaluate().isEmpty; i++) {
      await tester.tap(find.byIcon(Icons.arrow_back).hitTestable().first);
      await settle(tester);
    }
    await waitFor(tester, home);
    await tapThen(tester, find.text('My Shop'), find.text('Record Sale'));
    await tapThen(tester, find.text('Record Sale'), find.text('Eggs'));
    await tapThen(tester, find.text('Eggs'), find.byType(RecordSaleButton));
    final saleFields = find.byType(TextField);
    await tester.enterText(saleFields.at(0), '30');
    await tester.enterText(saleFields.at(1), '300');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tapThen(tester, find.byType(RecordSaleButton), find.text('Save'));
    await tapThen(tester, find.text('Save'), find.text('What have you sold ?'));
    await tapThen(tester, find.byIcon(Icons.arrow_back), find.text('30 Eggs'));
    await screenshot(tester, 'sale_saved_offline');

    // Nothing reached the server while offline.
    expect(serverValues('batches', 'name'), isNot(contains('Offline Batch')));
    expect(
      serverValues('inventory_items', 'name'),
      isNot(contains('Growers Mash')),
    );
    expect(
      serverValues('batch_records', 'eggs_collected'),
      isNot(contains(240)),
    );
    expect(serverValues('sale', 'quantity'), isNot(contains(30)));
    // The batch, the report and its day, the store item and the sale.
    expect(sync().pendingCount, greaterThanOrEqualTo(pendingAtStart + 5));
    expect(offlineBanner, findsOneWidget);

    // --- Back online ---------------------------------------------------------
    await tester.tap(find.byKey(DevOfflineSwitch.switchKey));
    final end = DateTime.now().add(const Duration(seconds: 30));
    while (sync().pendingCount > 0 && DateTime.now().isBefore(end)) {
      await tester.pump(const Duration(milliseconds: 250));
    }
    await settle(tester);
    expect(sync().pendingCount, 0);
    expect(sync().parkedCount, 0);
    expect(serverValues('batches', 'name'), contains('Offline Batch'));
    expect(serverValues('inventory_items', 'name'), contains('Growers Mash'));
    expect(serverValues('batch_records', 'eggs_collected'), contains(240));
    expect(serverValues('daily_records', 'id'), hasLength(4));
    expect(serverValues('sale', 'quantity'), contains(30));
    expect(offlineBanner, findsNothing);
    expect(find.textContaining('will upload'), findsNothing);
    await waitFor(tester, find.text('30 Eggs'));
    await screenshot(tester, 'shop_back_online');
  });
}
