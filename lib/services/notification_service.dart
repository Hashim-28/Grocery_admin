import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Handling a background message: ${message.messageId}");
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Register background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Android Initialization
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS Initialization
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _notificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap logic here if needed
      },
    );

    // 1. Handle FCM foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        showNotification(
          id: message.notification.hashCode,
          title: message.notification?.title ?? 'Notification',
          body: message.notification?.body ?? '',
          payload: message.data.toString(),
        );
      }
    });

    // 2. Handle background/terminated state tap
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('A new onMessageOpenedApp event was published!');
    });

    // 3. Get and save token
    await updateToken();

    // 4. Listen for token refresh
    _fcm.onTokenRefresh.listen((token) {
      _saveTokenToSupabase(token);
    });
  }

  Future<void> updateToken() async {
    try {
      String? token = await _fcm.getToken();
      if (token != null) {
        debugPrint("Admin FCM Token: $token");
        await _saveTokenToSupabase(token);
      }
    } catch (e) {
      debugPrint("Error getting Admin FCM token: $e");
    }
  }

  Future<void> _saveTokenToSupabase(String token) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        // Check if user is in profiles or staff_members
        // Admins are in profiles, staff might be in staff_members
        // We can try to upsert in both or check role first.
        // For simplicity, we'll try to update profiles first.
        await Supabase.instance.client
            .from('profiles')
            .update({'fcm_token': token})
            .eq('id', user.id);
            
        debugPrint("Admin FCM Token saved to Supabase Profiles");
      }
    } catch (e) {
      debugPrint("Error saving Admin FCM token to Supabase: $e");
    }
  }

  Future<bool> requestPermissions() async {
    // Request FCM permission
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (Platform.isAndroid) {
      // Request POST_NOTIFICATIONS permission for Android 13+
      final status = await Permission.notification.request();
      return status.isGranted;
    } else if (Platform.isIOS) {
      final bool? granted = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return granted ?? false;
    }
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'grocery_admin_channel',
          'Grocery Admin Notifications',
          channelDescription: 'Notifications for new orders and reviews',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _notificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: payload,
    );
  }
}
