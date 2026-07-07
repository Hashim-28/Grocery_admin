import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class NotificationApiService {
  static final NotificationApiService _instance = NotificationApiService._internal();
  factory NotificationApiService() => _instance;
  NotificationApiService._internal();

  final _supabase = Supabase.instance.client;

  // Firebase Service Account Details
  static const _serviceAccount = {
    "project_id": "diesel-cash-carry",
    "client_email": "firebase-adminsdk-fbsvc@diesel-cash-carry.iam.gserviceaccount.com",
    "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC7Kw4xpzByFV7w\nivCVOtUkUrRb8vGA0fxjkHLa948HfKi94LYEsvo+PameiKGWfnnxzCiAbetLqAyD\nDsx0PCXVkB2m6/Ezp5cFwMHTUvG2XnL4bKLSgZcfTmuA6+O97FsajJ23qxhlIGcQ\nPrmpwgDjE/dhEloYd5mefRFMutqoQXQb+78qrMfw+I1UDibip/jaPVWDb4lw54Bu\nD5tXmGTnM6pxGPEf/4GYAUgW44puDEhZ+anLVHlXYZpWRCTetNMEx78nh49GaBya\nYYbvziksfwtpKuU4usOXgCMvtN8rhVnd1F56IjCJ0d4Xo8Ca23/IuNBqFTwz5xhy\nCM6qJOG9AgMBAAECggEAIxywJHt3WKeOsHR4Lp6jVpWXVTqNuLtr7CewjEht0hs+\nMqTBsL78uAlsVRvPqIJgkQ5aOMGmJwLHGh0AGPwhot9O2L4heS3C5KblFaZVRv+P\n9O+4WeJKvepBu6VFC5+X9bKUcdzMjkgWXZNO1DxbWz4nJdRCB54EORnAUZMqKu8O\nN0oF+b7yEb78vIwLKRcYpb14rVzQ3TexOn6FyOAOinT9fzOHyWOxW7mASFEn0nmp\nFRTa1gBVi1gHlP/u+YR8tsmPNCwrtYZfOcYexNb7BvW2sPyGqEKoDPsUyKUltitb\n1oRT9cToBb4wQpPtTzmglKuKh7sr0PWw80hPWI6HgQKBgQDosg5vcjRM6janMhTF\nLkX2GhL7SaxAl81M2TXut66xwZDoK36qpx9g4nceHy4BeGLmK+DbJlUHsBG+5Lm7\nuZtbfJ7IPmaRAAFk7OA1hRlK7DZKzefN5fkCbEKSB86JvZyxs3ii2zT+1HGenF8D\nE+n7Oj3+Ges46RcbpQWJwwHVQQKBgQDN6cAPGnOiAHUd9OX949o2igZiNDwR8wZj\n4qXM1BjP4avL9e+VppS27vh4U2bINxCej0v60nMMbBIm3IEtMs/QRViN2Mk1deKF\nk4L+S4Jtyn9rEHIQMjHTABgKKPk4+BLnvRRQFPiWnD/b2gGUjljaQ/RDd2OgkiZJ\nmBZhoUqBfQKBgCH39DGCq23a9vV7UxrhwWbGsaSrQZEAWADy6HObrs3WIvAxgUEq\nOmNrS9ZC2PVv/If7OczkEJ+ZrU1/mDl2Q96cF5XFvjVGme2Aws4tSt7sEpTi8AbX\nnn0jDqjAqP7khh5Ow7qKY3cbziZIT3pkitCY1PnmELdzF2N6uI8+v2LBAoGABA2X\n1DRHFmc/5ukNJeQ4RV6OJZy1mfzYoVqyvMdn/Z+JjCg5IQ74Wml1xpiNq186GoTj\nj/pYfWQbL1yjxkn7wTO8PH6J5118qfhvWaYO2S5lN6xJMnxqcqbL0ldgIHjxllIo\ndjMTeZN1xlQSN+RdZ15zDmjpMx3tVwGBX0aXetkCgYEAzuS6ibOZ472d/Oo4wcgv\nrUhNnjvfMyyxKrozh4v5t6Kw0kGCr599i3imRX/hR74iAHkZJZSErzzHxsDnEMjb\n5obvsj8Ejy6Ta4PYL6/XzmMYfNYo3+vOlQEvd7gg6qpaAmb4sssRee1OsxIfop0h\nmGKKQ5/TAe74gmm9g8X5z+w=\n-----END PRIVATE KEY-----\n",
  };

  /// Gets an access token using the Service Account
  Future<String> _getAccessToken() async {
    try {
      final accountCredentials = auth.ServiceAccountCredentials.fromJson(_serviceAccount);
      const scopes = ['https://www.googleapis.com/auth/cloud-platform'];
      final client = await auth.clientViaServiceAccount(accountCredentials, scopes);
      return client.credentials.accessToken.data;
    } catch (e) {
      debugPrint('Error getting FCM access token: $e');
      rethrow;
    }
  }

  /// Sends a notification to a specific FCM token
  Future<void> _sendRawNotification({
    required String token,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      final accessToken = await _getAccessToken();
      final url = 'https://fcm.googleapis.com/v1/projects/${_serviceAccount['project_id']}/messages:send';
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'message': {
            'token': token,
            'notification': {
              'title': title,
              'body': body,
            },
            'data': data ?? {},
            'android': {
              'notification': {
                'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                'channel_id': 'high_importance_channel',
              },
            },
          }
        }),
      );

      if (response.statusCode != 200) {
        debugPrint('FCM Error: ${response.body}');
      } else {
        debugPrint('FCM Success: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error sending raw notification: $e');
    }
  }

  /// Sends a notification to a specific Supabase user
  Future<void> sendNotification({
    required String title,
    required String body,
    required String recipientId,
    Map<String, dynamic>? data,
  }) async {
    try {
      final res = await _supabase
          .from('profiles')
          .select('fcm_token')
          .eq('id', recipientId)
          .maybeSingle();

      if (res != null && res['fcm_token'] != null) {
        await _sendRawNotification(
          token: res['fcm_token'],
          title: title,
          body: body,
          data: data,
        );
      } else {
        debugPrint('No FCM token found for user $recipientId');
      }
    } catch (e) {
      debugPrint('Error in sendNotification: $e');
    }
  }

  /// Sends a notification to all admins
  Future<void> notifyAdmins({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      final res = await _supabase
          .from('profiles')
          .select('fcm_token')
          .eq('role', 'admin')
          .not('fcm_token', 'is', null);

      final List tokens = (res as List).map((p) => p['fcm_token'] as String).toList();
      
      for (var token in tokens) {
        await _sendRawNotification(
          token: token,
          title: title,
          body: body,
          data: data,
        );
      }
      debugPrint('Admin notifications sent to ${tokens.length} admins');
    } catch (e) {
      debugPrint('Error in notifyAdmins: $e');
    }
  }

  /// Sends a broadcast notification to all users
  Future<void> broadcastNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      final res = await _supabase
          .from('profiles')
          .select('fcm_token')
          .not('fcm_token', 'is', null);

      final List tokens = (res as List).map((p) => p['fcm_token'] as String).toList();

      for (var token in tokens) {
        await _sendRawNotification(
          token: token,
          title: title,
          body: body,
          data: data,
        );
      }
      debugPrint('Broadcast sent to ${tokens.length} users');
    } catch (e) {
      debugPrint('Error in broadcastNotification: $e');
    }
  }
}
