import 'package:coralsea/main.dart' as app;
import 'package:coralsea/shared/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('CoralSea Android end-to-end flow', (tester) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove('coralsea.marketplace.v1');
    await app.main();
    await tester.pumpAndSettle();
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
    await binding.takeScreenshot('01_onboarding');
    await tap(tester, find.byKey(const Key('get-started')));
    await tap(tester, find.text('🦊  Metamask'));
    expect(find.text('New Drop'), findsOneWidget);
    await binding.takeScreenshot('02_home');
    await tap(tester, find.byType(NftCard).first);
    await binding.takeScreenshot('03_details');
    await tap(tester, find.byKey(const Key('buy-now')));
    await tap(tester, find.byType(Checkbox));
    await tap(tester, find.byKey(const Key('confirm-transaction')));
    expect(find.text('You own something special.'), findsOneWidget);
    await binding.takeScreenshot('04_purchase_success');
    await tap(tester, find.text('Continue Exploring'));
    await tap(tester, find.byTooltip('Back'));
    await tap(tester, find.byKey(const Key('nav-profile')));
    expect(find.text('3D door dash'), findsOneWidget);
    await binding.takeScreenshot('05_profile');
    await tap(tester, find.byTooltip('Settings'));
    await tap(tester, find.byType(Switch));
    await binding.takeScreenshot('06_dark_settings');
    await tap(tester, find.byTooltip('Back'));
    await tap(tester, find.byKey(const Key('nav-home')));
    await binding.takeScreenshot('07_dark_home');
    await tap(tester, find.byKey(const Key('nav-search')));
    await tester.enterText(find.byKey(const Key('search-input')), 'door');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.text('1 results'), findsOneWidget);
    await binding.takeScreenshot('08_search');
    await tap(tester, find.byKey(const Key('create-nft')));
    await tap(tester, find.byKey(const Key('choose-artwork')));
    await tap(tester, find.byKey(const Key('sample-blue')));
    await tester.enterText(find.byKey(const Key('item-name')), 'Ocean Study');
    await tester.scrollUntilVisible(
      find.byKey(const Key('item-price')),
      250,
      scrollable: currentScroll(),
    );
    await tester.enterText(find.byKey(const Key('item-price')), '0.25');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await tap(tester, find.byKey(const Key('submit-item')));
    expect(find.text('Your art is ready.'), findsOneWidget);
    await binding.takeScreenshot('09_create_success');
    expect(tester.takeException(), isNull);
  });
}

Finder currentScroll() => find
    .descendant(
      of: find.byType(ListView).last,
      matching: find.byType(Scrollable),
    )
    .first;
Future<void> tap(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(finder, 300, scrollable: currentScroll());
  }
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}
