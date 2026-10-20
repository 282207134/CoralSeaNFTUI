import 'package:flutter/material.dart';
import 'app.dart';
import 'data/local_repository.dart';
import 'state/marketplace_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repository = await LocalRepository.open();
  runApp(CoralSeaApp(store: MarketplaceStore(repository)));
}
