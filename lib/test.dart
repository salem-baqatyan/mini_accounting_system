// import 'package:easy_notify/easy_notify.dart';
// import 'package:flutter/material.dart';

// class NotificationTestScreen extends StatelessWidget {
//   const NotificationTestScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('تجربة الإشعارات'), centerTitle: true),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             const SizedBox(height: 30),
//             ElevatedButton.icon(
//               onPressed: () {
//                 EasyNotify.showBasicNotification(
//                   id: 10,
//                   title: 'إشعار فوري',
//                   body: 'هذا إشعار يظهر فورًا',
//                 );
//               },
//               icon: const Icon(Icons.flash_on),
//               label: const Text('إشعار فوري'),
//               style: ElevatedButton.styleFrom(
//                 minimumSize: const Size.fromHeight(50),
//               ),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton.icon(
//               onPressed: () {
//                 EasyNotify.showScheduledNotification(
//                   id: 11,
//                   title: 'إشعار مؤجل',
//                   body: 'هذا إشعار سيظهر بعد 10 ثواني',
//                   duration: const Duration(seconds: 10),
//                 );
//               },
//               icon: const Icon(Icons.timer),
//               label: const Text('إشعار بعد 10 ثواني'),
//               style: ElevatedButton.styleFrom(
//                 minimumSize: const Size.fromHeight(50),
//               ),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton.icon(
//               onPressed: () {
//                 EasyNotify.showRepeatedNotification(
//                   id: 12,
//                   title: 'إشعار متكرر',
//                   body: 'هذا إشعار سيتكرر يوميًا',
//                 );
//               },
//               icon: const Icon(Icons.repeat),
//               label: const Text('إشعار متكرر يوميًا'),
//               style: ElevatedButton.styleFrom(
//                 minimumSize: const Size.fromHeight(50),
//               ),
//             ),
//             const SizedBox(height: 40),
//             const Text(
//               'اضغط على أي زر لتجربة نوع مختلف من الإشعار',
//               style: TextStyle(fontSize: 16),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
