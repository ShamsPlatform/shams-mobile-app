import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shams_mobile_app/core/error/exceptions.dart';
import 'package:shams_mobile_app/core/error/failures.dart';
import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/features/maintenance/data/datasources/maintenance_remote_data_source.dart';
import 'package:shams_mobile_app/features/maintenance/data/repositories/maintenance_repository_impl.dart';
import 'package:shams_mobile_app/features/maintenance/domain/entities/maintenance_request.dart';
import 'package:shams_mobile_app/features/maintenance/domain/repositories/maintenance_repository.dart';

class MockMaintenanceRemoteDataSource extends Mock
    implements MaintenanceRemoteDataSource {}

void main() {
  late MockMaintenanceRemoteDataSource remote;
  late MaintenanceRepositoryImpl repository;

  const createParams = CreateMaintenanceRequestParams(
    workshopId: 'w1',
    serviceType: 'تنظيف ألواح',
    problemDescription: 'تراكم الغبار',
  );

  final requestRow = {
    'id': 'req-1',
    'workshop_id': 'w1',
    'client_id': 'u1',
    'service_type': 'تنظيف ألواح',
    'problem_description': 'تراكم الغبار',
    'requested_at': '2026-11-15T10:00:00.000Z',
    'status': 'pending',
  };

  setUpAll(() {
    registerFallbackValue(createParams);
  });

  setUp(() {
    remote = MockMaintenanceRemoteDataSource();
    repository = MaintenanceRepositoryImpl(remote);
  });

  test('createRequest maps created row and wraps exceptions cleanly', () async {
    when(() => remote.createRequest(createParams))
        .thenAnswer((_) async => requestRow);

    final okResult = await repository.createRequest(createParams);
    expect(okResult, isA<Ok<MaintenanceRequest>>());
    expect((okResult as Ok<MaintenanceRequest>).data.id, 'req-1');

    when(() => remote.createRequest(createParams))
        .thenThrow(const AppAuthException('signed out'));
    final errResult = await repository.createRequest(createParams);
    expect(errResult, const Err<MaintenanceRequest>(AuthFailure('signed out')));
  });

  test('read, updateStatus, and deleteRequest map rows and statuses',
      () async {
    when(() => remote.fetchMyRequests()).thenAnswer((_) async => [requestRow]);
    when(() => remote.fetchWorkshopRequests('w1'))
        .thenAnswer((_) async => [requestRow]);
    when(
      () => remote.updateStatus(
        requestId: 'req-1',
        newStatus: 'in_progress',
      ),
    ).thenAnswer((_) async {});
    when(() => remote.deleteRequest('req-1'))
        .thenThrow(const ServerException('delete error'));

    expect((await repository.getMyRequests() as Ok).data, hasLength(1));
    expect(
      (await repository.getWorkshopRequests('w1') as Ok).data,
      hasLength(1),
    );
    expect(
      await repository.updateStatus(
        requestId: 'req-1',
        newStatus: MaintenanceRequestStatus.inProgress,
      ),
      isA<Ok<void>>(),
    );
    expect(
      await repository.deleteRequest('req-1'),
      const Err<void>(ServerFailure('delete error')),
    );
  });
}
