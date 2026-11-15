import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/core/usecase/usecase.dart';
import 'package:shams_mobile_app/features/posts/domain/entities/post.dart';
import 'package:shams_mobile_app/features/posts/domain/repositories/post_repository.dart';

class GetWorkshopPostsParams {
  const GetWorkshopPostsParams({
    required this.workshopId,
    this.limit = 20,
    this.offset = 0,
  });

  final String workshopId;
  final int limit;
  final int offset;
}

/// Fetches posts belonging to a specific workshop.
class GetWorkshopPostsUseCase
    implements UseCase<List<Post>, GetWorkshopPostsParams> {
  GetWorkshopPostsUseCase(this._postRepository);

  final PostRepository _postRepository;

  @override
  Future<Result<List<Post>>> call(GetWorkshopPostsParams params) {
    return _postRepository.fetchWorkshopPosts(
      workshopId: params.workshopId,
      limit: params.limit,
      offset: params.offset,
    );
  }
}
