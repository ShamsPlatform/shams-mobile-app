import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shams_mobile_app/core/theme/shams_theme.dart';
import 'package:shams_mobile_app/core/widgets/outlined_button.dart';

Widget _buildTestApp({
  required Widget child,
  ThemeData? theme,
}) {
  return MaterialApp(
    theme: theme ?? ShamsTheme.light,
    home: Scaffold(
      body: Center(child: child),
    ),
  );
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('CustomOutlinedButton', () {
    testWidgets('uses light primary color for foreground and 1.5dp border',
        (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          theme: ShamsTheme.light,
          child: CustomOutlinedButton(
            title: 'تسجيل الدخول',
            onPressed: () {},
          ),
        ),
      );

      final button = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
      final style = button.style!;
      final fg = style.foregroundColor?.resolve({});
      final side = style.side?.resolve({});

      expect(fg, ShamsTheme.light.colorScheme.primary);
      expect(side?.color, ShamsTheme.light.colorScheme.primary);
      expect(side?.width, 1.5);
    });

    testWidgets('uses dark primary color in dark mode', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          theme: ShamsTheme.dark,
          child: CustomOutlinedButton(
            title: 'Sign In',
            onPressed: () {},
          ),
        ),
      );

      final button = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
      final style = button.style!;
      final fg = style.foregroundColor?.resolve({});
      final side = style.side?.resolve({});

      expect(fg, ShamsTheme.dark.colorScheme.primary);
      expect(side?.color, ShamsTheme.dark.colorScheme.primary);
      expect(side?.width, 1.5);
    });

    testWidgets('supports optional icon and triggers onPressed callback',
        (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        _buildTestApp(
          child: CustomOutlinedButton(
            title: 'Open Link',
            icon: const Icon(Icons.open_in_new_rounded),
            onPressed: () => tapped = true,
          ),
        ),
      );

      expect(find.byIcon(Icons.open_in_new_rounded), findsOneWidget);
      expect(find.text('Open Link'), findsOneWidget);

      await tester.tap(find.text('Open Link'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('applies tactile press scale animation on pointer down/up',
        (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          child: CustomOutlinedButton(
            title: 'Press Me',
            onPressed: () {},
          ),
        ),
      );

      AnimatedScale scaleWidget() =>
          tester.widget<AnimatedScale>(find.byType(AnimatedScale));

      expect(scaleWidget().scale, 1.0);

      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Press Me')),
      );
      await tester.pump();
      expect(scaleWidget().scale, 0.96);

      await gesture.up();
      await tester.pumpAndSettle();
      expect(scaleWidget().scale, 1.0);
    });
  });
}

