import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:room_rental_system/controllers/notifications_controller.dart';
import 'package:room_rental_system/widgets/notification_item.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final NotificationsController ctrl = Get.find<NotificationsController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: ctrl.markAllRead,
            child: const Text(
              'Mark all read',
              style: TextStyle(
                color: Colors.blueAccent,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: Obx(
              () => Row(
                children: List.generate(ctrl.tabs.length, (i) {
                  final isSelected = ctrl.selectedTab.value == i;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => ctrl.selectTab(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: isSelected
                                  ? Colors.blueAccent
                                  : Colors.transparent,
                              width: 2.5,
                            ),
                          ),
                        ),
                        child: Text(
                          ctrl.tabs[i],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? Colors.blueAccent
                                : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          Expanded(
            child: Obx(() {
              final today = ctrl.todayNotifications;
              final earlier = ctrl.earlierNotifications;
              final hasAny = today.isNotEmpty || earlier.isNotEmpty;

              if (!hasAny) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.notifications_off_outlined,
                        size: 64,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No notifications here yet',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  if (today.isNotEmpty) ...[
                    _SectionHeader(label: 'TODAY'),
                    ...today.map((n) => NotificationItemWidget(item: n)),
                  ],

                  if (earlier.isNotEmpty) ...[
                    _SectionHeader(label: 'EARLIER'),
                    ...earlier.map((n) => NotificationItemWidget(item: n)),
                  ],

                  const SizedBox(height: 24),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F7FA),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade500,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
