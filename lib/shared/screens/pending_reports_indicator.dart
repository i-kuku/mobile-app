// import 'package:flutter/material.dart';
// import 'package:ikuku/shared/services/connectivity_manager.dart';

// class PendingReportsIndicator extends StatelessWidget {
//   final VoidCallback? onTap;

//   const PendingReportsIndicator({super.key, this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder<int>(
//       valueListenable: ConnectivityManager.instance.pendingReportsNotifier,
//       builder: (context, pendingCount, _) {
//         if (pendingCount == 0) return const SizedBox.shrink();

//         return GestureDetector(
//           onTap: onTap,
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//             decoration: BoxDecoration(
//               color: Colors.orange,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Icon(Icons.cloud_upload, size: 16, color: Colors.white),
//                 const SizedBox(width: 4),
//                 Text(
//                   '$pendingCount pending',
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 12,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
