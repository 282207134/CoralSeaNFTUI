import 'package:coralsea/app.dart';
import 'package:coralsea/shared/widgets.dart';
import 'package:coralsea/state/marketplace_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support/fake_repository.dart';

Future<MarketplaceStore> launch(
  WidgetTester tester, {
  bool onboarded = true,
  Size size = const Size(375, 812),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final store = MarketplaceStore(
    FakeRepository({
      'onboarded': onboarded,
      'wallet': onboarded ? 'Metamask' : null,
    }),
  );
  addTearDown(store.dispose);
  await tester.pumpWidget(CoralSeaApp(store: store));
  await tester.pumpAndSettle();
  return store;
}

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      finder,
      300,
      scrollable: find
          .descendant(
            of: find.byType(ListView).last,
            matching: find.byType(Scrollable),
          )
          .first,
    );
  }
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('onboarding connects wallet and opens home', (tester) async {
    final store = await launch(tester, onboarded: false);
    await tapVisible(tester, find.byKey(const Key('get-started')));
    await tapVisible(tester, find.text('🦊  Metamask'));
    expect(store.onboarded, isTrue);
    expect(store.wallet, 'Metamask');
    expect(find.text('New Drop'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('search handles results, empty category, and clear', (
    tester,
  ) async {
    await launch(tester);
    await tester.tap(find.byKey(const Key('nav-search')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('search-input')), 'door');
    await tester.pumpAndSettle();
    expect(find.text('1 results'), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('search-input')),
      'nothing-matches',
    );
    await tester.pumpAndSettle();
    expect(find.text('No NFTs found'), findsOneWidget);
    await tester.tap(find.byTooltip('Clear search'));
    await tester.pumpAndSettle();
    expect(find.text('Popular Collection'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('purchase completes and collected state updates', (tester) async {
    final store = await launch(tester);
    await tester.tap(find.byType(NftCard).first);
    await tester.pumpAndSettle();
    await tapVisible(tester, find.byKey(const Key('buy-now')));
    await tapVisible(tester, find.byType(Checkbox));
    await tapVisible(tester, find.byKey(const Key('confirm-transaction')));
    expect(find.text('You own something special.'), findsOneWidget);
    expect(store.collected, contains('door'));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
  testWidgets('create validates required inputs then publishes sample art', (
    tester,
  ) async {
    final store = await launch(tester);
    await tester.tap(find.byKey(const Key('create-nft')));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.byKey(const Key('choose-artwork')));
    await tester.tap(find.byKey(const Key('sample-blue')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('item-name')));
    await tester.enterText(find.byKey(const Key('item-name')), 'My ocean');
    await tester.scrollUntilVisible(
      find.byKey(const Key('item-price')),
      250,
      scrollable: find
          .descendant(
            of: find.byType(ListView).last,
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.enterText(find.byKey(const Key('item-price')), '0.2');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await tapVisible(tester, find.byKey(const Key('submit-item')));
    expect(find.text('Your art is ready.'), findsOneWidget);
    expect(store.created.single.name, 'My ocean');
    expect(tester.takeException(), isNull);
  });
  for (final size in [const Size(320, 640), const Size(600, 900)]) {
    testWidgets('home and theme render without overflow at $size', (
      tester,
    ) async {
      final store = await launch(tester, size: size);
      expect(tester.takeException(), isNull);
      await tester.tap(find.byKey(const Key('nav-profile')));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(store.dark, isTrue);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets(
    'empty create form validates fields after they scroll out of view',
    (tester) async {
      final store = await launch(tester);
      await tester.tap(find.byKey(const Key('create-nft')));
      await tester.pumpAndSettle();
      await tapVisible(tester, find.byKey(const Key('submit-item')));
      expect(store.created, isEmpty);
      expect(find.text('Please enter a name.'), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('offer confirmation records the bid and shows success', (
    tester,
  ) async {
    final store = await launch(tester);
    await tester.tap(find.byType(NftCard).first);
    await tester.pumpAndSettle();
    await tapVisible(tester, find.text('Make an Offer'));
    await tester.enterText(find.byKey(const Key('offer-amount')), '0.03');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await tapVisible(tester, find.byType(Checkbox));
    await tapVisible(tester, find.byKey(const Key('confirm-transaction')));
    expect(find.text('Your offer is in!'), findsOneWidget);
    expect(store.events.single.amount, .03);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
