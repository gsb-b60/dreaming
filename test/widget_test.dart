import 'package:dreaming/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> pumpApp(
  WidgetTester tester, {
  String? storage,
  Size size = const Size(1024, 900),
}) async {
  await tester.binding.setSurfaceSize(size);
  SharedPreferences.setMockInitialValues({
    if (storage != null) 'dreaming.localDreams.v1': storage,
  });
  final preferences = await SharedPreferences.getInstance();
  await tester.pumpWidget(DreamingApp(preferences: preferences));
  await tester.pumpAndSettle();
}

void main() {
  tearDown(() async {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    await binding.setSurfaceSize(null);
  });

  testWidgets('shows first-launch empty state and heatmap', (tester) async {
    await pumpApp(tester);

    expect(find.text('Dreaming'), findsOneWidget);
    expect(find.text('Dream history'), findsOneWidget);

    await tester.drag(find.byType(ListView).first, const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(find.text('No dreams recorded yet.'), findsOneWidget);
  });

  testWidgets('renders a mobile month heatmap and opens bottom-sheet preview', (
    tester,
  ) async {
    await pumpApp(tester, size: const Size(390, 844));

    final currentYear = DateTime.now().year;
    expect(find.text('January $currentYear'), findsOneWidget);

    final cell = find.bySemanticsLabel(
      RegExp('January 1, $currentYear.*0 dreams recorded'),
    );
    await tester.tap(cell);
    await tester.pumpAndSettle();

    expect(find.textContaining('0 dreams'), findsWidgets);
    expect(find.text('View all'), findsOneWidget);
    expect(find.text('Add dream'), findsWidgets);
  });

  testWidgets('opens desktop day preview from full-year heatmap cell', (
    tester,
  ) async {
    await pumpApp(tester, size: const Size(1024, 900));

    final currentYear = DateTime.now().year;
    final cell = find.bySemanticsLabel(
      RegExp('January 1, $currentYear.*0 dreams recorded'),
    );
    await tester.tap(cell);
    await tester.pumpAndSettle();

    expect(find.textContaining('0 dreams'), findsWidgets);
    expect(find.text('View all'), findsOneWidget);
    expect(find.text('Add dream'), findsWidgets);
  });

  testWidgets('creates a dream through the editor and updates search', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.text('Add Dream'));
    await tester.pumpAndSettle();
    expect(find.text('Record a dream'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Title'),
      'Ocean flight',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Dream'),
      'I flew over the ocean.',
    );
    await tester.tap(find.text('😌 Peaceful'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('No dreams recorded yet.'), findsNothing);
    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Search title, dream text, tags, mood'),
      'ocean',
    );
    await tester.pumpAndSettle();

    expect(find.text('Ocean flight'), findsOneWidget);
    expect(find.textContaining('Matched'), findsWidgets);
  });

  testWidgets('search no-results empty state appears', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Search title, dream text, tags, mood'),
      'missing',
    );
    await tester.pumpAndSettle();

    expect(find.text('No dreams found.'), findsOneWidget);
  });

  testWidgets('settings exposes disabled export actions when empty', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Export JSON'), findsOneWidget);
    expect(find.text('Export CSV'), findsOneWidget);
    expect(find.textContaining('No account'), findsOneWidget);
  });
}
