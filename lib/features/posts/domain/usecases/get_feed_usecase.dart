import 'package:shams_mobile_app/core/error/failures.dart';
import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/core/usecase/usecase.dart';
import 'package:shams_mobile_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:shams_mobile_app/features/posts/domain/entities/post.dart';
import 'package:shams_mobile_app/features/posts/domain/repositories/post_repository.dart';

class GetFeedParams {
  const GetFeedParams({this.limit = 20, this.offset = 0});

  final int limit;
  final int offset;
}

/// Fetches the signed-in user's home feed with like flags and comments merged.
class GetFeedUseCase implements UseCase<List<Post>, GetFeedParams> {
  GetFeedUseCase(this._authRepository, this._postRepository);

  final AuthRepository _authRepository;
  final PostRepository _postRepository;

  @override
  Future<Result<List<Post>>> call(GetFeedParams params) async {
    final user = _authRepository.currentUser;
    if (user == null) {
      return const Err(AuthFailure('لا يوجد مستخدم مسجل دخول'));
    }

    return _postRepository.fetchFeed(
      currentUserId: user.id,
      limit: params.limit,
      offset: params.offset,
    );
  }
}
