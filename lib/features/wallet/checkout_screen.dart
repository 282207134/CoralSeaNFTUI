import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../domain/models.dart';
import '../../shared/widgets.dart';
import '../../state/marketplace_store.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key, required this.nft, this.offer = false});
  final Nft nft;
  final bool offer;
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final form = GlobalKey<FormState>();
  final amount = TextEditingController();
  int days = 7;
  bool agreed = false, busy = false, success = false;
  String? error;
  @override
  void initState() {
    super.initState();
    amount.text = eth(widget.nft.price);
  }

  @override
  void dispose() {
    amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final nft = widget.nft;
    if (success) {
      return PageFrame(
        title: 'All Done',
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: coralYellow.withValues(alpha: .15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: coralYellow,
                      size: 64,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    widget.offer
                        ? 'Your offer is in!'
                        : 'You own something special.',
                    style: context.text.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    widget.offer
                        ? 'Your offer on ${nft.name} has been recorded. You can find it in your profile.'
                        : '${nft.name} has been added to your collection.',
                    textAlign: TextAlign.center,
                    style: context.text.bodySmall,
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: 180,
                    height: 180,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: ArtImage(nft),
                    ),
                  ),
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Continue Exploring'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return PageFrame(
      title: widget.offer ? 'Make an Offer' : 'Buy NFT',
      child: Form(
        key: form,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                SizedBox(
                  width: 88,
                  height: 88,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: ArtImage(nft),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(nft.name, style: context.text.titleMedium),
                      const SizedBox(height: 6),
                      Text('@${nft.creator}', style: context.text.bodySmall),
                      const SizedBox(height: 6),
                      Text(
                        '${eth(nft.price)} wETH',
                        style: context.text.titleSmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 40),
            Text(
              widget.offer ? 'Your Bid' : 'Payment Details',
              style: context.text.titleMedium,
            ),
            const SizedBox(height: 16),
            if (widget.offer) ...[
              TextFormField(
                key: const Key('offer-amount'),
                controller: amount,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  suffixText: 'wETH',
                  hintText: 'Enter your bid',
                ),
                validator: (v) {
                  final value = double.tryParse(v ?? '');
                  return value == null ||
                          !value.isFinite ||
                          value <= 0 ||
                          value > store.balance
                      ? 'Enter an amount within your balance.'
                      : null;
                },
              ),
              const SizedBox(height: 24),
              Text('Bid Expiration', style: context.text.titleSmall),
              const SizedBox(height: 10),
              DropdownButtonFormField<int>(
                initialValue: days,
                items: [1, 3, 7, 30]
                    .map(
                      (d) => DropdownMenuItem(
                        value: d,
                        child: Text('$d ${d == 1 ? 'day' : 'days'}'),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => days = v!),
              ),
              const SizedBox(height: 24),
            ],
            _row('Your Balance', '${eth(store.balance)} ETH'),
            _row('Item Price', '${eth(nft.price)} ETH'),
            _row('Network Fee', '0 ETH · Demo'),
            const Divider(),
            _row(
              'Total',
              widget.offer ? 'Your bid amount' : '${eth(nft.price)} ETH',
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.panel,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.offer
                    ? 'This is a local demo offer. No funds are locked or transferred. Offers appear in Profile → Offers Made.'
                    : 'This is a simulated purchase using your demo balance. No blockchain transaction will be sent.',
                style: context.text.bodySmall,
              ),
            ),
            const SizedBox(height: 20),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: coralYellow,
              checkColor: ink,
              value: agreed,
              onChanged: busy ? null : (v) => setState(() => agreed = v!),
              title: const Text(
                'I understand this is a demo transaction.',
                style: TextStyle(fontSize: 12),
              ),
            ),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Text(
                  error!,
                  style: TextStyle(color: context.colors.error),
                ),
              ),
            const SizedBox(height: 14),
            FilledButton(
              key: const Key('confirm-transaction'),
              onPressed: !agreed || busy ? null : _submit,
              child: busy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(widget.offer ? 'Confirm Offer' : 'Confirm Purchase'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      children: [
        Expanded(child: Text(label, style: context.text.bodySmall)),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
  Future<void> _submit() async {
    if (!form.currentState!.validate()) return;
    final bid = double.tryParse(amount.text);
    if (widget.offer && (bid == null || !bid.isFinite || bid <= 0)) {
      setState(() => error = 'Enter a valid positive bid amount.');
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final store = AppScope.of(context);
      if (widget.offer) {
        await store.makeOffer(
          widget.nft,
          bid!,
          DateTime.now().add(Duration(days: days)),
        );
      } else {
        await store.purchase(widget.nft);
      }
      if (mounted) setState(() => success = true);
    } on StateError catch (e) {
      if (mounted) setState(() => error = e.message);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }
}
