import 'dart:convert';
import 'package:coralsea/data/local_repository.dart';

class FakeRepository implements MarketplaceRepository {
  FakeRepository([Map<String, dynamic> initial = const {}])
    : data = Map.of(initial);
  Map<String, dynamic> data;
  bool fail = false;
  @override
  Map<String, dynamic> load() => data;
  @override
  Future<void> save(Map<String, dynamic> snapshot) async {
    if (fail) throw StateError('Storage unavailable');
    data = jsonDecode(jsonEncode(snapshot)) as Map<String, dynamic>;
  }
}
