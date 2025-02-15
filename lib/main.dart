import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:whatsapp_messenger/common/routes/routes.dart';
import 'package:whatsapp_messenger/common/theme/dark_theme.dart';
import 'package:whatsapp_messenger/common/theme/light_theme.dart';
import 'package:whatsapp_messenger/feature/auth/controller/auth_controller.dart';
import 'package:whatsapp_messenger/feature/auth/services/notification_service.dart';
import 'package:whatsapp_messenger/feature/home/pages/home_page.dart';
import 'package:whatsapp_messenger/feature/welcome/pages/welcome_page.dart';
import 'package:whatsapp_messenger/firebase_options.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Background notification received: ${message.notification?.body}");

  String senderTitle =
      message.notification?.title ?? message.data['title'] ?? "Unknown";

  if (blockedArray.contains(senderTitle)) {
    print(
        "Background notification from blocked sender: $senderTitle. Ignoring...");
    return; // Exit the method if the sender is blocked
  }

  // Store the notification data
  print("Storing background notification: ${message.notification?.title}");
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final notificationStateProvider =
    StateNotifierProvider<NotificationNotifier, List<RemoteMessage>>((ref) {
  return NotificationNotifier();
});

class NotificationNotifier extends StateNotifier<List<RemoteMessage>> {
  NotificationNotifier() : super([]);

  void addNotification(RemoteMessage message) {
    state = [...state, message];
  }

  void clearNotifications() {
    state = [];
  }
}

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize NotificationService
  final notificationService = NotificationService();
  await notificationService.loadBlockedArray();
  notificationService.initialize();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(
    ProviderScope(
      overrides: [
        notificationServiceProvider.overrideWithValue(notificationService),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WhatsApp Me',
      theme: lightTheme(),
      darkTheme: darkTheme(),
      home: ref.watch(userInfoAuthProvider).when(
            data: (user) {
              if (user == null) return const WelcomePage();
              return HomePage();
            },
            error: (error, trace) {
              return const Scaffold(
                body: Center(
                  child: Text('Something wrong happened'),
                ),
              );
            },
            loading: () => const SizedBox(),
          ),
      onGenerateRoute: Routes.onGenerateRoute,
    );
  }
}
