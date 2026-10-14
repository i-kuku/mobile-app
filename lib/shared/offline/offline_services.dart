import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'connectivity_service.dart';
import 'local_store.dart';
import 'sync_engine.dart';

export 'connectivity_service.dart';
export 'local_store.dart';
export 'network_errors.dart';
export 'outbox.dart';
export 'sync_engine.dart';

/// The app-wide offline data layer, set up once at start-up by [init].
class OfflineServices {
  OfflineServices._(this.store, this.connectivity, this.sync);

  final LocalStore store;
  final ConnectivityService connectivity;
  final SyncEngine sync;

  static OfflineServices? _instance;

  static OfflineServices get instance =>
      _instance ??
      (throw StateError('OfflineServices.init() must run before use'));

  static bool get isReady => _instance != null;

  /// Opens the local store and wires up syncing. Does not touch the
  /// network, so start-up is just as fast offline.
  static Future<OfflineServices> init({
    StorePersistence? persistence,
    ConnectivityService? connectivity,
    SupabaseClient Function()? client,
    List<PullSpec>? pullSpecs,
    Duration requestTimeout = const Duration(seconds: 20),
  }) async {
    final store = await LocalStore.open(persistence ?? HiveStorePersistence());
    final network = connectivity ?? ConnectivityService.device();
    final sync = SyncEngine(
      store: store,
      connectivity: network,
      client: client,
      pullSpecs: pullSpecs,
      requestTimeout: requestTimeout,
    );
    return _instance = OfflineServices._(store, network, sync);
  }

  /// Starts watching the network and syncing in the background.
  Future<void> start() async {
    await connectivity.start();
    final userId = sync.currentUserId;
    if (userId != null) await store.claimFor(userId);
    sync.start();
  }

  /// Call once someone has signed in: keeps their data if this device
  /// already holds it, otherwise clears what's here, then starts a sync in
  /// the background so the app is ready to use offline.
  Future<void> signedIn(String userId) async {
    await store.claimFor(userId);
    unawaited(sync.sync());
  }

  /// Forgets everything on this device, including unsent changes.
  Future<void> signedOut() => store.clear();

  @visibleForTesting
  static Future<void> reset() async {
    _instance?.sync.dispose();
    _instance?.connectivity.dispose();
    _instance = null;
  }
}
