import 'package:flutter/material.dart';

class AuthErrorWidget extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback internetTest;

  /// Offer a connection test alongside the message.
  final bool showConnectionTest;

  const AuthErrorWidget({
    super.key,
    required this.errorMessage,
    required this.internetTest,
    this.showConnectionTest = false,
  });

  @override
  Widget build(BuildContext context) {
    return errorMessage != null
        ? Wrap(
            children: [
              SizedBox(height: 16),
              Text(errorMessage!, style: TextStyle(color: Colors.red)),
              SizedBox(height: 8),
              if (showConnectionTest)
                ElevatedButton(
                  onPressed: internetTest,
                  child: Text('Test Connection'),
                ),
            ],
          )
        : SizedBox.shrink();
  }
}
