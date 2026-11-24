import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shams_mobile_app/core/theme/shams_theme.dart';
import 'package:shams_mobile_app/core/widgets/shams_shimmer.dart';
import 'package:shams_mobile_app/features/posts/presentation/widgets/post_card_skeleton.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('PostFeedSkeletonList & PostCardSkeleton', () {
    testWidgets('renders 3 skeleton cards in light theme without overflow',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ShamsTheme.light,
          home: const Scaffold(
            body: SingleChildScrollView(
              child: PostFeedSkeletonList(),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(PostCardSkeleton), findsNWidgets(3));
      expect(find.byType(ShamsShimmer), findsNWidgets(3));
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders cleanly in dark theme and compact viewport',
        (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          theme: ShamsTheme.dark,
          home: const Scaffold(
            body: SingleChildScrollView(
              child: PostFeedSkeletonList(),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(PostCardSkeleton), findsNWidgets(3));
      expect(tester.takeException(), isNull);
    });
  });
}

