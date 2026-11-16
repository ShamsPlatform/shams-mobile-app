import 'dart:io';

/// Enforces strict Clean Architecture structure, layer import boundaries, and
/// external SDK confinement across `lib/`.
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

const _allowedTopLevelDirs = {'app', 'core', 'features'};
const _allowedTopLevelFiles = {'main.dart'};

final _legacyImportPattern = RegExp(
  r'''['\"]package:shams_mobile_app/(models|providers|services|utils|views|widgets)/''',
);
final _relativeImportPattern = RegExp(r'''^(import|export)\s+['\"]\.\.?/''');
final _featurePathPattern = RegExp(r'^lib/features/([^/]+)/');
final _featureDataImportPattern = RegExp(
  r'package:shams_mobile_app/features/([^/]+)/data/',
);

final _supabaseAllowedPaths = <RegExp>[
  RegExp(r'^lib/main\.dart$'),
  RegExp(r'^lib/core/di/injection\.dart$'),
  RegExp(r'^lib/core/data/datasources/'),
  RegExp(r'^lib/features/[^/]+/data/datasources/'),
];

final _sharedPrefsAllowedPaths = <RegExp>[
  RegExp(r'^lib/core/di/injection\.dart$'),
  RegExp(r'^lib/core/theme/theme_storage\.dart$'),
  RegExp(r'^lib/core/l10n/language_storage\.dart$'),
  RegExp(r'^lib/features/[^/]+/data/datasources/'),
];

final _rules = <_ImportRule>[
  _ImportRule(
    pathPattern: RegExp(r'^lib/core/'),
    skipIf: (path) => path == 'lib/core/di/injection.dart',
    forbiddenImports: ['/features/'],
  ),
  _ImportRule(
    pathPattern: RegExp(r'^lib/app/'),
    forbiddenImports: [RegExp(r'/features/[^/]+/data/')],
  ),
  _ImportRule(
    pathPattern: RegExp(r'^lib/features/[^/]+/domain/'),
    forbiddenImports: ['package:flutter/', '/data/', '/presentation/', '/app/'],
  ),
  _ImportRule(
    pathPattern: RegExp(r'^lib/features/[^/]+/presentation/'),
    forbiddenImports: ['/data/'],
  ),
  _ImportRule(
    pathPattern: RegExp(r'^lib/features/[^/]+/data/'),
    forbiddenImports: ['/presentation/', '/app/'],
  ),
];

String _normalize(String path) => path.replaceAll('\\', '/');

bool _matchesAny(String path, List<RegExp> patterns) =>
    patterns.any((pattern) => pattern.hasMatch(path));

int _checkRootLayout(Directory libDir) {
  var violations = 0;
  for (final entity in libDir.listSync()) {
    final normalized = _normalize(entity.path);
    final name = normalized.split('/').last;
    if (entity is Directory && !_allowedTopLevelDirs.contains(name)) {
      stdout.writeln('$normalized  unexpected top-level directory under lib/');
      violations++;
    } else if (entity is File && !_allowedTopLevelFiles.contains(name)) {
      stdout.writeln('$normalized  unexpected top-level file under lib/');
      violations++;
    }
  }
  return violations;
}

int _checkFile(File file) {
  final normalizedPath = _normalize(file.path);
  final lines = file.readAsLinesSync();
  final featureOwner = _featurePathPattern
      .firstMatch(normalizedPath)
      ?.group(1);
  final allowSupabase = _matchesAny(normalizedPath, _supabaseAllowedPaths);
  final allowSharedPrefs = _matchesAny(
    normalizedPath,
    _sharedPrefsAllowedPaths,
  );

  var violations = 0;

  for (var i = 0; i < lines.length; i++) {
    final lineNumber = i + 1;
    final trimmed = lines[i].trim();
    if (trimmed.startsWith('//')) continue;

    if (!allowSupabase && trimmed.contains('Supabase.instance')) {
      stdout.writeln(
        '$normalizedPath:$lineNumber  forbidden "Supabase.instance" outside composition root or datasources',
      );
      violations++;
    }

    final isDirective =
        trimmed.startsWith('import ') || trimmed.startsWith('export ');
    if (!isDirective) continue;

    if (_legacyImportPattern.hasMatch(trimmed)) {
      stdout.writeln(
        '$normalizedPath:$lineNumber  forbidden legacy folder import',
      );
      violations++;
    }

    if (_relativeImportPattern.hasMatch(trimmed)) {
      stdout.writeln(
        '$normalizedPath:$lineNumber  forbidden relative import (use package: imports)',
      );
      violations++;
    }

    if (!allowSupabase && trimmed.contains('package:supabase_flutter/')) {
      stdout.writeln(
        '$normalizedPath:$lineNumber  forbidden "package:supabase_flutter/" outside composition root or datasources',
      );
      violations++;
    }

    if (!allowSharedPrefs && trimmed.contains('package:shared_preferences/')) {
      stdout.writeln(
        '$normalizedPath:$lineNumber  forbidden "package:shared_preferences/" outside DI, theme storage, or datasources',
      );
      violations++;
    }

    if (featureOwner != null) {
      final importedFeature = _featureDataImportPattern
          .firstMatch(trimmed)
          ?.group(1);
      if (importedFeature != null && importedFeature != featureOwner) {
        stdout.writeln(
          '$normalizedPath:$lineNumber  forbidden cross-feature data import ("$importedFeature" from "$featureOwner")',
        );
        violations++;
      }
    }

    for (final rule in _rules) {
      if (!rule.pathPattern.hasMatch(normalizedPath)) continue;
      if (rule.skipIf?.call(normalizedPath) ?? false) continue;

      for (final banned in rule.forbiddenImports) {
        final matched = switch (banned) {
          final RegExp r => r.hasMatch(trimmed),
          final String s => trimmed.contains(s),
          _ => false,
        };
        if (matched) {
          stdout.writeln(
            '$normalizedPath:$lineNumber  forbidden import "$banned"',
          );
          violations++;
        }
      }
    }
  }

  return violations;
}

void main() {
  final libDir = Directory('lib');
  if (!libDir.existsSync()) {
    stderr.writeln('Error: lib/ directory not found.');
    exit(1);
  }

  var violations = _checkRootLayout(libDir);

  for (final entity in libDir.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    violations += _checkFile(entity);
  }

  if (violations > 0) {
    stderr.writeln('Found $violations architecture violation(s).');
    exit(1);
  }

  stdout.writeln('Architecture check passed.');
}
