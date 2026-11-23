import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shams_mobile_app/core/error/exceptions.dart';
import 'package:shams_mobile_app/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class _FakeTransformBuilder<T> extends Fake
    implements PostgrestTransformBuilder<T> {
  _FakeTransformBuilder(this._run);

  final Future<T> Function() _run;

  @override
  Future<R> then<R>(
    FutureOr<R> Function(T value) onValue, {
    Function? onError,
  }) =>
      Future<T>.sync(_run).then(onValue, onError: onError);
}

class _FakeFilterBuilder<T> extends Fake implements PostgrestFilterBuilder<T> {
  _FakeFilterBuilder(this._run, {PostgrestMap? singleRow})
      : _singleRow = singleRow;

  final Future<T> Function() _run;
  final PostgrestMap? _singleRow;

  @override
  PostgrestFilterBuilder<T> eq(String column, Object value) => this;

  @override
  PostgrestFilterBuilder<T> neq(String column, Object value) => this;

  @override
  PostgrestTransformBuilder<PostgrestList> select([String columns = '*']) {
    return _FakeListTransformBuilder(_singleRow);
  }

  @override
  Future<R> then<R>(
    FutureOr<R> Function(T value) onValue, {
    Function? onError,
  }) =>
      Future<T>.sync(_run).then(onValue, onError: onError);
}

class _FakeListTransformBuilder extends Fake
    implements PostgrestTransformBuilder<PostgrestList> {
  _FakeListTransformBuilder(this._singleRow);

  final PostgrestMap? _singleRow;

  @override
  PostgrestTransformBuilder<PostgrestMap> single() {
    return _FakeTransformBuilder<PostgrestMap>(
      () async => _singleRow ?? <String, dynamic>{},
    );
  }
}

class _FakeQueryBuilder extends Fake implements SupabaseQueryBuilder {
  _FakeQueryBuilder({PostgrestMap? insertedRow, PostgrestList? selectedRows})
      : _insertedRow = insertedRow,
        _selectedRows = selectedRows;

  final PostgrestMap? _insertedRow;
  final PostgrestList? _selectedRows;

  @override
  PostgrestFilterBuilder<dynamic> insert(
    Object values, {
    bool defaultToNull = true,
  }) {
    return _FakeFilterBuilder<dynamic>(
      () async => _insertedRow,
      singleRow: _insertedRow,
    );
  }

  @override
  PostgrestFilterBuilder<PostgrestList> select([String columns = '*']) {
    return _FakeFilterBuilder<PostgrestList>(
      () async => _selectedRows ?? const <PostgrestMap>[],
    );
  }
}

void main() {
  test('sendMessage skips client notification when DB triggers handle it',
      () async {
    final db = MockSupabaseClient();
    final auth = MockGoTrueClient();
    const user = User(
      id: 'sender-1',
      appMetadata: {},
      userMetadata: {},
      aud: 'authenticated',
      createdAt: '2026-01-01T00:00:00.000Z',
    );
    when(() => db.auth).thenReturn(auth);
    when(() => auth.currentUser).thenReturn(user);
    when(() => db.from('messages')).thenAnswer(
      (_) => _FakeQueryBuilder(
        insertedRow: {
          'id': 'm1',
          'chat_id': 'c1',
          'sender_id': 'sender-1',
          'text': 'مرحباً',
          'created_at': '2026-11-15T00:00:00.000Z',
        },
      ),
    );

    final dataSource = ChatRemoteDataSourceImpl(
      db,
      useDbNotificationTriggers: true,
    );

    final result = await dataSource.sendMessage(chatId: 'c1', text: 'مرحباً');
    await Future<void>.delayed(Duration.zero);

    expect(result['id'], 'm1');
    verifyNever(() => db.from('chat_participants'));
    verifyNever(() => db.from('notifications'));
  });

  test('sendMessage maps PostgrestException to ServerException', () async {
    final db = MockSupabaseClient();
    final auth = MockGoTrueClient();
    const user = User(
      id: 'sender-1',
      appMetadata: {},
      userMetadata: {},
      aud: 'authenticated',
      createdAt: '2026-01-01T00:00:00.000Z',
    );
    when(() => db.auth).thenReturn(auth);
    when(() => auth.currentUser).thenReturn(user);
    when(() => db.from('messages')).thenThrow(
      const PostgrestException(
        message:
            'new row for relation "notifications" violates check constraint "notifications_type_check"',
        code: '23514',
      ),
    );

    final dataSource = ChatRemoteDataSourceImpl(
      db,
      useDbNotificationTriggers: true,
    );

    await expectLater(
      dataSource.sendMessage(chatId: 'c1', text: 'مرحباً'),
      throwsA(
        isA<ServerException>().having(
          (e) => e.message,
          'message',
          contains('notifications_type_check'),
        ),
      ),
    );
  });
}
