import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shams_mobile_app/core/l10n/generated/app_localizations.dart';
import 'package:shams_mobile_app/core/theme/shams_colors.dart';
import 'package:shams_mobile_app/core/theme/shams_theme.dart';
import 'package:shams_mobile_app/features/posts/presentation/widgets/post_card.dart';

Widget _buildTestApp({
  required Widget child,
  ThemeData? theme,
  Locale locale = const Locale('en'),
}) {
  return MaterialApp(
    theme: theme ?? ShamsTheme.light,
    locale: locale,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [
      Locale('ar'),
      Locale('en'),
    ],
    home: Scaffold(
      body: SingleChildScrollView(child: child),
    ),
  );
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('PostCard', () {
    testWidgets('renders header with relative timestamp and share action icon',
        (tester) async {
      var shareTapped = false;

      await tester.pumpWidget(
        _buildTestApp(
          child: PostCard(
            username: 'Solar Expert',
            userHandle: '@solar_pro',
            avatarPath: '',
            content: 'Clean solar panel maintenance tip.',
            timeAgoText: '2h',
            likesCount: 5,
            commentsCount: 2,
            sharesCount: 1,
            isLiked: false,
            onShareTap: () => shareTapped = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Solar Expert'), findsOneWidget);
      expect(find.text('@solar_pro'), findsOneWidget);
      expect(find.text('2h'), findsOneWidget);

      final shareIcon = find.byIcon(Icons.share_outlined);
      expect(shareIcon, findsOneWidget);

      await tester.tap(shareIcon);
      await tester.pumpAndSettle();
      expect(shareTapped, isTrue);
    });

    testWidgets('toggles like state, updates count, and runs bounce animation',
        (tester) async {
      bool? latestLiked;

      await tester.pumpWidget(
        _buildTestApp(
          child: PostCard(
            username: 'Shams User',
            userHandle: '@shams',
            avatarPath: '',
            content: 'Inverter checkup complete.',
            likesCount: 10,
            commentsCount: 3,
            sharesCount: 0,
            isLiked: false,
            onLikeToggle: (liked) => latestLiked = liked,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);
      expect(find.text('10'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.favorite_border_rounded));
      await tester.pump(const Duration(milliseconds: 100));

      expect(latestLiked, isTrue);
      expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
      expect(find.text('11'), findsOneWidget);

      await tester.pumpAndSettle();

      // Rapid tap back to unliked works without exception
      await tester.tap(find.byIcon(Icons.favorite_rounded));
      await tester.pumpAndSettle();

      expect(latestLiked, isFalse);
      expect(find.text('10'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders dark mode border and padded Hero image carousel',
        (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          theme: ShamsTheme.dark,
          child: const PostCard(
            username: 'Tech Team',
            userHandle: '@tech',
            avatarPath: '',
            content: 'Installation showcase',
            imagePaths: ['non_existent_local_image.png'],
            heroTag: 'post-media-hero-1',
            likesCount: 0,
            commentsCount: 0,
            sharesCount: 0,
            isLiked: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final ext = ShamsTheme.dark.extension<ShamsExtendedColors>()!;
      final cardContainer = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(PostCard),
              matching: find.byType(Container),
            )
            .first,
      );
      final decoration = cardContainer.decoration! as BoxDecoration;
      expect(decoration.border, isNotNull);
      expect((decoration.border! as Border).top.color, ext.borderLight);

      final hero = tester.widget<Hero>(find.byType(Hero));
      expect(hero.tag, 'post-media-hero-1');
    });
  });
}

