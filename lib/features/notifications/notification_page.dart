import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/utils/notification_manager.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<AppNotification> allNotifications = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final data = await NotificationManager.getNotifications();
    if (mounted) {
      setState(() {
        allNotifications = data;
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("NOTIFIKASI", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          if (allNotifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded, color: Colors.red),
              onPressed: () async {
                await NotificationManager.clearAll();
                _loadNotifications();
              },
            )
        ],
      ),
      body: Column(
        children: [
          const Divider(height: 1),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : allNotifications.isEmpty
                    ? _buildEmptyState(theme)
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: allNotifications.length,
                        itemBuilder: (context, index) {
                          final notif = allNotifications[index];
                          return _buildNotificationCard(notif, theme, isDark);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(AppNotification notif, ThemeData theme, bool isDark) {
    IconData icon;
    Color color;

    switch (notif.type) {
      case NotificationType.warning:
        icon = Icons.warning_amber_rounded;
        color = Colors.orange;
        break;
      case NotificationType.success:
        icon = Icons.check_circle_outline_rounded;
        color = Colors.green;
        break;
      case NotificationType.info:
        icon = Icons.person_add_outlined;
        color = Colors.blue;
        break;
      default:
        icon = Icons.notifications_none_rounded;
        color = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notif.title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text(notif.body, style: GoogleFonts.outfit(fontSize: 13, color: theme.hintColor)),
                const SizedBox(height: 8),
                Text(
                  DateFormat('dd MMM, HH:mm').format(notif.time),
                  style: GoogleFonts.outfit(fontSize: 11, color: theme.hintColor.withOpacity(0.5)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 60, color: theme.hintColor.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text(
            "Tidak ada notifikasi untuk filter ini",
            style: GoogleFonts.outfit(color: theme.hintColor),
          ),
        ],
      ),
    );
  }
}
