import 'package:flutter/material.dart';

class PatientNotificationsScreen extends StatefulWidget {
  const PatientNotificationsScreen({super.key});

  @override
  State<PatientNotificationsScreen> createState() =>
      _PatientNotificationsScreenState();
}

class _PatientNotificationsScreenState
    extends State<PatientNotificationsScreen> {
  String selectedFilter = 'All';

  final List<Map<String, dynamic>> notifications = [
    {
      'title': 'Appointment Confirmed',
      'message':
          'Your appointment with Dr. Priya Sharma has been successfully booked.',
      'time': '10 min ago',
      'type': 'Appointment',
      'icon': Icons.calendar_month_rounded,
      'read': false,
    },
    {
      'title': 'Appointment Reminder',
      'message':
          'You have an appointment with Dr. Rahul Mehta tomorrow at 10:30 AM.',
      'time': '1 hour ago',
      'type': 'Reminder',
      'icon': Icons.alarm_rounded,
      'read': false,
    },
    {
      'title': 'Bed Available',
      'message':
          'A general ward bed is currently available at CityCare Hospital.',
      'time': '2 hours ago',
      'type': 'Hospital',
      'icon': Icons.local_hospital_rounded,
      'read': true,
    },
    {
      'title': 'Doctor Consultation Update',
      'message':
          'Dr. Priya Sharma has updated your consultation information.',
      'time': 'Yesterday',
      'type': 'Doctor',
      'icon': Icons.medical_services_rounded,
      'read': true,
    },
    {
      'title': 'Medical Record Updated',
      'message':
          'Your latest medical record has been added to your HealthSync profile.',
      'time': 'Yesterday',
      'type': 'Medical',
      'icon': Icons.description_rounded,
      'read': true,
    },
    {
      'title': 'Welcome to HealthSync',
      'message':
          'Your HealthSync account is ready. You can now manage appointments, records and hospitals.',
      'time': '2 days ago',
      'type': 'System',
      'icon': Icons.notifications_active_rounded,
      'read': true,
    },
  ];

  List<Map<String, dynamic>> get filteredNotifications {
    if (selectedFilter == 'Unread') {
      return notifications
          .where((notification) => notification['read'] == false)
          .toList();
    }

    if (selectedFilter == 'Appointments') {
      return notifications
          .where(
            (notification) =>
                notification['type'] == 'Appointment' ||
                notification['type'] == 'Reminder',
          )
          .toList();
    }

    if (selectedFilter == 'Hospital') {
      return notifications
          .where((notification) => notification['type'] == 'Hospital')
          .toList();
    }

    return notifications;
  }

  int get unreadCount {
    return notifications.where((notification) {
      return notification['read'] == false;
    }).length;
  }

  void markAsRead(int index) {
    setState(() {
      notifications[index]['read'] = true;
    });
  }

  void markAllAsRead() {
    setState(() {
      for (final notification in notifications) {
        notification['read'] = true;
      }
    });
  }

  void deleteNotification(int index) {
    setState(() {
      notifications.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF172033),
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: markAllAsRead,
              child: const Text(
                'Mark all read',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(),
          _buildFilters(),
          Expanded(
            child: filteredNotifications.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      8,
                      16,
                      24,
                    ),
                    itemCount: filteredNotifications.length,
                    itemBuilder: (context, index) {
                      final notification = filteredNotifications[index];

                      final originalIndex =
                          notifications.indexOf(notification);

                      return _buildNotificationCard(
                        notification,
                        originalIndex,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(
        20,
        8,
        20,
        20,
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F1FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.notifications_active_rounded,
              color: Color(0xFF2563EB),
              size: 27,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Stay updated',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF172033),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  unreadCount == 0
                      ? 'You are all caught up!'
                      : 'You have $unreadCount unread notification'
                          '${unreadCount == 1 ? '' : 's'}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    final filters = [
      'All',
      'Unread',
      'Appointments',
      'Hospital',
    ];

    return Container(
      height: 62,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter == filter;

          return ChoiceChip(
            label: Text(filter),
            selected: isSelected,
            onSelected: (_) {
              setState(() {
                selectedFilter = filter;
              });
            },
            selectedColor: const Color(0xFF2563EB),
            backgroundColor: const Color(0xFFF1F5F9),
            labelStyle: TextStyle(
              color: isSelected
                  ? Colors.white
                  : const Color(0xFF475569),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            side: BorderSide.none,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(
    Map<String, dynamic> notification,
    int originalIndex,
  ) {
    final bool isRead = notification['read'] == true;

    return Dismissible(
      key: ValueKey(
        '${notification['title']}_${notification['time']}',
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        deleteNotification(originalIndex);
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.red,
        ),
      ),
      child: GestureDetector(
        onTap: () {
          markAsRead(originalIndex);

          _showNotificationDetails(
            notification,
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isRead
                ? Colors.white
                : const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isRead
                  ? const Color(0xFFE5E7EB)
                  : const Color(0xFFBFDBFE),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildNotificationIcon(
                notification['icon'] as IconData,
                isRead,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification['title'],
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isRead
                                  ? FontWeight.w600
                                  : FontWeight.w800,
                              color: const Color(0xFF172033),
                            ),
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF2563EB),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(
                      notification['message'],
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      notification['time'],
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(
    IconData icon,
    bool isRead,
  ) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: isRead
            ? const Color(0xFFF1F5F9)
            : const Color(0xFFDCEBFF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        icon,
        size: 22,
        color: isRead
            ? const Color(0xFF64748B)
            : const Color(0xFF2563EB),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                size: 45,
                color: Color(0xFF2563EB),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No notifications',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF172033),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'You have no notifications in this category.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationDetails(
    Map<String, dynamic> notification,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            24,
            20,
            24,
            30,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  _buildNotificationIcon(
                    notification['icon'] as IconData,
                    false,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      notification['title'],
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF172033),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                notification['message'],
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                notification['time'],
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}