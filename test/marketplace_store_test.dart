import 'package:coralsea/domain/models.dart';
import 'package:coralsea/state/marketplace_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support/fake_repository.dart';

void main() {
  late FakeRepository repository;
  late MarketplaceStore store;
  setUp(() {
    repository = FakeRepository();
    store = MarketplaceStore(repository);
  });
  tearDown(() => store.dispose());

  test('purchase requires connection and cannot charge twice', () async {
    expect(() => store.purchase(seedNfts.first), throwsStateError);
    await store.connect('Metamask');
    final before = store.balance;
    await store.purchase(seedNfts.first);
    expect(store.balance, closeTo(before - .05, .000001));
    expect(store.collected, contains('door'));
    expect(() => store.purchase(seedNfts.first), throwsStateError);
    expect(store.events, hasLength(1));
  });
  test('insufficient balance leaves collection and history intact', () async {
    final poor = MarketplaceStore(
      FakeRepository({'wallet': 'Rainbow', 'balance': .01}),
    );
    expect(() => poor.purchase(seedNfts.first), throwsStateError);
    expect(poor.collected, isEmpty);
    expect(poor.events, isEmpty);
    expect(poor.balance, .01);
    poor.dispose();
  });
  test(
    'offers validate amounts and expiry without debiting demo funds',
    () async {
      await store.connect('Rainbow');
      final future = DateTime.now().add(const Duration(days: 7));
      for (final amount in [double.nan, double.infinity, -1.0, 0.0, 100.0]) {
        expect(
          () => store.makeOffer(seedNfts.first, amount, future),
          throwsStateError,
        );
      }
      expect(
        () => store.makeOffer(seedNfts.first, .1, DateTime(2000)),
        throwsStateError,
      );
      final before = store.balance;
      await store.makeOffer(seedNfts.first, .1, future);
      expect(store.balance, before);
      expect(store.events.single.expiresAt, future);
      expect(store.events.single.title, 'Offer made');
    },
  );
  test(
    'created item metadata, favorites and preferences survive a new store',
    () async {
      await store.connect('Metamask');
      const nft = Nft(
        id: 'my-art',
        name: 'My artwork',
        image: 'art_blue',
        price: .3,
        isCreated: true,
        royalties: 5,
        properties: {'Color': 'Blue'},
        altText: 'Blue painting',
      );
      await store.create(nft);
      await store.toggleFavorite(nft.id);
      await store.setDark(true);
      await store.finishOnboarding();
      final restored = MarketplaceStore(repository);
      expect(restored.dark, isTrue);
      expect(restored.onboarded, isTrue);
      expect(restored.favorites, contains('my-art'));
      expect(restored.created.single.properties, {'Color': 'Blue'});
      expect(restored.created.single.royalties, 5);
      expect(
        () => restored.purchase(restored.created.single),
        throwsStateError,
      );
      restored.dispose();
    },
  );
  test('search combines case-insensitive text and category filters', () {
    expect(store.search('DOOR', 'Trending').single.id, 'door');
    expect(store.search('door', 'Art'), isEmpty);
    expect(store.search('  casey  ', 'Art'), hasLength(2));
    expect(store.search('', 'Domain Name'), isEmpty);
  });
  test('serialized writes preserve final state during rapid toggles', () async {
    final first = store.toggleFavorite('door');
    final second = store.toggleFavorite('blue');
    final third = store.toggleFavorite('door');
    await Future.wait([first, second, third]);
    expect(repository.data['favorites'], ['blue']);
  });
  test(
    'storage failure is visible and retry preserves session state',
    () async {
      repository.fail = true;
      await store.toggleFavorite('door');
      expect(store.storageError, isNotNull);
      expect(store.favorites, contains('door'));
      repository.fail = false;
      await store.retrySave();
      expect(store.storageError, isNull);
      expect(repository.data['favorites'], ['door']);
    },
  );
  test(
    'wallet swap conserves combined funds and invalid send is atomic',
    () async {
      await store.connect('Metamask');
      final total = store.balance;
      await store.walletAction('Swap', .5);
      expect(store.balance + store.wrappedBalance, closeTo(total, .000001));
      expect(store.wrappedBalance, .5);
      expect(
        () => store.walletAction('Send', .1, address: 'invalid'),
        throwsStateError,
      );
      expect(store.events, hasLength(1));
      await store.walletAction('Buy', 1);
      expect(store.balance + store.wrappedBalance, closeTo(total + 1, .000001));
    },
  );
}
