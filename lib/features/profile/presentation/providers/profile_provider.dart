import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shams_mobile_app/core/domain/entities/app_user.dart';
import 'package:shams_mobile_app/core/presentation/resettable.dart';
import 'package:shams_mobile_app/core/presentation/view_status.dart';
import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/core/usecase/usecase.dart';
import 'package:shams_mobile_app/features/profile/domain/usecases/get_my_profile_usecase.dart';
import 'package:shams_mobile_app/features/profile/domain/usecases/update_profile_usecase.dart';

/// State manager for the signed-in user's profile.
class ProfileProvider extends ChangeNotifier implements Resettable {
  ProfileProvider({
    required GetMyProfileUseCase getMyProfile,
    required UpdateProfileUseCase updateProfile,
  })  : _getMyProfile = getMyProfile,
        _updateProfile = updateProfile;

  static const AppUser _placeholderUser = AppUser(
    id: '',
    name: 'جاري التحميل...',
    email: '',
  );

  final GetMyProfileUseCase _getMyProfile;
  final UpdateProfileUseCase _updateProfile;

  AppUser? _currentUser;
  ViewStatus _status = ViewStatus.initial;
  String? _errorMessage;

  AppUser? get currentUser => _currentUser;
  AppUser get currentUserOrPlaceholder => _currentUser ?? _placeholderUser;
  ViewStatus get status => _status;
  bool get isLoading => _status == ViewStatus.loading;
  String? get errorMessage => _errorMessage;

  void _evictImage(String? path) {
    if (path == null || path.isEmpty) return;
    try {
      if (path.startsWith('http')) {
        NetworkImage(path).evict();
      } else if (!path.startsWith('assets/')) {
        FileImage(File(path)).evict();
      }
    } catch (e) {
      debugPrint('Error evicting image: $e');
    }
  }

  Future<void> load() async {
    _status = ViewStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _getMyProfile(const NoParams());
    switch (result) {
      case Ok(:final data):
        if (_currentUser?.profileImageUrl != data.profileImageUrl) {
          _evictImage(_currentUser?.profileImageUrl);
        }
        _currentUser = data;
        _status = ViewStatus.success;
      case Err(:final failure):
        _status = ViewStatus.failure;
        _errorMessage = failure.message;
    }
    notifyListeners();
  }

  Future<bool> updateProfile(UpdateProfileParams params) async {
    _status = ViewStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _updateProfile(params);
    switch (result) {
      case Ok(:final data):
        if (_currentUser?.profileImageUrl != data.profileImageUrl) {
          _evictImage(_currentUser?.profileImageUrl);
        }
        _currentUser = data;
        _status = ViewStatus.success;
        notifyListeners();
        return true;
      case Err(:final failure):
        _status = ViewStatus.failure;
        _errorMessage = failure.message;
        notifyListeners();
        return false;
    }
  }

  void updateWorkshopStatus(bool hasWorkshop) {
    final user = _currentUser;
    if (user != null && user.id.isNotEmpty) {
      _currentUser = user.copyWith(hasWorkshop: hasWorkshop);
      notifyListeners();
    }
  }

  @override
  void reset() {
    _evictImage(_currentUser?.profileImageUrl);
    _currentUser = null;
    _status = ViewStatus.initial;
    _errorMessage = null;
    notifyListeners();
  }
}
