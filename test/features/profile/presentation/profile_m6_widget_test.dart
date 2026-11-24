import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:shams_mobile_app/core/domain/entities/app_user.dart';
import 'package:shams_mobile_app/core/l10n/generated/app_localizations.dart';
import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/core/theme/shams_theme.dart';
import 'package:shams_mobile_app/core/usecase/usecase.dart';
import 'package:shams_mobile_app/features/profile/domain/usecases/get_my_profile_usecase.dart';
import 'package:shams_mobile_app/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:shams_mobile_app/features/profile/presentation/providers/profile_provider.dart';
import 'package:shams_mobile_app/features/profile/presentation/screens/about_shams_screen.dart';
import 'package:shams_mobile_app/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:shams_mobile_app/features/profile/presentation/screens/privacy_security_screen.dart';
import 'package:shams_mobile_app/features/profile/presentation/widgets/profile_bottom_sheets.dart';
import 'package:shams_mobile_app/features/profile/presentation/widgets/profile_header_card.dart';

class _MockGetMyProfileUseCase extends Mock implements GetMyProfileUseCase {}

class _MockUpdateProfileUseCase extends Mock implements UpdateProfileUseCase {}

Widget _buildTestApp({
  required Widget home,
  Locale locale = const Locale('en'),
  ThemeData? theme,
  double textScale = 1.0,
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
    builder: (context, child) {
      return MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale),
        ),
        child: child!,
      );
    },
    home: home,
  );
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    registerFallbackValue(const NoParams());
    registerFallbackValue(
      const UpdateProfileParams(
        name: '',
        username: '',
        phone: '',
        bio: '',
      ),
    );
  });

  group('F29 ProfileHeaderCard', () {
    testWidgets('hides location pin and bio when both are null or empty',
        (tester) async {
      const user = AppUser(
        id: 'u1',
        name: 'Ali',
        email: 'ali@shams.ye',
        bio: '   ',
        location: null,
      );

      await tester.pumpWidget(
        _buildTestApp(
          home: Scaffold(
            body: ProfileHeaderCard(
              currentUser: user,
              onEditProfileTap: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.location_on_rounded), findsNothing);
      expect(find.byIcon(Icons.info_outline_rounded), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders both bio and localized location when present',
        (tester) async {
      const user = AppUser(
        id: 'u1',
        name: 'Ali',
        email: 'ali@shams.ye',
        bio: 'Solar Engineer',
        location: 'صنعاء',
      );

      await tester.pumpWidget(
        _buildTestApp(
          locale: const Locale('en'),
          home: Scaffold(
            body: ProfileHeaderCard(
              currentUser: user,
              onEditProfileTap: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);
      expect(find.text('Solar Engineer'), findsOneWidget);
      expect(find.byIcon(Icons.location_on_rounded), findsOneWidget);
      expect(find.text("Sana'a"), findsOneWidget);
    });
  });

  group('F30 EditProfileScreen', () {
    testWidgets(
        'sanitizes invalid initial location, uses onSecondary camera icon, and saves selected governorate',
        (tester) async {
      final getProfile = _MockGetMyProfileUseCase();
      final updateProfile = _MockUpdateProfileUseCase();
      const initialUser = AppUser(
        id: 'u1',
        name: 'Ali',
        email: 'ali@shams.ye',
        location: 'invalid-legacy-city',
      );
      when(() => getProfile(any())).thenAnswer((_) async => const Ok(initialUser));
      when(() => updateProfile(any())).thenAnswer((_) async => const Ok(initialUser));

      final provider = ProfileProvider(
        getMyProfile: getProfile,
        updateProfile: updateProfile,
      );
      await provider.load();

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: _buildTestApp(home: const EditProfileScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Verify camera icon uses onSecondary
      final cameraIcon = tester.widget<Icon>(
        find.byIcon(Icons.camera_alt_rounded),
      );
      expect(cameraIcon.color, ShamsTheme.light.colorScheme.onSecondary);

      // Select governorate dropdown
      final dropdown = find.byType(DropdownButtonFormField<String>);
      expect(dropdown, findsOneWidget);
      await tester.ensureVisible(dropdown);
      await tester.tap(dropdown);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Aden').last);
      await tester.pumpAndSettle();

      final saveBtn = find.text('Save Changes');
      await tester.ensureVisible(saveBtn);
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      final captured = verify(() => updateProfile(captureAny())).captured.single
          as UpdateProfileParams;
      expect(captured.location, 'عدن');
      expect(tester.takeException(), isNull);
    });
  });

  group('F31 & F32 ProfileBottomSheets', () {
    testWidgets('language sheet renders radio circles instead of checkboxes',
        (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showProfileLanguageSheet(
                  context,
                  initialLanguage: 'ar',
                  onSave: (_) {},
                ),
                child: const Text('Open Lang'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Lang'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
      expect(find.byIcon(Icons.radio_button_unchecked_rounded), findsOneWidget);
      expect(find.byIcon(Icons.check_box), findsNothing);
    });

    testWidgets(
        'support sheet renders interactive tiles with subtitles and chevrons',
        (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showProfileSupportSheet(
                  context,
                  onShowMessage: (_, {isError = false}) {},
                ),
                child: const Text('Open Support'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Support'));
      await tester.pumpAndSettle();

      expect(find.text('+967 776 434 968'), findsNWidgets(2));
      expect(find.text('codyvex1@gmail.com'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_ios_rounded), findsNWidgets(3));
      expect(tester.takeException(), isNull);
    });
  });

  group('F33 PrivacySecurityScreen', () {
    testWidgets('Full Privacy Policy OutlinedButton.icon opens policy sheet',
        (tester) async {
      await tester.pumpWidget(
        _buildTestApp(home: const PrivacySecurityScreen()),
      );
      await tester.pumpAndSettle();

      final openIcon = find.byIcon(Icons.open_in_new_rounded);
      await tester.scrollUntilVisible(
        openIcon,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(openIcon, findsOneWidget);
      await tester.tap(openIcon);
      await tester.pumpAndSettle();

      final closeButton = find.text('Close');
      expect(closeButton, findsOneWidget);
      await tester.ensureVisible(closeButton);
      await tester.pumpAndSettle();
      await tester.tap(closeButton);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('F34 AboutShamsScreen', () {
    for (final width in [320.0, 360.0]) {
      for (final locale in [const Locale('ar'), const Locale('en')]) {
        for (final scale in [1.0, 1.5]) {
          testWidgets(
              'renders without overflow at ${width.toInt()}dp, ${locale.languageCode}, ${scale}x',
              (tester) async {
            tester.view.physicalSize = Size(width, 800);
            tester.view.devicePixelRatio = 1.0;
            addTearDown(() => tester.view.resetPhysicalSize());

            await tester.pumpWidget(
              _buildTestApp(
                locale: locale,
                textScale: scale,
                home: const AboutShamsScreen(),
              ),
            );
            await tester.pumpAndSettle();

            expect(tester.takeException(), isNull);
          });
        }
      }
    }
  });
}
