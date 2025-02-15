// // ignore_for_file: avoid_print

// import 'dart:convert';

// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:http/http.dart' as http;

// // Global navigator key for accessing context globally
// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// List<String> blockedArray = [];

// class NotificationService {
//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
//   final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   Future<String?> getToken() async {
//     return await _firebaseMessaging.getToken();
//   }

//   void initialize() async {
//     await _firebaseMessaging.requestPermission();

//     String? token = await getToken();
//     print("FCM Token: $token");
//     _listenForNotifications();
//   }

//   void _listenForNotifications() {
//     // Foreground messages
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       print("Foreground notification received:");
//       _storeNotificationData(message);
//     });

//     // Background & terminated messages
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       print("Notification opened from backgroun");
//       _storeNotificationData(message);
//     });

//     // App opened from a terminated state
//     FirebaseMessaging.instance
//         .getInitialMessage()
//         .then((RemoteMessage? message) {
//       if (message != null) {
//         print("App launched from a terminated state:");
//         _storeNotificationData(message);
//       }
//     });

//     print("Listening for notifications...");
//   }

//   void _storeNotificationData(RemoteMessage message) {
//     String senderTitle =
//         message.notification?.title ?? message.data['title'] ?? "Unknown";
//     String messageBody =
//         message.notification?.body ?? message.data['body'] ?? "No message";

//     print("User Phone: $senderTitle");
//     print("Receiver Message: $messageBody");

//     handleNotification(senderTitle, messageBody, navigatorKey.currentContext!);
//   }

//   Future<void> handleNotification(
//       String senderTitle, String message, BuildContext context) async {
//     print("handleNotification");
//     if (!blockedArray.contains(senderTitle)) {
//       String? classification = await checkHarassment(message);

//       if (classification == "Harassment") {
//         showHarassmentDialog(context, senderTitle);
//       }
//     }
//   }

//   Future<String?> checkHarassment(String message) async {
//     final uri = Uri.parse(
//         "http://192.168.1.127:5000/predict?message=${Uri.encodeComponent(message)}");
//     print("check harssment: $uri");
//     final response = await http.get(uri);
//     print("check harssment2");

//     if (response.statusCode == 200) {
//       print("check harssment3");
//       final data = json.decode(response.body);
//       print("success");
//       return data['classification']; // Harassment or Non-Harassment
//     } else {
//       throw Exception('Failed to analyze message');
//     }
//   }

//   void showHarassmentDialog(BuildContext context, String senderTitle) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Harassment Message Detected'),
//           content: Text('This person sent a harassment message.'),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 // Add sender to blocked list
//                 blockedArray.add(senderTitle);
//                 Navigator.of(context).pop();
//               },
//               child: Text('Block'),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text('Ignore'),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
