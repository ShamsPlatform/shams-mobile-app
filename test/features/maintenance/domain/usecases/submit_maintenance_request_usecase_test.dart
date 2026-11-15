import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shams_mobile_app/core/error/failures.dart';
import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/features/chat/domain/entities/message.dart';
import 'package:shams_mobile_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:shams_mobile_app/features/maintenance/domain/entities/maintenance_request.dart';
import 'package:shams_mobile_app/features/maintenance/domain/repositories/maintenance_repository.dart';
import 'package:shams_mobile_app/features/maintenance/domain/usecases/submit_maintenance_request_usecase.dart';

class MockMaintenanceRepository extends Mock implements MaintenanceRepository {}

class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late MockMaintenanceRepository maintenanceRepo;
  late MockChatRepository chatRepo;
  late SubmitMaintenanceRequestUseCase useCase;

  final requestedAt = DateTime.utc(2026, 11, 15, 10, 0);
  final createdRequest = MaintenanceRequest(
    id: 'req-1',
    workshopId: 'w1',
    clientId: 'u1',
    serviceType: 'صيانة عاكس (Inverter)',
    systemCapacityKw: 5.0,
    inverterBrand: 'Growatt',
    batteryType: 'ليثيوم',
    problemDescription: 'الشحن ضعيف وقت الظهيرة',
    requestedAt: requestedAt,
  );
  final sentMessage = Message(
    id: 'msg-1',
    senderId: 'u1',
    text: 'summary',
    timestamp: requestedAt,
  );

  const fullParams = SubmitMaintenanceRequestParams(
    workshopId: 'w1',
    workshopOwnerId: 'owner-1',
    serviceType: 'صيانة عاكس (Inverter)',
    problemDescription: 'الشحن ضعيف وقت الظهيرة',
    systemCapacityKw: 5.0,
    inverterBrand: 'Growatt',
    batteryType: 'ليثيوم',
  );

  const minimalParams = SubmitMaintenanceRequestParams(
    workshopId: 'w1',
    workshopOwnerId: 'owner-1',
    serviceType: 'تنظيف ألواح',
    problemDescription: 'تنظيف دوري',
  );

  setUpAll(() {
    registerFallbackValue(
      const CreateMaintenanceRequestParams(
        workshopId: 'w',
        serviceType: 's',
        problemDescription: 'p',
      ),
    );
  });

  setUp(() {
    maintenanceRepo = MockMaintenanceRepository();
    chatRepo = MockChatRepository();
    useCase = SubmitMaintenanceRequestUseCase(maintenanceRepo, chatRepo);
  });

  test('executes createRequest -> getOrCreateChat -> sendMessage in order',
      () async {
    when(() => maintenanceRepo.createRequest(any()))
        .thenAnswer((_) async => Ok(createdRequest));
    when(
      () => chatRepo.getOrCreateChat(
        otherUserId: 'owner-1',
        maintenanceRequestId: 'req-1',
      ),
    ).thenAnswer((_) async => const Ok('chat-1'));
    when(
      () => chatRepo.sendMessage(
        chatId: 'chat-1',
        text: any(named: 'text'),
      ),
    ).thenAnswer((_) async => Ok(sentMessage));

    final result = await useCase(fullParams);

    expect(result, const Ok('chat-1'));

    const expectedSummary = '📋 طلب خدمة جديد:\n'
        'نوع الخدمة: صيانة عاكس (Inverter)\n'
        'قدرة المنظومة: 5.0 كيلوواط\n'
        'نوع العاكس: Growatt\n'
        'نوع البطارية: ليثيوم\n'
        'تفاصيل المشكلة: الشحن ضعيف وقت الظهيرة';

    verifyInOrder([
      () => maintenanceRepo.createRequest(
            any(
              that: predicate<CreateMaintenanceRequestParams>(
                (p) =>
                    p.workshopId == 'w1' &&
                    p.serviceType == 'صيانة عاكس (Inverter)' &&
                    p.problemDescription == 'الشحن ضعيف وقت الظهيرة' &&
                    p.systemCapacityKw == 5.0 &&
                    p.inverterBrand == 'Growatt' &&
                    p.batteryType == 'ليثيوم',
              ),
            ),
          ),
      () => chatRepo.getOrCreateChat(
            otherUserId: 'owner-1',
            maintenanceRequestId: 'req-1',
          ),
      () => chatRepo.sendMessage(chatId: 'chat-1', text: expectedSummary),
    ]);
  });

  test('omits optional fields from summary message when null or empty',
      () async {
    when(() => maintenanceRepo.createRequest(any()))
        .thenAnswer((_) async => Ok(createdRequest));
    when(
      () => chatRepo.getOrCreateChat(
        otherUserId: 'owner-1',
        maintenanceRequestId: 'req-1',
      ),
    ).thenAnswer((_) async => const Ok('chat-1'));
    when(
      () => chatRepo.sendMessage(
        chatId: 'chat-1',
        text: any(named: 'text'),
      ),
    ).thenAnswer((_) async => Ok(sentMessage));

    final result = await useCase(minimalParams);

    expect(result, const Ok('chat-1'));
    const expectedMinimalSummary = '📋 طلب خدمة جديد:\n'
        'نوع الخدمة: تنظيف ألواح\n'
        'تفاصيل المشكلة: تنظيف دوري';
    verify(
      () => chatRepo.sendMessage(chatId: 'chat-1', text: expectedMinimalSummary),
    ).called(1);
  });

  test('stops after step 1 failure and does not touch chat repository',
      () async {
    when(() => maintenanceRepo.createRequest(any()))
        .thenAnswer((_) async => const Err(ServerFailure('insert failed')));

    final result = await useCase(fullParams);

    expect(result, const Err<String>(ServerFailure('insert failed')));
    verify(() => maintenanceRepo.createRequest(any())).called(1);
    verifyNoMoreInteractions(chatRepo);
  });

  test('stops after step 2 failure and does not send summary message',
      () async {
    when(() => maintenanceRepo.createRequest(any()))
        .thenAnswer((_) async => Ok(createdRequest));
    when(
      () => chatRepo.getOrCreateChat(
        otherUserId: 'owner-1',
        maintenanceRequestId: 'req-1',
      ),
    ).thenAnswer((_) async => const Err(ServerFailure('rpc failed')));

    final result = await useCase(fullParams);

    expect(result, const Err<String>(ServerFailure('rpc failed')));
    verifyNever(
      () => chatRepo.sendMessage(
        chatId: any(named: 'chatId'),
        text: any(named: 'text'),
      ),
    );
  });

  test('propagates Err when step 3 sendMessage fails', () async {
    when(() => maintenanceRepo.createRequest(any()))
        .thenAnswer((_) async => Ok(createdRequest));
    when(
      () => chatRepo.getOrCreateChat(
        otherUserId: 'owner-1',
        maintenanceRequestId: 'req-1',
      ),
    ).thenAnswer((_) async => const Ok('chat-1'));
    when(
      () => chatRepo.sendMessage(
        chatId: 'chat-1',
        text: any(named: 'text'),
      ),
    ).thenAnswer((_) async => const Err(NetworkFailure()));

    final result = await useCase(fullParams);

    expect(result, const Err<String>(NetworkFailure()));
  });
}
