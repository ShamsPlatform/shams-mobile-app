import 'package:flutter/foundation.dart';
import 'package:shams_mobile_app/core/presentation/view_status.dart';
import 'package:shams_mobile_app/features/maintenance/domain/usecases/submit_maintenance_request_usecase.dart';

/// Presentation state for submitting a solar maintenance request and opening
/// its linked workshop chat.
class MaintenanceRequestProvider extends ChangeNotifier {
  MaintenanceRequestProvider({
    required SubmitMaintenanceRequestUseCase submitMaintenanceRequest,
  }) : _submitMaintenanceRequest = submitMaintenanceRequest;

  final SubmitMaintenanceRequestUseCase _submitMaintenanceRequest;

  ViewStatus _status = ViewStatus.initial;
  String? _errorMessage;

  ViewStatus get status => _status;
  String? get errorMessage => _errorMessage;

  /// Submits [params] and returns the created/linked `chatId`, or `null` when
  /// submission fails (populating [errorMessage]).
  Future<String?> submit(SubmitMaintenanceRequestParams params) async {
    _status = ViewStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _submitMaintenanceRequest(params);
    return result.fold(
      (failure) {
        _status = ViewStatus.failure;
        _errorMessage = failure.message;
        notifyListeners();
        return null;
      },
      (chatId) {
        _status = ViewStatus.success;
        _errorMessage = null;
        notifyListeners();
        return chatId;
      },
    );
  }
}
