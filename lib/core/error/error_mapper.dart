import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shams_mobile_app/core/error/exceptions.dart';
import 'package:shams_mobile_app/core/error/failures.dart';
import 'package:shams_mobile_app/core/result/result.dart';

/// Executes [body] in a repository and translates data-source exceptions
/// into domain [Failure]s wrapped in [Err].
Future<Result<T>> guard<T>(Future<T> Function() body) async {
  try {
    return Ok(await body());
  } on AppAuthException catch (e) {
    return Err(AuthFailure(e.message));
  } on NotFoundException catch (e) {
    return Err(NotFoundFailure(e.message));
  } on ServerException catch (e) {
    return Err(ServerFailure(e.message));
  } on CacheException catch (e) {
    return Err(CacheFailure(e.message));
  } on SocketException {
    return const Err(NetworkFailure());
  } catch (e, s) {
    debugPrintStack(label: e.toString(), stackTrace: s);
    return const Err(UnknownFailure());
  }
}
