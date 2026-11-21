/// Formatting helpers extracted from legacy models and widgets (F6).
///
/// All outputs are locale-neutral: callers in the presentation layer are
/// responsible for providing localized labels so that the domain/util layer
/// remains Flutter-free and free of hard-coded Arabic strings.
///
/// Example (presentation layer usage):
/// ```dart
/// final l10n = AppLocalizations.of(context)!;
/// final label = formatRelativeTime(
///   post.createdAt,
///   nowLabel: l10n.nowRelative,
///   minutesLabel: (n) => l10n.minutesAgo(n),
///   hoursLabel:   (n) => l10n.hoursAgo(n),
///   daysLabel:    (n) => l10n.daysAgo(n),
/// );
/// ```
String formatRelativeTime(
  DateTime dateTime, {
  DateTime? now,
  String nowLabel = 'الآن',
  String Function(int count)? minutesLabel,
  String Function(int count)? hoursLabel,
  String Function(int count)? daysLabel,
}) {
  final reference = now ?? DateTime.now();
  final diff = reference.difference(dateTime);
  if (diff.inDays > 7) {
    return '${dateTime.year}-${dateTime.month}-${dateTime.day}';
  } else if (diff.inDays >= 1) {
    return daysLabel != null ? daysLabel(diff.inDays) : 'منذ ${diff.inDays} يوم';
  } else if (diff.inHours >= 1) {
    return hoursLabel != null ? hoursLabel(diff.inHours) : 'منذ ${diff.inHours} ساعة';
  } else if (diff.inMinutes >= 1) {
    return minutesLabel != null ? minutesLabel(diff.inMinutes) : 'منذ ${diff.inMinutes} دقيقة';
  } else {
    return nowLabel;
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
