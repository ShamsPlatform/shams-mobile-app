import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shams_mobile_app/core/error/exceptions.dart';
import 'package:shams_mobile_app/features/maintenance/domain/repositories/maintenance_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Remote data source for solar maintenance requests and status notifications.
abstract interface class MaintenanceRemoteDataSource {
  Future<Map<String, dynamic>> createRequest(
    CreateMaintenanceRequestParams params,
  );

  Future<List<Map<String, dynamic>>> fetchMyRequests();

  Future<List<Map<String, dynamic>>> fetchWorkshopRequests(String workshopId);

  Future<void> updateStatus({
    required String requestId,
    required String newStatus,
  });

  Future<void> deleteRequest(String requestId);
}

class MaintenanceRemoteDataSourceImpl implements MaintenanceRemoteDataSource {
  MaintenanceRemoteDataSourceImpl(this._db);

  final SupabaseClient _db;

  String _requireUserId() {
    final user = _db.auth.currentUser;
    if (user == null) {
      throw const AppAuthException('لا يوجد مستخدم مسجل دخول');
    }
    return user.id;
  }

  Future<T> _guardDb<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } on AuthException catch (e) {
      throw AppAuthException(e.message);
    }
  }

  @override
  Future<Map<String, dynamic>> createRequest(
    CreateMaintenanceRequestParams params,
  ) {
    return _guardDb(() async {
      final userId = _requireUserId();

      final request = await _db
          .from('maintenance_requests')
          .insert({
            'workshop_id': params.workshopId,
            'client_id': userId,
            'service_type': params.serviceType,
            'problem_description': params.problemDescription,
            'system_capacity_kw': params.systemCapacityKw,
            'inverter_brand': params.inverterBrand,
            'battery_type': params.batteryType,
            'status': 'pending',
          })
          .select()
          .single();

      unawaited(
        _createMaintenanceNotification(
          requestId: request['id'] as String,
          workshopId: params.workshopId,
          clientId: userId,
          serviceType: params.serviceType,
        ),
      );

      return request;
    });
  }

  Future<void> _createMaintenanceNotification({
    required String requestId,
    required String workshopId,
    required String clientId,
    required String serviceType,
  }) async {
    try {
      final workshop = await _db
          .from('workshops')
          .select('owner_id')
          .eq('id', workshopId)
          .single();
      final ownerId = workshop['owner_id'] as String;

      final clientProfile = await _db
          .from('profiles')
          .select('name')
          .eq('id', clientId)
          .maybeSingle();
      final clientName = clientProfile?['name'] ?? 'عميل شمس';

      await _db.from('notifications').insert({
        'user_id': ownerId,
        'title': 'طلب صيانة جديد',
        'message': 'تلقيت طلب صيانة جديد من $clientName ($serviceType)',
        'type': 'maintenance_status',
        'target_id': requestId,
      });
    } catch (e) {
      debugPrint('Error creating maintenance request notification: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchMyRequests() {
    return _guardDb(() async {
      final userId = _requireUserId();
      return await _db
          .from('maintenance_requests')
          .select('''
            *,
            workshops!maintenance_requests_workshop_id_fkey(id, name, logo_url, city)
          ''')
          .eq('client_id', userId)
          .order('requested_at', ascending: false);
    });
  }

  @override
  Future<List<Map<String, dynamic>>> fetchWorkshopRequests(String workshopId) {
    return _guardDb(() async {
      return await _db
          .from('maintenance_requests')
          .select('''
            *,
            profiles!maintenance_requests_client_id_fkey(id, name, phone, profile_image_url)
          ''')
          .eq('workshop_id', workshopId)
          .order('requested_at', ascending: false);
    });
  }

  @override
  Future<void> updateStatus({
    required String requestId,
    required String newStatus,
  }) {
    return _guardDb(() async {
      await _db.from('maintenance_requests').update({
        'status': newStatus,
      }).eq('id', requestId);

      unawaited(
        _createStatusUpdateNotification(
          requestId: requestId,
          newStatus: newStatus,
        ),
      );
    });
  }

  Future<void> _createStatusUpdateNotification({
    required String requestId,
    required String newStatus,
  }) async {
    try {
      final request = await _db
          .from('maintenance_requests')
          .select('client_id, workshop_id, service_type')
          .eq('id', requestId)
          .single();

      final clientId = request['client_id'] as String;
      final workshopId = request['workshop_id'] as String;
      final serviceType = request['service_type'] as String;

      final workshop = await _db
          .from('workshops')
          .select('name')
          .eq('id', workshopId)
          .single();
      final workshopName = workshop['name'] as String;

      var statusStr = 'قيد الانتظار';
      if (newStatus == 'accepted') statusStr = 'مقبول';
      if (newStatus == 'in_progress') statusStr = 'جارٍ التنفيذ';
      if (newStatus == 'rejected' || newStatus == 'cancelled') {
        statusStr = 'مرفوض';
      }
      if (newStatus == 'completed') statusStr = 'مكتمل';

      await _db.from('notifications').insert({
        'user_id': clientId,
        'title': 'تحديث طلب الصيانة',
        'message':
            'تم تحديث حالة طلب الصيانة ($serviceType) لدى $workshopName إلى: $statusStr',
        'type': 'maintenance_status',
        'target_id': requestId,
      });
    } catch (e) {
      debugPrint('Error creating maintenance status update notification: $e');
    }
  }

  @override
  Future<void> deleteRequest(String requestId) {
    return _guardDb(() async {
      await _db.from('maintenance_requests').delete().eq('id', requestId);
    });
  }
}
