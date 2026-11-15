import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shams_mobile_app/core/error/exceptions.dart';
import 'package:shams_mobile_app/core/error/failures.dart';
import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:shams_mobile_app/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:shams_mobile_app/features/profile/domain/entities/profile_upsert.dart';

class _MockProfileRemoteDataSource extends Mock
    implements ProfileRemoteDataSource {}

void main() {
  late _MockProfileRemoteDataSource remote;
  late ProfileRepositoryImpl repository;

  const payload = ProfileUpsert(
    id: 'u-1',
    name: 'Ali',
    username: 'ali',
    location: 'صنعاء',
    email: 'ali@example.com',
  );

  setUpAll(() {
    registerFallbackValue(payload);
  });

  setUp(() {
    remote = _MockProfileRemoteDataSource();
    repository = ProfileRepositoryImpl(remote);
  });

  test('uploadAvatar returns Ok with uploaded url', () async {
    when(
      () => remote.uploadAvatar(
        userId: 'u-1',
        localFilePath: '/tmp/pic.png',
      ),
    ).thenAnswer((_) async => 'https://cdn.example.com/u-1.png');

    final result = await repository.uploadAvatar(
      userId: 'u-1',
      localFilePath: '/tmp/pic.png',
    );

    expect(result, const Ok('https://cdn.example.com/u-1.png'));
  });

  test('uploadAvatar maps ServerException to ServerFailure', () async {
    when(
      () => remote.uploadAvatar(
        userId: 'u-1',
        localFilePath: '/tmp/pic.png',
      ),
    ).thenThrow(const ServerException('upload failed'));

    final result = await repository.uploadAvatar(
      userId: 'u-1',
      localFilePath: '/tmp/pic.png',
    );

    expect(result, const Err<String>(ServerFailure('upload failed')));
  });

  test('upsertProfile returns Ok on success and ServerFailure on exception',
      () async {
    when(() => remote.upsertProfile(payload)).thenAnswer((_) async {});
    final ok = await repository.upsertProfile(payload);
    expect(ok, isA<Ok<void>>());

    when(() => remote.upsertProfile(payload))
        .thenThrow(const ServerException('db error'));
    final err = await repository.upsertProfile(payload);
    expect(err, const Err<void>(ServerFailure('db error')));
  });
}
