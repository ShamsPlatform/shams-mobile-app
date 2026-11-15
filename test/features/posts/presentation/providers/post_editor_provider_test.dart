import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shams_mobile_app/core/error/failures.dart';
import 'package:shams_mobile_app/core/presentation/view_status.dart';
import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/features/posts/domain/entities/post.dart';
import 'package:shams_mobile_app/features/posts/domain/usecases/create_post_usecase.dart';
import 'package:shams_mobile_app/features/posts/domain/usecases/update_post_usecase.dart';
import 'package:shams_mobile_app/features/posts/presentation/providers/post_editor_provider.dart';

class MockCreatePostUseCase extends Mock implements CreatePostUseCase {}

class MockUpdatePostUseCase extends Mock implements UpdatePostUseCase {}

void main() {
  late MockCreatePostUseCase createPost;
  late MockUpdatePostUseCase updatePost;
  late PostEditorProvider editor;

  final now = DateTime(2026, 11, 15, 4, 0);
  final samplePost = Post(
    id: 'p1',
    workshopId: 'w1',
    textDetails: 'Original',
    images: const ['https://cdn/1.jpg'],
    createdAt: now,
    isHighlighted: false,
  );

  setUpAll(() {
    registerFallbackValue(
      const CreatePostParams(workshopId: '', textDetails: ''),
    );
    registerFallbackValue(const UpdatePostParams(postId: ''));
  });

  setUp(() {
    createPost = MockCreatePostUseCase();
    updatePost = MockUpdatePostUseCase();
    editor = PostEditorProvider(createPost: createPost, updatePost: updatePost);
  });

  test('create returns Post on Ok and sets errorMessage on Err', () async {
    when(() => createPost(any())).thenAnswer((_) async => Ok(samplePost));

    final created = await editor.create(
      workshopId: 'w1',
      textDetails: 'Original',
      imagePaths: const ['/tmp/1.jpg'],
    );

    expect(created, samplePost);
    expect(editor.status, ViewStatus.success);
    expect(editor.errorMessage, isNull);

    when(() => createPost(any()))
        .thenAnswer((_) async => const Err(ServerFailure('upload failed')));

    final failed = await editor.create(
      workshopId: 'w1',
      textDetails: 'Fail',
    );

    expect(failed, isNull);
    expect(editor.status, ViewStatus.failure);
    expect(editor.errorMessage, 'upload failed');
  });

  test('update returns updated Post on Ok and sets errorMessage on Err',
      () async {
    when(() => updatePost(any())).thenAnswer((_) async => const Ok(null));

    final updated = await editor.update(
      original: samplePost,
      textDetails: 'Updated text',
      images: const ['https://cdn/1.jpg', '/tmp/2.jpg'],
      isHighlighted: true,
    );

    expect(updated, isNotNull);
    expect(updated!.textDetails, 'Updated text');
    expect(updated.images, ['https://cdn/1.jpg', '/tmp/2.jpg']);
    expect(updated.isHighlighted, true);
    expect(editor.status, ViewStatus.success);

    when(() => updatePost(any()))
        .thenAnswer((_) async => const Err(ServerFailure('update failed')));

    final failed = await editor.update(
      original: samplePost,
      textDetails: 'Fail',
      isHighlighted: false,
    );

    expect(failed, isNull);
    expect(editor.status, ViewStatus.failure);
    expect(editor.errorMessage, 'update failed');
  });
}
