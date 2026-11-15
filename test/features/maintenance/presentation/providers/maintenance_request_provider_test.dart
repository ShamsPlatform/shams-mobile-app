import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shams_mobile_app/core/error/failures.dart';
import 'package:shams_mobile_app/core/presentation/view_status.dart';
import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/features/maintenance/domain/usecases/submit_maintenance_request_usecase.dart';
import 'package:shams_mobile_app/features/maintenance/presentation/providers/maintenance_request_provider.dart';

class MockSubmitMaintenanceRequestUseCase extends Mock
    implements SubmitMaintenanceRequestUseCase {}

void main() {
  late MockSubmitMaintenanceRequestUseCase submitUseCase;
  late MaintenanceRequestProvider provider;

  const params = SubmitMaintenanceRequestParams(
    workshopId: 'w1',
    workshopOwnerId: 'owner-1',
    serviceType: 'صيانة',
    problemDescription: 'مشكلة شحن',
  );

  setUpAll(() {
    registerFallbackValue(params);
  });

  setUp(() {
    submitUseCase = MockSubmitMaintenanceRequestUseCase();
    provider = MaintenanceRequestProvider(
      submitMaintenanceRequest: submitUseCase,
    );
  });

  tearDown(() {
    provider.dispose();
  });

  test('submit returns chatId and transitions to ViewStatus.success on Ok',
      () async {
    when(() => submitUseCase(any()))
        .thenAnswer((_) async => const Ok('chat-1'));

    final statuses = <ViewStatus>[];
    provider.addListener(() => statuses.add(provider.status));

    final chatId = await provider.submit(params);

    expect(chatId, 'chat-1');
    expect(statuses, [ViewStatus.loading, ViewStatus.success]);
    expect(provider.errorMessage, isNull);
  });

  test('submit returns null and stores errorMessage on Err', () async {
    when(() => submitUseCase(any()))
        .thenAnswer((_) async => const Err(ServerFailure('submit failed')));

    final chatId = await provider.submit(params);

    expect(chatId, isNull);
    expect(provider.status, ViewStatus.failure);
    expect(provider.errorMessage, 'submit failed');
  });
}
