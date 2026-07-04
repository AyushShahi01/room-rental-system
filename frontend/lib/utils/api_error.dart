import 'package:dio/dio.dart';

String extractApiErrorMessage(DioException error, {String fallback = 'Request failed.'}) {
  try {
    final data = error.response?.data;
    if (data is Map) {
      final topLevel = data['detail'] ?? data['message'] ?? data['error'];
      if (topLevel != null) return topLevel.toString();

      final errorsMap = data['errors'];
      if (errorsMap is Map) {
        final nonField = errorsMap['non_field_errors'];
        if (nonField is List && nonField.isNotEmpty) {
          return nonField.join('\n');
        }

        final parts = <String>[];
        for (final entry in errorsMap.entries) {
          final label = entry.key.toString();
          final val = entry.value;
          if (val is List && val.isNotEmpty) {
            parts.add('$label: ${val.join(', ')}');
          } else if (val is String && val.isNotEmpty) {
            parts.add('$label: $val');
          }
        }
        if (parts.isNotEmpty) return parts.join('\n');
      }

      final parts = <String>[];
      for (final entry in data.entries) {
        final label = entry.key.toString();
        if (label == 'errors') continue;
        final val = entry.value;
        if (val is List && val.isNotEmpty) {
          parts.add('$label: ${val.join(', ')}');
        } else if (val is String && val.isNotEmpty) {
          parts.add('$label: $val');
        }
      }
      if (parts.isNotEmpty) return parts.join('\n');
    } else if (data is String && data.isNotEmpty) {
      return data;
    }
  } catch (_) {
    // Fall through to generic handling below.
  }

  if (error.response?.statusCode == 403) {
    return 'You do not have permission to perform this action.';
  }

  return fallback;
}
