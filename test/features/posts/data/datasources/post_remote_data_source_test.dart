import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shams_mobile_app/core/data/datasources/file_storage_data_source.dart';
import 'package:shams_mobile_app/features/posts/data/datasources/post_remote_data_source.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockFileStorageDataSource extends Mock implements FileStorageDataSource {}

class _FakePostgrestTransformBuilder<T> extends Fake
    implements PostgrestTransformBuilder<T> {
  _FakePostgrestTransformBuilder(this._run);

  final Future<T> Function() _run;

  @override
  Future<R> then<R>(
    FutureOr<R> Function(T value) onValue, {
    Function? onError,
  }) {
    return Future<T>.sync(_run).then(onValue, onError: onError);
  }
}

class _FakePostgrestFilterBuilder<T> extends Fake
    implements PostgrestFilterBuilder<T> {
  _FakePostgrestFilterBuilder(this._run);

  final Future<T> Function() _run;

  @override
  PostgrestFilterBuilder<T> eq(String column, Object value) => this;

  @override
  PostgrestTransformBuilder<PostgrestList> select([String columns = '*']) {
    return _FakePostgrestTransformBuilder<PostgrestList>(
      () async => const <PostgrestMap>[],
    );
  }

  @override
  PostgrestTransformBuilder<PostgrestMap?> maybeSingle() {
    return _FakePostgrestTransformBuilder<PostgrestMap?>(() async {
      final result = await _run();
      if (result is PostgrestMap?) return result;
      return null;
    });
  }

  @override
  PostgrestTransformBuilder<PostgrestMap> single() {
    return _FakePostgrestTransformBuilder<PostgrestMap>(() async {
      final result = await _run();
      return (result as PostgrestMap?) ?? <String, dynamic>{};
    });
  }

  @override
  Future<R> then<R>(
    FutureOr<R> Function(T value) onValue, {
    Function? onError,
  }) {
    return Future<T>.sync(_run).then(onValue, onError: onError);
  }
}

class _FakeSupabaseQueryBuilder extends Fake implements SupabaseQueryBuilder {
  _FakeSupabaseQueryBuilder({
    Future<PostgrestList> Function()? onSelect,
    Future<dynamic> Function(Map<dynamic, dynamic> values)? onUpdate,
    Future<dynamic> Function(Object values)? onInsert,
  })  : _onSelect = onSelect,
        _onUpdate = onUpdate,
        _onInsert = onInsert;

  final Future<PostgrestList> Function()? _onSelect;
  final Future<dynamic> Function(Map<dynamic, dynamic> values)? _onUpdate;
  final Future<dynamic> Function(Object values)? _onInsert;

  @override
  PostgrestFilterBuilder<PostgrestList> select([String columns = '*']) {
    return _FakePostgrestFilterBuilder<PostgrestList>(
      _onSelect ?? () async => const <PostgrestMap>[],
    );
  }

  @override
  PostgrestFilterBuilder<dynamic> update(Map<dynamic, dynamic> values) {
    return _FakePostgrestFilterBuilder<dynamic>(
      () => (_onUpdate ?? (_) async => null)(values),
    );
  }

  @override
  PostgrestFilterBuilder<dynamic> insert(
    Object values, {
    bool defaultToNull = true,
  }) {
    return _FakePostgrestFilterBuilder<dynamic>(
      () => (_onInsert ?? (_) async => null)(values),
    );
  }
}

