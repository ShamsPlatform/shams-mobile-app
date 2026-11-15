import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shams_mobile_app/features/maintenance/data/datasources/maintenance_remote_data_source.dart';
import 'package:shams_mobile_app/features/maintenance/domain/repositories/maintenance_repository.dart';
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

class _FakeFilterBuilder<T> extends Fake implements PostgrestFilterBuilder<T> {
  _FakeFilterBuilder(this._run, {PostgrestMap? singleRow})
      : _singleRow = singleRow;

  final Future<T> Function() _run;
  final PostgrestMap? _singleRow;

  @override
  PostgrestFilterBuilder<T> eq(String column, Object value) => this;

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

class _FakeQueryBuilder extends Fake implements SupabaseQueryBuilder {
  _FakeQueryBuilder({PostgrestMap? singleRow}) : _singleRow = singleRow;

  final PostgrestMap? _singleRow;

  @override
  PostgrestFilterBuilder<dynamic> insert(
    Object values, {
    bool defaultToNull = true,
  }) {
    return _FakeFilterBuilder<dynamic>(
      () async => _singleRow,
      singleRow: _singleRow,
    );
  }

  @override
  PostgrestFilterBuilder<dynamic> update(Map<dynamic, dynamic> values) {
    return _FakeFilterBuilder<dynamic>(() async => null);
  }
}

void main() {
  test(
      'createRequest and updateStatus skip client notifications when DB triggers handle them',
      () async {
    final db = MockSupabaseClient();
    final auth = MockGoTrueClient();
    const user = User(
      id: 'client-1',
      appMetadata: {},
      userMetadata: {},
      aud: 'authenticated',
      createdAt: '2026-01-01T00:00:00.000Z',
    );
    when(() => db.auth).thenReturn(auth);
    when(() => auth.currentUser).thenReturn(user);

    var requestCalls = 0;
    when(() => db.from('maintenance_requests')).thenAnswer((_) {
      requestCalls++;
      return _FakeQueryBuilder(
        singleRow: {
          'id': 'req-1',
          'workshop_id': 'w1',
          'client_id': 'client-1',
          'service_type': 'صيانة',
          'status': 'pending',
        },
      );
    });

    final dataSource = MaintenanceRemoteDataSourceImpl(
      db,
      useDbNotificationTriggers: true,
    );

    final created = await dataSource.createRequest(
      const CreateMaintenanceRequestParams(
        workshopId: 'w1',
        serviceType: 'صيانة',
        problemDescription: 'فحص البطارية',
      ),
    );
    await dataSource.updateStatus(requestId: 'req-1', newStatus: 'in_progress');
    await Future<void>.delayed(Duration.zero);

    expect(created['id'], 'req-1');
    expect(requestCalls, 2);
    verifyNever(() => db.from('workshops'));
    verifyNever(() => db.from('notifications'));
  });
}
