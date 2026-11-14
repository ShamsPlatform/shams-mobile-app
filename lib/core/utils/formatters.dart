/// Formatting helpers extracted from legacy models and widgets (F6).
///
/// Produces the exact same strings as the legacy inline formatting logic.
String formatRelativeTime(DateTime dateTime, {DateTime? now}) {
  final reference = now ?? DateTime.now();
  final diff = reference.difference(dateTime);
  if (diff.inDays > 7) {
    return '${dateTime.year}-${dateTime.month}-${dateTime.day}';
  } else if (diff.inDays >= 1) {
    return 'منذ ${diff.inDays} يوم';
  } else if (diff.inHours >= 1) {
    return 'منذ ${diff.inHours} ساعة';
  } else if (diff.inMinutes >= 1) {
    return 'منذ ${diff.inMinutes} دقيقة';
  } else {
    return 'الآن';
  }
}

/// Formats large integer counts compactly (e.g. `45800` -> `"45.8K"`).
String formatCompactNumber(int count) {
  if (count >= 1000000) {
    return '${(count / 1000000).toStringAsFixed(1)}M';
  }
  if (count >= 1000) {
    return '${(count / 1000).toStringAsFixed(1)}K';
  }
  return '$count';
}
