import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme.dart';
import '../../domain/models.dart';
import '../../shared/widgets.dart';
import '../../state/marketplace_store.dart';
import '../profile/profile_screen.dart';
import '../wallet/checkout_screen.dart';
import '../wallet/onboarding_screen.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.nft});
  final Nft nft;
  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  String tab = 'Overview';
  bool expanded = false;
  @override
  Widget build(BuildContext context) {
    final nft = widget.nft;
    final store = AppScope.of(context);
    final owned = store.collected.contains(nft.id) || nft.isCreated;
    return PageFrame(
      title: 'Details',
      actions: [
        CircleButton(
          icon: Icons.share_outlined,
          label: 'Share NFT',
          onPressed: () => _share(context),
        ),
        PopupMenuButton<String>(
          tooltip: 'More options',
          onSelected: (value) {
            if (value == 'Report') {
              openPage(context, ReportScreen(nft: nft));
            } else {
              message(context, 'Metadata is up to date.');
            }
          },
          itemBuilder: (_) => [
            'Refresh metadata',
            'Report',
          ].map((v) => PopupMenuItem(value: v, child: Text(v))).toList(),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Hero(tag: 'detail-${nft.id}', child: ArtImage(nft)),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: CircleButton(
                    icon: Icons.fullscreen,
                    label: 'Enlarge image',
                    onPressed: () => openPage(
                      context,
                      Scaffold(
                        backgroundColor: Colors.black,
                        appBar: AppBar(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          title: Text(nft.name),
                        ),
                        body: Center(
                          child: InteractiveViewer(
                            minScale: .5,
                            maxScale: 5,
                            child: Hero(
                              tag: 'detail-${nft.id}',
                              child: ArtImage(nft, fit: BoxFit.contain),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Avatar(name: 'degods', size: 30),
              const SizedBox(width: 8),
              Expanded(
                child: Text('@${nft.creator}', style: context.text.bodySmall),
              ),
              FavoriteButton(nft),
            ],
          ),
          const SizedBox(height: 12),
          Text(nft.name, style: context.text.titleMedium),
          const Divider(),
          InkWell(
            onTap: () => openPage(
              context,
              SellerScreen(
                name: owned ? 'Casey Kaspol' : 'DeGods',
                avatar: owned ? 'casey' : 'degods',
              ),
            ),
            child: Row(
              children: [
                Avatar(
                  name: owned ? 'casey' : 'degods',
                  size: 48,
                  verified: true,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Current Owner', style: context.text.bodySmall),
                    const SizedBox(height: 3),
                    Text(
                      owned ? 'Casey Kaspol' : 'DeGods',
                      style: context.text.titleSmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: context.panel,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                _bidPanel('Time Left', const AuctionClock()),
                const SizedBox(height: 10),
                _bidPanel(
                  nft.saleType == 'Open For Bid'
                      ? 'Starting Bid'
                      : 'Current Price',
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${eth(nft.price)} wETH',
                        style: context.text.titleMedium,
                      ),
                      const SizedBox(height: 5),
                      Text('by CaseyKaspol', style: context.text.bodySmall),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  key: const Key('buy-now'),
                  onPressed: owned ? null : () => _checkout(false),
                  child: Text(
                    owned
                        ? 'In Your Collection'
                        : nft.saleType == 'Open For Bid'
                        ? 'Place a Bid'
                        : 'Buy Now',
                  ),
                ),
                if (!owned) ...[
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => _checkout(true),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: coralYellow,
                      side: const BorderSide(color: coralYellow),
                    ),
                    child: const Text('Make an Offer'),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: context.panel,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: ['Overview', 'Offers', 'Listing', 'Activity']
                  .map(
                    (v) => Expanded(
                      child: InkWell(
                        onTap: () => setState(() => tab = v),
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: tab == v ? coralYellow : Colors.transparent,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Text(
                            v,
                            style: TextStyle(
                              fontSize: 12,
                              color: tab == v
                                  ? ink
                                  : context.text.bodySmall!.color,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 24),
          if (tab == 'Overview') ...[
            Text('About Collection', style: context.text.titleMedium),
            const SizedBox(height: 14),
            Text(
              nft.description,
              maxLines: expanded ? null : 3,
              overflow: expanded ? null : TextOverflow.ellipsis,
              style: context.text.bodySmall,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => setState(() => expanded = !expanded),
                child: Text(expanded ? 'Read Less' : 'Read More'),
              ),
            ),
            Text('Details', style: context.text.titleMedium),
            const SizedBox(height: 12),
            _row('Contract Address', '0x524cab2ec6912457…'),
            _row('Token ID', nft.id),
            _row('Token Standard', 'ERC-721'),
            _row('Blockchain', 'ETHEREUM'),
            const SizedBox(height: 20),
            Text('Properties', style: context.text.titleMedium),
            const SizedBox(height: 12),
            ...((nft.properties.isNotEmpty
                    ? nft.properties
                    : const {
                        'BACKGROUND': 'Beige',
                        'BODY': 'Soft geometry',
                        'EDITION': '1 of 1',
                        'COLLECTION': 'Architecture',
                      })
                .entries
                .map(
                  (e) => Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(e.key, style: context.text.bodySmall),
                                Text(
                                  e.value,
                                  style: const TextStyle(
                                    color: coralYellow,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text('1%', style: context.text.bodySmall),
                        ],
                      ),
                      const Divider(),
                    ],
                  ),
                )),
          ] else if (tab == 'Listing') ...[
            _row('Price', '${eth(nft.price)} ETH'),
            _row('From', owned ? 'You' : 'DeGods'),
            _row('Sale type', nft.saleType),
          ] else
            EventList(
              events: store.events
                  .where(
                    (e) =>
                        e.nftId == nft.id &&
                        (tab != 'Offers' || e.title == 'Offer made'),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _bidPanel(String label, Widget child) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: context.colors.surface,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.text.bodySmall),
        const SizedBox(height: 8),
        child,
      ],
    ),
  );
  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Expanded(child: Text(label)),
        Flexible(
          child: Text(
            value,
            style: context.text.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
  Future<void> _checkout(bool offer) async {
    if (await ensureWallet(context) && mounted) {
      openPage(
        context,
        CheckoutScreen(
          nft: widget.nft,
          offer: offer || widget.nft.saleType == 'Open For Bid',
        ),
      );
    }
  }

  void _share(BuildContext context) => showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Share this NFT', style: context.text.titleLarge),
            const SizedBox(height: 10),
            Text(widget.nft.name),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () async {
                await Clipboard.setData(
                  ClipboardData(
                    text:
                        'CoralSea · ${widget.nft.name} · ${eth(widget.nft.price)} ETH · Item ${widget.nft.id}',
                  ),
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  message(context, 'NFT details copied');
                }
              },
              icon: const Icon(Icons.copy, size: 18),
              label: const Text('Copy NFT Details'),
            ),
          ],
        ),
      ),
    ),
  );
}

class AuctionClock extends StatefulWidget {
  const AuctionClock({super.key});
  @override
  State<AuctionClock> createState() => _AuctionClockState();
}

class _AuctionClockState extends State<AuctionClock> {
  late final Timer timer;
  late final DateTime end;
  @override
  void initState() {
    super.initState();
    end = DateTime.now().add(
      const Duration(hours: 19, minutes: 33, seconds: 2),
    );
    timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remaining = end.difference(DateTime.now());
    final seconds = remaining.inSeconds.clamp(0, 999999);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '00 : ${(seconds ~/ 3600).toString().padLeft(2, '0')} : ${(seconds ~/ 60 % 60).toString().padLeft(2, '0')} : ${(seconds % 60).toString().padLeft(2, '0')}',
          style: context.text.titleMedium,
        ),
        const SizedBox(height: 5),
        Text(
          'days     hrs      min      sec',
          style: context.text.bodySmall!.copyWith(fontSize: 10),
        ),
      ],
    );
  }
}

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key, required this.nft});
  final Nft nft;
  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String reason = 'Fake collection or possible scam';
  bool submitted = false;
  @override
  Widget build(BuildContext context) => PageFrame(
    title: 'Report NFT',
    child: submitted
        ? const EmptyState(
            icon: Icons.fact_check_outlined,
            title: 'Report recorded',
            subtitle:
                'Your demo report has been recorded for this session. No report was sent to an external service.',
          )
        : ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Why are you reporting this item?',
                style: context.text.titleLarge,
              ),
              const SizedBox(height: 20),
              RadioGroup<String>(
                groupValue: reason,
                onChanged: (v) => setState(() => reason = v!),
                child: Column(
                  children:
                      [
                            'Fake collection or possible scam',
                            'Explicit or sensitive content',
                            'Stolen artwork',
                            'Other',
                          ]
                          .map(
                            (v) => RadioListTile<String>(
                              value: v,
                              activeColor: coralYellow,
                              title: Text(v),
                            ),
                          )
                          .toList(),
                ),
              ),
              const SizedBox(height: 20),
              const TextField(
                maxLines: 5,
                maxLength: 500,
                decoration: InputDecoration(
                  hintText: 'Tell us more (optional)',
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => setState(() => submitted = true),
                child: const Text('Submit Report'),
              ),
            ],
          ),
  );
}
