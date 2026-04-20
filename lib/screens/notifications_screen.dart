import 'package:flutter/material.dart';
import 'package:grocery_app_admin/core/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/data_provider.dart';

class AdminNotificationScreen extends StatelessWidget {
  const AdminNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'ADMIN ALERTS',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded),
            onPressed: () =>
                context.read<DataProvider>().clearAdminNotifications(),
          ),
        ],
      ),
      body: Consumer<DataProvider>(
        builder: (context, data, _) {
          if (data.isNotificationsLoading && data.adminNotifications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = data.adminNotifications;

          if (notifications.isEmpty) {
            return _buildEmpty();
          }

          return RefreshIndicator(
            onRefresh: data.fetchAdminNotifications,
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final n = notifications[i];
                return GestureDetector(
                  onTap: () => data.markAdminNotificationRead(n.id),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: n.isRead
                          ? Colors.grey[50]
                          : AppTheme.primaryGreen.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: n.isRead
                            ? Colors.grey[200]!
                            : AppTheme.primaryGreen.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: n.isRead
                                ? Colors.grey[200]
                                : AppTheme.primaryGreen.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            n.type == 'new_order'
                                ? Icons.shopping_bag_rounded
                                : Icons.star_rounded,
                            color: n.isRead
                                ? Colors.grey[600]
                                : AppTheme.primaryGreen,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    n.title,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  if (!n.isRead)
                                    const CircleAvatar(
                                      radius: 4,
                                      backgroundColor: Colors.red,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                n.body,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _getTimeString(n.time),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primaryGreen.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _getTimeString(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }
}
