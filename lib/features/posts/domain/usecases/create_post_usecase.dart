import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/core/usecase/usecase.dart';
import 'package:shams_mobile_app/features/posts/domain/entities/post.dart';
import 'package:shams_mobile_app/features/posts/domain/repositories/post_repository.dart';

class CreatePostParams {
  const CreatePostParams({
    required this.workshopId,
    required this.textDetails,
    this.imagePaths = const [],
    this.isHighlighted = false,
  });

  final String workshopId;
  final String textDetails;
  final List<String> imagePaths;
  final bool isHighlighted;
}

/// Creates a new workshop post and uploads attached local media paths.
class CreatePostUseCase implements UseCase<Post, CreatePostParams> {
  CreatePostUseCase(this._postRepository);

  final PostRepository _postRepository;

  @override
  Future<Result<Post>> call(CreatePostParams params) {
    return _postRepository.createPost(
      workshopId: params.workshopId,
      textDetails: params.textDetails,
      imagePaths: params.imagePaths,
      isHighlighted: params.isHighlighted,
    );
  }
}
