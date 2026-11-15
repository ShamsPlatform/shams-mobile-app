import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/core/usecase/usecase.dart';
import 'package:shams_mobile_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:shams_mobile_app/features/maintenance/domain/entities/maintenance_request.dart';
import 'package:shams_mobile_app/features/maintenance/domain/repositories/maintenance_repository.dart';

/// Parameters for submitting a maintenance request and starting a workshop chat.
class SubmitMaintenanceRequestParams {
  final String workshopId;
  final String workshopOwnerId;
  final String serviceType;
  final String problemDescription;
  final double? systemCapacityKw;
  final String? inverterBrand;
  final String? batteryType;

  const SubmitMaintenanceRequestParams({
    required this.workshopId,
    required this.workshopOwnerId,
    required this.serviceType,
    required this.problemDescription,
    this.systemCapacityKw,
    this.inverterBrand,
    this.batteryType,
  });
}

/// Orchestrates submitting a solar maintenance request and notifying the workshop
/// in chat (fixes F7 by moving this workflow out of `ChatProvider`):
///
/// 1. Creates the maintenance request record.
/// 2. Finds or creates a 1-to-1 chat linked to the request.
/// 3. Sends the formatted Arabic summary message in that chat.
///
/// If step 2 or 3 fails, returns `Err` without rolling back the already-created
/// request (preserving legacy behavior).
class SubmitMaintenanceRequestUseCase
    implements UseCase<String, SubmitMaintenanceRequestParams> {
  SubmitMaintenanceRequestUseCase(
    this._maintenanceRepository,
    this._chatRepository,
  );

  final MaintenanceRepository _maintenanceRepository;
  final ChatRepository _chatRepository;

  @override
  Future<Result<String>> call(SubmitMaintenanceRequestParams params) async {
    final requestResult = await _maintenanceRepository.createRequest(
      CreateMaintenanceRequestParams(
        workshopId: params.workshopId,
        serviceType: params.serviceType,
        problemDescription: params.problemDescription,
        systemCapacityKw: params.systemCapacityKw,
        inverterBrand: params.inverterBrand,
        batteryType: params.batteryType,
      ),
    );

    final MaintenanceRequest request;
    switch (requestResult) {
      case Ok(:final data):
        request = data;
      case Err(:final failure):
        return Err(failure);
    }

    final chatResult = await _chatRepository.getOrCreateChat(
      otherUserId: params.workshopOwnerId,
      maintenanceRequestId: request.id,
    );

    final String chatId;
    switch (chatResult) {
      case Ok(:final data):
        chatId = data;
      case Err(:final failure):
        return Err(failure);
    }

    final summaryText = _formatSummaryText(params);

    final messageResult = await _chatRepository.sendMessage(
      chatId: chatId,
      text: summaryText,
    );

    return switch (messageResult) {
      Ok() => Ok(chatId),
      Err(:final failure) => Err(failure),
    };
  }

  String _formatSummaryText(SubmitMaintenanceRequestParams params) {
    final capacityLine = params.systemCapacityKw != null
        ? 'قدرة المنظومة: ${params.systemCapacityKw} كيلوواط\n'
        : '';
    final inverterLine =
        params.inverterBrand != null && params.inverterBrand!.isNotEmpty
            ? 'نوع العاكس: ${params.inverterBrand}\n'
            : '';
    final batteryLine =
        params.batteryType != null && params.batteryType!.isNotEmpty
            ? 'نوع البطارية: ${params.batteryType}\n'
            : '';

    return '📋 طلب خدمة جديد:\n'
        'نوع الخدمة: ${params.serviceType}\n'
        '$capacityLine'
        '$inverterLine'
        '$batteryLine'
        'تفاصيل المشكلة: ${params.problemDescription}';
  }
}