void main() {
  late MockSupabaseClient db;
  late MockGoTrueClient auth;
  late MockFileStorageDataSource storage;

  setUp(() {
    db = MockSupabaseClient();
    auth = MockGoTrueClient();
    storage = MockFileStorageDataSource();
    when(() => db.auth).thenReturn(auth);
  });

  group('incrementPostsViewsForTest (K2)', () {
    test('short-circuits on empty postIds without calling rpc or from',
        () async {
      final dataSource = PostRemoteDataSourceImpl(db, storage);

      await dataSource.incrementPostsViewsForTest(const []);

      verifyNever(() => db.rpc<dynamic>(any(), params: any(named: 'params')));
      verifyNever(() => db.from(any()));
    });

    test('uses increment_post_views RPC and skips legacy update loop on Ok',
        () async {
      final dataSource = PostRemoteDataSourceImpl(db, storage);
      when(
        () => db.rpc<dynamic>(
          'increment_post_views',
          params: {'post_ids': ['p1', 'p2']},
        ),
      ).thenAnswer(
        (_) => _FakePostgrestFilterBuilder<dynamic>(() async => null),
      );

      await dataSource.incrementPostsViewsForTest(['p1', 'p2']);

      verify(
        () => db.rpc<dynamic>(
          'increment_post_views',
          params: {'post_ids': ['p1', 'p2']},
        ),
      ).called(1);
      verifyNever(() => db.from(any()));
    });

    test('falls back to legacy read-update loop when RPC is missing (PGRST202)',
        () async {
      final dataSource = PostRemoteDataSourceImpl(db, storage);
      final updatedPayloads = <Map<dynamic, dynamic>>[];

      when(
        () => db.rpc<dynamic>(
          'increment_post_views',
          params: {'post_ids': ['p1']},
        ),
      ).thenAnswer(
        (_) => _FakePostgrestFilterBuilder<dynamic>(
          () async => throw const PostgrestException(
            message: 'function increment_post_views not found',
            code: 'PGRST202',
          ),
        ),
      );

      final postsBuilder = _SingleSelectPostsBuilder(
        row: {'views_count': 7},
        onUpdate: updatedPayloads.add,
      );
      when(() => db.from('posts')).thenAnswer((_) => postsBuilder);

      await dataSource.incrementPostsViewsForTest(['p1']);

      expect(updatedPayloads, [
        {'views_count': 8},
      ]);
    });

    test('does not fall back when RPC fails with non-missing PostgrestException',
        () async {
      final dataSource = PostRemoteDataSourceImpl(db, storage);

      when(
        () => db.rpc<dynamic>(
          'increment_post_views',
          params: {'post_ids': ['p1']},
        ),
      ).thenAnswer(
        (_) => _FakePostgrestFilterBuilder<dynamic>(
          () async => throw const PostgrestException(
            message: 'permission denied',
            code: '42501',
          ),
        ),
      );

      await dataSource.incrementPostsViewsForTest(['p1']);

      verifyNever(() => db.from('posts'));
    });
  });

  group('useDbNotificationTriggers (N1)', () {
    const user = User(
      id: 'liker-1',
      appMetadata: {},
      userMetadata: {},
      aud: 'authenticated',
      createdAt: '2026-01-01T00:00:00.000Z',
    );

    test('skips notification query/insert when useDbNotificationTriggers is true',
        () async {
      when(() => auth.currentUser).thenReturn(user);
      when(() => db.from('post_likes')).thenAnswer(
        (_) => _FakeSupabaseQueryBuilder(
          onSelect: () async => const <PostgrestMap>[],
          onInsert: (_) async => null,
        ),
      );

      final dataSource = PostRemoteDataSourceImpl(
        db,
        storage,
        useDbNotificationTriggers: true,
      );

      final liked = await dataSource.toggleLike('post-1');

      expect(liked, isTrue);
      verifyNever(() => db.from('posts'));
      verifyNever(() => db.from('notifications'));
    });

    test('inserts like notification when useDbNotificationTriggers is false',
        () async {
      final notificationInserts = <Object>[];
      when(() => auth.currentUser).thenReturn(user);
      when(() => db.from('post_likes')).thenAnswer(
        (_) => _FakeSupabaseQueryBuilder(
          onSelect: () async => const <PostgrestMap>[],
          onInsert: (_) async => null,
        ),
      );
      when(() => db.from('posts')).thenAnswer(
        (_) => _SingleSelectPostsBuilder(
          row: {'author_id': 'author-2', 'text_details': 'لوح شمسي جديد'},
        ),
      );
      when(() => db.from('profiles')).thenAnswer(
        (_) => _SingleSelectPostsBuilder(row: {'name': 'أنيس'}),
      );
      when(() => db.from('notifications')).thenAnswer(
        (_) => _FakeSupabaseQueryBuilder(
          onInsert: (values) async {
            notificationInserts.add(values);
            return null;
          },
        ),
      );

      final dataSource = PostRemoteDataSourceImpl(
        db,
        storage,
        useDbNotificationTriggers: false,
      );

      final liked = await dataSource.toggleLike('post-1');
      await Future<void>.delayed(Duration.zero);

      expect(liked, isTrue);
      expect(notificationInserts, hasLength(1));
      final payload = notificationInserts.single as Map<String, dynamic>;
      expect(payload['user_id'], 'author-2');
      expect(payload['type'], 'like');
      expect(payload['target_id'], 'post-1');
    });
  });
}

class _SingleSelectPostsBuilder extends Fake implements SupabaseQueryBuilder {
  _SingleSelectPostsBuilder({
    required this.row,
    this.onUpdate,
  });

  final PostgrestMap row;
  final void Function(Map<dynamic, dynamic>)? onUpdate;

  @override
  PostgrestFilterBuilder<PostgrestList> select([String columns = '*']) {
    return _SingleRowFilterBuilder(row);
  }

  @override
  PostgrestFilterBuilder<dynamic> update(Map<dynamic, dynamic> values) {
    return _FakePostgrestFilterBuilder<dynamic>(() async {
      onUpdate?.call(values);
      return null;
    });
  }
}

class _SingleRowFilterBuilder extends Fake
    implements PostgrestFilterBuilder<PostgrestList> {
  _SingleRowFilterBuilder(this.row);

  final PostgrestMap row;

  @override
  PostgrestFilterBuilder<PostgrestList> eq(String column, Object value) => this;

  @override
  PostgrestTransformBuilder<PostgrestMap?> maybeSingle() {
    return _FakePostgrestTransformBuilder<PostgrestMap?>(() async => row);
  }

  @override
  PostgrestTransformBuilder<PostgrestMap> single() {
    return _FakePostgrestTransformBuilder<PostgrestMap>(() async => row);
  }
}
