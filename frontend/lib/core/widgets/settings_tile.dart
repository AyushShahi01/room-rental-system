import 'package:flutter/material.dart';

/// A reusable settings list tile.
///
/// Supports three modes:
///   - Arrow (navigates somewhere) — pass [onTap]
///   - Toggle — pass [value] and [onToggle]
///   - Value label — pass [trailing] string
class SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;

  /// For navigation tiles
  final VoidCallback? onTap;

  /// For toggle tiles
  final bool? value;
  final ValueChanged<bool>? onToggle;

  /// For value label tiles (e.g. "English", "Public")
  final String? trailingLabel;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.onTap,
    this.value,
    this.onToggle,
    this.trailingLabel,
  });

  @override
  Widget build(BuildContext context) {
    Widget trailing;

    if (value != null && onToggle != null) {
      // Toggle switch tile
      trailing = Switch(
        value: value!,
        onChanged: onToggle,
        activeThumbColor: Colors.blueAccent,
      );
    } else if (trailingLabel != null) {
      // Static label tile
      trailing = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            trailingLabel!,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
        ],
      );
    } else {
      // Arrow tile
      trailing = Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20);
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            // Title + optional subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ],
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
