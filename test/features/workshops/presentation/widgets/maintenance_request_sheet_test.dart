import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:shams_mobile_app/core/l10n/generated/app_localizations.dart';
import 'package:shams_mobile_app/core/presentation/view_status.dart';
import 'package:shams_mobile_app/core/theme/shams_theme.dart';
import 'package:shams_mobile_app/features/chat/presentation/providers/chat_list_provider.dart';
import 'package:shams_mobile_app/features/maintenance/domain/usecases/submit_maintenance_request_usecase.dart';
import 'package:shams_mobile_app/features/maintenance/presentation/providers/maintenance_request_provider.dart';
import 'package:shams_mobile_app/features/workshops/domain/entities/workshop.dart';
import 'package:shams_mobile_app/features/workshops/presentation/widgets/profile/maintenance_request_sheet.dart';

class _MockMaintenanceRequestProvider extends Mock
    with ChangeNotifier
    implements MaintenanceRequestProvider {}

class _MockChatListProvider extends Mock
    with ChangeNotifier
    implements ChatListProvider {}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    registerFallbackValue(
      const SubmitMaintenanceRequestParams(
        workshopId: '',
        workshopOwnerId: '',
        serviceType: '',
        problemDescription: '',
      ),
    );
  });

  group('showMaintenanceRequestSheet', () {
    const workshop = Workshop(
      id: 'ws-1',
      ownerId: 'owner-1',
      name: 'Shams Solar Workshop',
      handle: '@shams_ws',
      city: "Sana'a",
    );

    testWidgets(
        'displays LoadingAnimationWidget while submitting and transferring, then restores form on failure',
        (tester) async {
      tester.view.physicalSize = const Size(420, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final maintenanceProvider = _MockMaintenanceRequestProvider();
      final chatListProvider = _MockChatListProvider();
      final completer = Completer<String?>();

      when(() => maintenanceProvider.status).thenReturn(ViewStatus.initial);
      when(() => maintenanceProvider.errorMessage)
          .thenReturn('Network unavailable');
      when(() => maintenanceProvider.submit(any()))
          .thenAnswer((_) => completer.future);
      when(() => chatListProvider.load(silent: true)).thenAnswer((_) async {});

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<MaintenanceRequestProvider>.value(
              value: maintenanceProvider,
            ),
            ChangeNotifierProvider<ChatListProvider>.value(
              value: chatListProvider,
            ),
          ],
          child: MaterialApp(
            theme: ShamsTheme.light,
            locale: const Locale('en'),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('ar'), Locale('en')],
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () =>
                      showMaintenanceRequestSheet(context, workshop),
                  child: const Text('Open Sheet'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      // Select service type
      final serviceDropdown = find.byType(DropdownButtonFormField<String>).first;
      await tester.ensureVisible(serviceDropdown);
      await tester.tap(serviceDropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownMenuItem<String>).last);
      await tester.pumpAndSettle();

      // Enter problem description
      await tester.enterText(
        find.byType(TextField).last,
        'Inverter shuts down at noon.',
      );
      await tester.pump();

      // Submit
      final sendButton = find.text('Submit Request');
      await tester.ensureVisible(sendButton);
      await tester.tap(sendButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      // Verify loading_animation_widget is visible during submission & transfer
      expect(
        find.byWidgetPredicate((w) => w is LoadingAnimationWidget || w.runtimeType.toString().contains('DiscreteCircle')),
        findsWidgets,
      );
      expect(
        find.text('Sending request and creating chat...'),
        findsOneWidget,
      );
      expect(find.text('Shams Solar Workshop'), findsOneWidget);

      // Complete with null (failure) to verify form preserves text and shows error
      completer.complete(null);
      await tester.pumpAndSettle();

      expect(find.text('Inverter shuts down at noon.'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}

