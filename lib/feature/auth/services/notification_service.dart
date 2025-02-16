import 'dart:convert';
import 'dart:math';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp_messenger/feature/auth/services/local_notification_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
List<Map<String, String>> pendingNotifications = [];

List<String> blockedArray = [];

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // List to store pending notifications
  List<Map<String, String>> pendingNotifications = [];

  int generateRandomNumber(int min, int max) {
    final Random random = Random();
    return min + random.nextInt(max - min + 1);
  }

  Future<String?> getToken() async {
    print(await _firebaseMessaging.getToken());
    return await _firebaseMessaging.getToken();
  }

  void initialize() async {
    await _firebaseMessaging.requestPermission();

    String? token = await getToken();
    print("FCM Token: $token");
    _listenForNotifications();
  }

  void _listenForNotifications() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Foreground notification received:");
      _storeNotificationData(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Notification opened from background:");
      _storeNotificationData(message);
    });

    // App opened from a terminated state
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        print("App launched from a terminated state:");
        _storeNotificationData(message);
      }
    });

    print("Listening for notifications...");
  }

  void _storeNotificationData(RemoteMessage message) {
    String senderTitle = message.notification?.title ?? message.data['title'];
    String messageBody =
        message.notification?.body ?? message.data['body'] ?? "No message";

    print("User Phone: $senderTitle");
    print("Receiver Message: $messageBody");

    // Store the notification data
    pendingNotifications.add({
      'senderTitle': senderTitle,
      'messageBody': messageBody,
    });

    // Handle the notification if the app is in the foreground
    if (navigatorKey.currentContext != null) {
      handleNotification(
          senderTitle, messageBody, navigatorKey.currentContext!);
    }
  }

  Future<void> handleNotification(
      String senderTitle, String message, BuildContext context) async {
    print("handleNotification");
    int id = generateRandomNumber(1, 20);
    if (!blockedArray.contains(senderTitle)) {
      await NewLocalNotificationService.showNotification(
          id: id, title: senderTitle, body: message);
      String? classification = await checkHarassment(message);

      if (classification == "Harassment") {
        showHarassmentDialog(context, senderTitle);
      }
    } else {
      print("block number");
    }
  }

  Future<String?> checkHarassment(String message) async {
    final uri = Uri.parse(
        "http://192.168.43.99:5000/predict?message=${Uri.encodeComponent(message).toString()}");
    print("check harassment:$uri");

    try {
      final response = await http.get(uri);
      print("check harassment2");

      if (response.statusCode == 200) {
        print("check harassment3");
        final data = json.decode(response.body);
        print("success");
        print(data['classification']);
        return data['classification'];
      } else {
        throw Exception('Failed to analyze message');
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<void> loadBlockedArray() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    blockedArray = prefs.getStringList('blockedArray') ?? [];
  }

  Future<void> saveBlockedArray() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('blockedArray', blockedArray);
  }

  Future<void> showHarassmentDialog(
      BuildContext context, String senderTitle) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Harassment Message Detected'),
          content: Text('This person sent a harassment message.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Add sender to blocked list
                blockedArray.add(senderTitle);
                Navigator.of(context).pop();
              },
              child: Text('Block'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Ignore'),
            ),
          ],
        );
      },
    );
  }

  // Method to check for pending notifications
  void checkPendingNotifications(BuildContext context) {
    for (var notification in pendingNotifications) {
      handleNotification(
        notification['senderTitle']!,
        notification['messageBody']!,
        context,
      );
    }
    pendingNotifications.clear(); // Clear the list after handling
  }
}
