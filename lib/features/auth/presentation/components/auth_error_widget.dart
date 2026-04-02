import 'package:flutter/material.dart';

class AuthErrorWidget extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback internetTest;
  const AuthErrorWidget({super.key, required this.errorMessage, required this.internetTest});

  @override
  Widget build(BuildContext context) {
    return errorMessage != null? Wrap(
      children: [
        SizedBox(height: 16),
        Text(errorMessage!, style: TextStyle(color: Colors.red)),
        SizedBox(height: 8),
        if (errorMessage!.contains('internet') ||
            errorMessage!.contains('connection'))
          ElevatedButton(onPressed: internetTest, child: Text('Test Connection')),
      ],
    ):SizedBox.shrink();
  }
}

