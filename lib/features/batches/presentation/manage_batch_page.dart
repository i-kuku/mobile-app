import 'package:flutter/material.dart';

class ManageBatchPage extends StatelessWidget {
  const ManageBatchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 66,
      width: 328,
      margin: EdgeInsets.only(bottom:12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200,width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Container(
              height: 56,
              width: 175,
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
              ),
            ))
        ],
      ),
    );
  }
}