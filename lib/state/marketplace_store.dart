import 'package:flutter/material.dart';
import '../data/local_repository.dart';
import '../domain/models.dart';

class MarketplaceStore extends ChangeNotifier {
  MarketplaceStore(this._repository) {
    final data = _repository.load();
    try {
      onboarded = data['onboarded'] == true;
      wallet = data['wallet'] as String?;
      dark = data['dark'] == true;
      balance = (data['balance'] as num? ?? 9.876667).toDouble();
      wrappedBalance = (data['wrappedBalance'] as num? ?? 0).toDouble();
      favorites.addAll(List<String>.from(data['favorites'] as List? ?? []));
      collected.addAll(List<String>.from(data['collected'] as List? ?? []));
      created.addAll(
        (data['created'] as List? ?? []).map(
          (e) => Nft.fromJson(Map<String, dynamic>.from(e as Map)),
        ),
      );
      events.addAll(
        (data['events'] as List? ?? []).map(
          (e) => MarketEvent.fromJson(Map<String, dynamic>.from(e as Map)),
        ),
      );
      notifications = data['notifications'] != false;
    } catch (_) {
      created.clear();
      events.clear();
    }
  }
  final MarketplaceRepository _repository;
  bool onboarded = false, dark = false, notifications = true;
  String? wallet, storageError;
  double balance = 9.876667;
  double wrappedBalance = 0;
  String get walletAddress =>
      RegExp(r'^0x[a-fA-F0-9]{40}$').hasMatch(wallet ?? '')
      ? wallet!
      : '0x92437a654badc76554ac111643a4e810f27cd4f0';
  final favorites = <String>{}, collected = <String>{};
  final created = <Nft>[];
  final events = <MarketEvent>[];
  Future<void> _saveQueue = Future.value();
  bool _disposed = false;
  List<Nft> get catalog => [...created, ...seedNfts];
  Nft nft(String id) =>
      catalog.firstWhere((n) => n.id == id, orElse: () => seedNfts.first);
  List<Nft> search(String query, String category) => catalog
      .where(
        (n) =>
            (category == 'Trending' || n.category == category) &&
            '${n.name} ${n.creator} ${n.collection}'.toLowerCase().contains(
              query.trim().toLowerCase(),
            ),
      )
      .toList();

  Future<void> _commit() {
    final snapshot = <String, dynamic>{
      'onboarded': onboarded,
      'wallet': wallet,
      'dark': dark,
      'balance': balance,
      'wrappedBalance': wrappedBalance,
      'notifications': notifications,
      'favorites': favorites.toList(),
      'collected': collected.toList(),
      'created': created.map((e) => e.toJson()).toList(),
      'events': events.map((e) => e.toJson()).toList(),
    };
    notifyListeners();
    _saveQueue = _saveQueue
        .then((_) => _repository.save(snapshot))
        .then((_) {
          if (storageError != null && !_disposed) {
            storageError = null;
            notifyListeners();
          }
        })
        .catchError((Object error) {
          if (!_disposed) {
            storageError =
                'Changes could not be saved on this device. Try again.';
            notifyListeners();
          }
        });
    return _saveQueue;
  }

  Future<void> retrySave() => _commit();
  Future<void> finishOnboarding() {
    onboarded = true;
    return _commit();
  }

  Future<void> connect(String provider) {
    wallet = provider;
    return _commit();
  }

  Future<void> disconnect() {
    wallet = null;
    return _commit();
  }

  Future<void> setDark(bool value) {
    dark = value;
    return _commit();
  }

  Future<void> setNotifications(bool value) {
    notifications = value;
    return _commit();
  }

  Future<void> toggleFavorite(String id) {
    if (!favorites.remove(id)) favorites.add(id);
    return _commit();
  }

  void _requireWallet() {
    if (wallet == null) throw StateError('Connect a demo wallet to continue.');
  }

  Future<void> purchase(Nft item) {
    _requireWallet();
    if (collected.contains(item.id) || item.isCreated) {
      throw StateError('This item is already in your collection.');
    }
    if (item.saleType != 'Fixed Price') {
      throw StateError('This item is open for bids. Make an offer instead.');
    }
    if (balance < item.price) throw StateError('Insufficient demo balance.');
    balance = double.parse((balance - item.price).toStringAsFixed(6));
    collected.add(item.id);
    events.insert(
      0,
      MarketEvent(
        nftId: item.id,
        title: 'Purchased',
        amount: item.price,
        time: DateTime.now(),
      ),
    );
    return _commit();
  }

  Future<void> makeOffer(Nft item, double amount, DateTime expiresAt) {
    _requireWallet();
    if (!amount.isFinite || amount <= 0 || amount > balance) {
      throw StateError('Enter a bid within your available balance.');
    }
    if (!expiresAt.isAfter(DateTime.now())) {
      throw StateError('Choose a future expiration date.');
    }
    if (item.isCreated || collected.contains(item.id)) {
      throw StateError('You already own this item.');
    }
    events.insert(
      0,
      MarketEvent(
        nftId: item.id,
        title: 'Offer made',
        amount: amount,
        time: DateTime.now(),
        expiresAt: expiresAt,
      ),
    );
    return _commit();
  }

  Future<void> create(Nft item) {
    _requireWallet();
    if (item.name.trim().isEmpty ||
        !item.price.isFinite ||
        item.price <= 0 ||
        !item.royalties.isFinite ||
        item.royalties < 0 ||
        item.royalties > 50) {
      throw StateError('Check the item name, price and royalties.');
    }
    created.insert(0, item);
    events.insert(
      0,
      MarketEvent(
        nftId: item.id,
        title: 'Created',
        amount: item.price,
        time: DateTime.now(),
      ),
    );
    return _commit();
  }

  Future<void> walletAction(
    String action,
    double amount, {
    String address = '',
  }) {
    _requireWallet();
    if (!amount.isFinite || amount <= 0 || amount > 100) {
      throw StateError('Enter an amount between 0 and 100 ETH.');
    }
    if (action == 'Send' && !RegExp(r'^0x[a-fA-F0-9]{40}$').hasMatch(address)) {
      throw StateError('Enter a valid Ethereum address.');
    }
    if (action != 'Buy' && amount > balance) {
      throw StateError('Insufficient demo balance.');
    }
    if (action == 'Buy') {
      balance += amount;
    } else if (action == 'Send') {
      balance -= amount;
    } else if (action == 'Swap') {
      balance -= amount;
      wrappedBalance += amount;
    } else {
      throw StateError('Unknown wallet action.');
    }
    balance = double.parse(balance.toStringAsFixed(6));
    wrappedBalance = double.parse(wrappedBalance.toStringAsFixed(6));
    events.insert(
      0,
      MarketEvent(
        nftId: 'wallet',
        title: action == 'Buy'
            ? 'Demo ETH added'
            : action == 'Swap'
            ? 'Wrapped ETH'
            : 'Demo ETH sent',
        amount: amount,
        time: DateTime.now(),
      ),
    );
    return _commit();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

class AppScope extends InheritedNotifier<MarketplaceStore> {
  const AppScope({
    super.key,
    required MarketplaceStore store,
    required super.child,
  }) : super(notifier: store);
  static MarketplaceStore of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
