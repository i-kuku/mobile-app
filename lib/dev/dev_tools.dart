import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ikuku/shared/offline/offline_services.dart';

import 'dev_backend.dart';
import 'dev_seed.dart';

/// A small tab on the left edge, shown only with the dev backend, that takes
/// the app offline and back so offline behavior can be tried on simulators,
/// which have no airplane mode.
class DevOfflineSwitch extends StatelessWidget {
  const DevOfflineSwitch({
    super.key,
    required this.backend,
    required this.child,
  });

  final DevBackend backend;
  final Widget child;

  static const switchKey = Key('dev-offline-switch');

  void _toggle() {
    backend.online.value = !backend.online.value;
    // Sync now, so the app notices straight away either way.
    if (OfflineServices.isReady) {
      unawaited(OfflineServices.instance.sync.sync());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned(
          left: 0,
          top: MediaQuery.sizeOf(context).height * 0.45,
          child: ValueListenableBuilder<bool>(
            valueListenable: backend.online,
            builder: (context, online, _) => Semantics(
              button: true,
              label: online ? 'Dev: go offline' : 'Dev: go online',
              child: Material(
                key: switchKey,
                color: (online ? Colors.green.shade700 : Colors.grey.shade800)
                    .withValues(alpha: 0.85),
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(16),
                ),
                child: InkWell(
                  onTap: _toggle,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(6, 8, 10, 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          online ? Icons.wifi : Icons.wifi_off,
                          size: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'DEV',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Signs in as the seeded developer account, for the sign-in screen.
class DevSignInButton extends StatelessWidget {
  const DevSignInButton({super.key, required this.onSignIn});

  /// Called with the dev account's email and password.
  final void Function(String email, String password) onSignIn;

  static const buttonKey = Key('dev-sign-in');

  @override
  Widget build(BuildContext context) {
    return Center(
      child: OutlinedButton.icon(
        key: buttonKey,
        onPressed: () => onSignIn(DevSeed.email, DevSeed.password),
        icon: const Icon(Icons.developer_mode, size: 18),
        label: const Text('Sign in as dev account (${DevSeed.email})'),
      ),
    );
  }
}
