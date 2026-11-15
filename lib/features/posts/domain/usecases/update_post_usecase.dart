import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/core/usecase/usecase.dart';
import 'package:shams_mobile_app/features/posts/domain/repositories/post_repository.dart';

class UpdatePostParams {
  const UpdatePostParams({
    required this.postId,
    this.textDetails,
    this.isHighlighted,
  });

  final String postId;
  final String? textDetails;
  final bool? isHighlighted;
}

/// Updates text or highlight status of an existing post.
class UpdatePostUseCase implements UseCase<void, UpdatePostParams> {
  UpdatePostUseCase(this._postRepository);

  final PostRepository _postRepository;

  @override
  Future<Result<void>> call(UpdatePostParams params) {
    return _postRepository.updatePost(
      postId: params.postId,
      textDetails: params.textDetails,
      isHighlighted: params.isHighlighted,
    );
  }
}
