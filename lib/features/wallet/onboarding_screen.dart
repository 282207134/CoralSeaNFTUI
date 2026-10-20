import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../shared/widgets.dart';
import '../../state/marketplace_store.dart';
import '../profile/settings_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: constraints.maxHeight * .54,
              width: double.infinity,
              child: Image.asset(
                'assets/images/onboarding.png',
                fit: BoxFit.cover,
                alignment: Alignment.bottomCenter,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 42, 20, 28),
              child: Column(
                children: [
                  Text(
                    'Discover Rare Digital Art and Collect NFTs',
                    style: context.text.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Million of the best NFT works you can find here and you can own it',
                    textAlign: TextAlign.center,
                    style: context.text.bodyMedium!.copyWith(
                      color: context.text.bodySmall!.color,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 42),
                  FilledButton(
                    key: const Key('get-started'),
                    onPressed: () async {
                      await openPage(context, const ConnectWalletScreen());
                    },
                    child: const Text('Get Started'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<bool> ensureWallet(BuildContext context) async {
  final store = AppScope.of(context);
  if (store.wallet == null) {
    await openPage(context, const ConnectWalletScreen());
  }
  return store.wallet != null;
}

class ConnectWalletScreen extends StatefulWidget {
  const ConnectWalletScreen({super.key});
  @override
  State<ConnectWalletScreen> createState() => _ConnectWalletScreenState();
}

class _ConnectWalletScreenState extends State<ConnectWalletScreen> {
  final address = TextEditingController();
  String? error;
  bool enteringAddress = false;
  @override
  void dispose() {
    address.dispose();
    super.dispose();
  }

  Future<void> _connect(String provider) async {
    final store = AppScope.of(context);
    await store.connect(provider);
    if (!store.onboarded) await store.finishOnboarding();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: IconButton(
        tooltip: 'Back',
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: Center(
            child: Text(
              'DEMO WALLET',
              style: context.text.bodySmall!.copyWith(
                fontSize: 10,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
      ],
    ),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
        children: [
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/logo.png',
                width: 72,
                height: 72,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Connect With Wallet',
            textAlign: TextAlign.center,
            style: context.text.headlineMedium,
          ),
          const SizedBox(height: 16),
          Text(
            'Your crypto wallet securely stores your digital goods and cryptocurrencies. Connect to one of our wallet providers or create a new one.',
            textAlign: TextAlign.center,
            style: context.text.bodyMedium!.copyWith(
              color: context.text.bodySmall!.color,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Explore with a simulated wallet. No funds or signatures required.',
            textAlign: TextAlign.center,
            style: context.text.bodySmall,
          ),
          const SizedBox(height: 32),
          OutlinedButton(
            onPressed: () => _connect('Metamask'),
            child: const Text('🦊  Metamask'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => _connect('Rainbow'),
            child: const Text('🌈  Rainbow'),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 22),
            child: Text('or', textAlign: TextAlign.center),
          ),
          if (enteringAddress) ...[
            TextField(
              controller: address,
              decoration: InputDecoration(
                hintText: '0x… Ethereum address',
                errorText: error,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () {
                if (!RegExp(
                  r'^0x[a-fA-F0-9]{40}$',
                ).hasMatch(address.text.trim())) {
                  setState(
                    () =>
                        error = 'Enter a valid 42-character Ethereum address.',
                  );
                  return;
                }
                _connect(address.text.trim());
              },
              child: const Text('Connect Address'),
            ),
          ] else
            OutlinedButton(
              onPressed: () => setState(() => enteringAddress = true),
              child: const Text('Enter Ethereum Address'),
            ),
          const SizedBox(height: 14),
          TextButton(
            onPressed: () => openPage(context, const SupportScreen()),
            child: const Text('New to CoralSea and NFT? Read FAQ'),
          ),
          const SizedBox(height: 32),
          TextButton(
            onPressed: () async {
              final store = AppScope.of(context);
              await store.finishOnboarding();
              if (context.mounted) Navigator.pop(context);
            },
            child: Text('Skip For Now', style: context.text.titleSmall),
          ),
        ],
      ),
    ),
  );
}
