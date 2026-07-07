import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../services/notification_api_service.dart';

class BroadcastNotificationScreen extends StatefulWidget {
  const BroadcastNotificationScreen({super.key});

  @override
  State<BroadcastNotificationScreen> createState() => _BroadcastNotificationScreenState();
}

class _BroadcastNotificationScreenState extends State<BroadcastNotificationScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  bool _isSending = false;

  Future<void> _sendNotification() async {
    if (_titleController.text.isEmpty || _bodyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in both title and body')),
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      await NotificationApiService().broadcastNotification(
        title: _titleController.text,
        body: _bodyController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Broadcast notification triggered successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('CUSTOM NOTIFICATION'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SEND BROADCAST',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.textGrey,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'NOTIFICATION TITLE',
                hintText: 'e.g. Weekend Flash Sale! ⚡',
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _bodyController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'MESSAGE BODY',
                hintText: 'e.g. Get 20% off on all fresh vegetables this Sunday.',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _isSending ? null : _sendNotification,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSending
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'SEND TO ALL USERS',
                      style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
                    ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.bgGrey,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderGrey),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppTheme.textGrey, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'This will send a push notification to every registered user on the platform.',
                      style: TextStyle(color: AppTheme.textGrey, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
