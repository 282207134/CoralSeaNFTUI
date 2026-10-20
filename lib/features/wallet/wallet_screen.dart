import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme.dart';
import '../../domain/models.dart';
import '../../shared/widgets.dart';
import '../../state/marketplace_store.dart';
import '../profile/profile_screen.dart';
import 'onboarding_screen.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    return PageFrame(
      title: 'My Wallet',
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        children: [
          const Center(child: Avatar(size: 82)),
          const SizedBox(height: 18),
          Center(
            child: Text('Casey Kaspol', style: context.text.headlineMedium),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              '${eth(store.balance)} ETH',
              style: context.text.headlineMedium!.copyWith(color: coralYellow),
            ),
          ),
          if (store.wrappedBalance > 0)
            Center(
              child: Text(
                '${eth(store.wrappedBalance)} wETH',
                style: context.text.bodySmall,
              ),
            ),
          Center(
            child: TextButton.icon(
              onPressed: () async {
                await Clipboard.setData(
                  ClipboardData(text: store.walletAddress),
                );
                if (context.mounted) message(context, 'Wallet address copied');
              },
              icon: const Icon(Icons.copy, size: 15),
              iconAlignment: IconAlignment.end,
              label: Text(
                '${store.walletAddress.substring(0, 7)}…${store.walletAddress.substring(36)}',
                style: context.text.bodySmall,
              ),
            ),
          ),
          Center(
            child: Text(
              store.wallet == null
                  ? 'Wallet disconnected'
                  : 'Connected · Demo wallet',
              style: context.text.bodySmall,
            ),
          ),
          const SizedBox(height: 24),
          if (store.wallet == null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: FilledButton(
                onPressed: () => openPage(context, const ConnectWalletScreen()),
                child: const Text('Connect Wallet'),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children:
                    [
                          ('Receive', Icons.south_west),
                          ('Send', Icons.north_east),
                          ('Buy', Icons.add_card),
                          ('Swap', Icons.swap_horiz),
                        ]
                        .map(
                          (a) => Column(
                            children: [
                              IconButton.filled(
                                onPressed: () => a.$1 == 'Receive'
                                    ? _receive(context)
                                    : openPage(
                                        context,
                                        WalletActionScreen(action: a.$1),
                                      ),
                                style: IconButton.styleFrom(
                                  backgroundColor: coralYellow,
                                  foregroundColor: ink,
                                  padding: const EdgeInsets.all(13),
                                ),
                                icon: Icon(a.$2),
                              ),
                              const SizedBox(height: 8),
                              Text(a.$1, style: context.text.bodySmall),
                            ],
                          ),
                        )
                        .toList(),
              ),
            ),
          const SizedBox(height: 30),
          const SectionTitle('Last Activity'),
          const SizedBox(height: 14),
          EventList(events: store.events),
        ],
      ),
    );
  }

  void _receive(BuildContext context) {
    final address = AppScope.of(context).walletAddress;
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.account_balance_wallet_outlined,
                color: coralYellow,
                size: 48,
              ),
              const SizedBox(height: 18),
              Text('Your demo address', style: context.text.titleLarge),
              const SizedBox(height: 14),
              SelectableText(address, textAlign: TextAlign.center),
              const SizedBox(height: 14),
              Text(
                'This address is for demonstration. Do not send real assets to this demo.',
                textAlign: TextAlign.center,
                style: context.text.bodySmall,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: address));
                  if (context.mounted) message(context, 'Address copied');
                },
                child: const Text('Copy Address'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WalletActionScreen extends StatefulWidget {
  const WalletActionScreen({super.key, required this.action});
  final String action;
  @override
  State<WalletActionScreen> createState() => _WalletActionScreenState();
}

class _WalletActionScreenState extends State<WalletActionScreen> {
  final form = GlobalKey<FormState>();
  final amount = TextEditingController(), address = TextEditingController();
  bool busy = false;
  String? error;
  @override
  void dispose() {
    amount.dispose();
    address.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PageFrame(
    title: '${widget.action} · Demo ETH',
    child: Form(
      key: form,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            widget.action == 'Buy'
                ? 'Add demo funds'
                : widget.action == 'Swap'
                ? 'ETH → wETH'
                : 'Send demo ETH',
            style: context.text.headlineMedium,
          ),
          const SizedBox(height: 12),
          Text(
            'Available: ${eth(AppScope.of(context).balance)} ETH',
            style: context.text.bodySmall,
          ),
          const SizedBox(height: 24),
          if (widget.action == 'Send') ...[
            TextFormField(
              controller: address,
              decoration: const InputDecoration(
                labelText: 'Recipient Address',
                hintText: '0x…',
              ),
              validator: (v) =>
                  RegExp(r'^0x[a-fA-F0-9]{40}$').hasMatch(v?.trim() ?? '')
                  ? null
                  : 'Enter a valid Ethereum address.',
            ),
            const SizedBox(height: 16),
          ],
          TextFormField(
            controller: amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Amount',
              suffixText: 'ETH',
            ),
            validator: (v) {
              final n = double.tryParse(v ?? '');
              return n == null || !n.isFinite || n <= 0 || n > 100
                  ? 'Enter an amount greater than 0, up to 100.'
                  : null;
            },
          ),
          const SizedBox(height: 24),
          Text(
            widget.action == 'Buy'
                ? 'This adds simulated ETH to your local wallet. No payment is needed.'
                : widget.action == 'Swap'
                ? 'A local 1:1 conversion. Your demo ETH balance decreases and your demo wETH balance increases.'
                : 'This only updates your local demo balance. The recipient does not receive a real transfer.',
            style: context.text.bodySmall,
          ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Text(
                error!,
                style: TextStyle(color: context.colors.error),
              ),
            ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: busy
                ? null
                : () async {
                    if (!form.currentState!.validate()) return;
                    setState(() {
                      busy = true;
                      error = null;
                    });
                    try {
                      await AppScope.of(context).walletAction(
                        widget.action,
                        double.parse(amount.text),
                        address: address.text.trim(),
                      );
                      if (context.mounted) {
                        Navigator.pop(context);
                        message(context, 'Demo wallet updated');
                      }
                    } on StateError catch (e) {
                      if (mounted) setState(() => error = e.message);
                    } finally {
                      if (mounted) setState(() => busy = false);
                    }
                  },
            child: Text(busy ? 'Updating…' : 'Confirm ${widget.action}'),
          ),
        ],
      ),
    ),
  );
}
