import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/notifications_controller.dart';

/// A single notification list item.
class NotificationItemWidget extends StatelessWidget {
  final NotificationItem item;

  const NotificationItemWidget({super.key, required this.item});

  /// Returns an icon and colour based on notification category.
  (IconData, Color) get _iconData {
    switch (item.category) {
      case 'rent':
        return (Icons.receipt_long_outlined, Colors.green);
      case 'bookings':
        return (Icons.bookmark_added_outlined, Colors.blueAccent);
      case 'maintenance':
        return (Icons.build_outlined, Colors.orange);
      default:
        return (Icons.notifications_none, Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _iconData;

    return Obx(() => Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            color: item.isRead.value ? Colors.white : const Color(0xFFEEF4FF),
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade100, width: 1),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Coloured icon circle
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: item.isRead.value
                                  ? FontWeight.w500
                                  : FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          item.time,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              // Unread dot
              if (!item.isRead.value) ...[
                const SizedBox(width: 8),
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: const BoxDecoration(
                    color: Colors.blueAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ));
  }
}
