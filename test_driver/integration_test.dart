import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

/// Runs integration tests with `flutter drive` and saves the screenshots they
/// take to build/integration_test/screenshots/.
Future<void> main() => integrationDriver(
  onScreenshot: (name, bytes, [args]) async {
    final file = File('build/integration_test/screenshots/$name.png');
    await file.create(recursive: true);
    await file.writeAsBytes(bytes);
    return true;
  },
);
