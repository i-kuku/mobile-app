// import 'package:flutter/material.dart';
// import 'package:ikuku/shared/services/connectivity_manager.dart';

// class ConnectivityStatusWidget extends StatelessWidget {
//   final Widget child;
//   final bool showOfflineIndicator;

//   const ConnectivityStatusWidget({
//     super.key,
//     required this.child,
//     this.showOfflineIndicator = true,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder<bool>(
//       valueListenable: ConnectivityManager.instance.isOnlineNotifier,
//       builder: (context, isOnline, _) {
//         return Stack(
//           children: [
//             child,
//             if (!isOnline && showOfflineIndicator)
//               Positioned(
//                 top: 0,
//                 left: 0,
//                 right: 0,
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(vertical: 4),
//                   color: Colors.orange,
//                   child: const Text(
//                     'Offline Mode - Reports will sync when online',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 12,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         );
//       },
//     );
//   }
// }

