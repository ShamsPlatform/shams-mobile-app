import 'dart:io';

/// Enforces Clean Architecture layer import boundaries across `lib/core/`,
/// `lib/app/`, and `lib/features/`.
///
/// Legacy folders (`models/`, `providers/`, `services/`, `views/`, `widgets/`)
/// are ignored during the incremental migration and removed in Phase 8.
class _ImportRule {
  final RegExp pathPattern;
  final List<Pattern> forbiddenImports;
  final bool Function(String normalizedPath)? skipIf;

  const _ImportRule({
    required this.pathPattern,
    required this.forbiddenImports,
    this.skipIf,
  });
}

final _rules = <_ImportRule>[
  _ImportRule(
    pathPattern: RegExp(r'^lib/core/'),
    skipIf: (path) => path == 'lib/core/di/injection.dart',
    forbiddenImports: ['/features/'],
  ),
  _ImportRule(
    pathPattern: RegExp(r'^lib/app/'),
    forbiddenImports: [
      'package:supabase_flutter/',
      'package:shared_preferences/',
      '/services/',
      RegExp(r'/features/[^/]+/data/'),
    ],
  ),
  _ImportRule(
    pathPattern: RegExp(r'^lib/features/'),
    forbiddenImports: ['/services/'],
  ),
  _ImportRule(
    pathPattern: RegExp(r'^lib/features/[^/]+/domain/'),
    forbiddenImports: [
      'package:flutter/',
      'package:supabase_flutter/',
      'package:shared_preferences/',
      '/data/',
      '/presentation/',
    ],
  ),
  _ImportRule(
    pathPattern: RegExp(r'^lib/features/[^/]+/presentation/'),
    forbiddenImports: [
      'package:supabase_flutter/',
      'package:shared_preferences/',
      '/data/',
    ],
  ),
  _ImportRule(
    pathPattern: RegExp(r'^lib/features/[^/]+/data/'),
    forbiddenImports: ['/presentation/'],
  ),
];

final _checkedRootPattern = RegExp(r'^lib/(core|app|features)/');

void main() {
  final libDir = Directory('lib');
  if (!libDir.existsSync()) {
    stderr.writeln('Error: lib/ directory not found.');
    exit(1);
  }

  var violations = 0;

  for (final entity in libDir.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;

    final normalizedPath = entity.path.replaceAll('\\', '/');
    if (!_checkedRootPattern.hasMatch(normalizedPath)) continue;

    final lines = entity.readAsLinesSync();
    for (final rule in _rules) {
      if (!rule.pathPattern.hasMatch(normalizedPath)) continue;
      if (rule.skipIf?.call(normalizedPath) ?? false) continue;

      for (var i = 0; i < lines.length; i++) {
        final line = lines[i].trim();
        if (!line.startsWith('import ')) continue;

        for (final banned in rule.forbiddenImports) {
          final matched = switch (banned) {
            final RegExp r => r.hasMatch(line),
            final String s => line.contains(s),
            _ => false,
          };
          if (matched) {
            stdout.writeln(
              '$normalizedPath:${i + 1}  forbidden import "$banned"',
            );
            violations++;
          }
        }
      }
    }
  }

  if (violations > 0) {
    stderr.writeln('Found $violations architecture violation(s).');
    exit(1);
  }

  stdout.writeln('Architecture check passed.');
}
