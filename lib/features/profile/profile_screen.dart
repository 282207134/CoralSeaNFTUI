import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme.dart';
import '../../domain/models.dart';
import '../../shared/widgets.dart';
import '../../state/marketplace_store.dart';
import '../marketplace/detail_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String tab = 'Collected';
  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final items = switch (tab) {
      'Created' => store.created,
      'Favorited' =>
        store.catalog.where((n) => store.favorites.contains(n.id)).toList(),
      _ => store.catalog.where((n) => store.collected.contains(n.id)).toList(),
    };
    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        const ProfileHeader(),
        CategoryTabs(
          selected: tab,
          items: const [
            'Collected',
            'Created',
            'Favorited',
            'Activity',
            'Offers Made',
          ],
          onChanged: (v) => setState(() => tab = v),
        ),
        const SizedBox(height: 16),
        if (tab == 'Activity' || tab == 'Offers Made')
          EventList(
            events: store.events
                .where((e) => tab != 'Offers Made' || e.title == 'Offer made')
                .toList(),
          )
        else if (items.isEmpty)
          EmptyState(
            icon: tab == 'Favorited'
                ? Icons.favorite_border
                : Icons.collections_outlined,
            title: tab == 'Collected'
                ? 'Your collection starts here'
                : tab == 'Created'
                ? 'Make something extraordinary'
                : 'Keep what inspires you',
            subtitle: tab == 'Collected'
                ? 'Purchase your first NFT and it will appear here.'
                : tab == 'Created'
                ? 'Tap the + button to create your first item.'
                : 'Tap the heart on any artwork to save it here.',
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: NftGrid(
              items,
              onTap: (nft) => openPage(context, DetailScreen(nft: nft)),
            ),
          ),
      ],
    );
  }
}

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    this.name = 'Casey Kaspol',
    this.avatar = 'casey',
    this.seller = false,
  });
  final String name, avatar;
  final bool seller;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      SizedBox(
        height: 214,
        child: Stack(
          children: [
            SizedBox(
              width: double.infinity,
              height: 172,
              child: Image.asset(
                'assets/images/profile_cover.png',
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              right: 16,
              top: 14,
              child: CircleButton(
                icon: seller ? Icons.arrow_back : Icons.settings_outlined,
                label: seller ? 'Back' : 'Settings',
                onPressed: () => seller
                    ? Navigator.pop(context)
                    : openPage(context, const SettingsScreen()),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    shape: BoxShape.circle,
                  ),
                  child: Avatar(name: avatar, size: 82),
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              name,
              style: context.text.headlineMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 10),
          const Icon(Icons.verified, color: Color(0xFF269BFF), size: 22),
        ],
      ),
      const SizedBox(height: 4),
      TextButton.icon(
        onPressed: () async {
          await Clipboard.setData(
            ClipboardData(text: AppScope.of(context).walletAddress),
          );
          if (context.mounted) message(context, 'Wallet address copied');
        },
        icon: Icon(
          Icons.copy_rounded,
          size: 15,
          color: context.text.bodySmall!.color,
        ),
        iconAlignment: IconAlignment.end,
        label: Text(
          '${AppScope.of(context).walletAddress.substring(0, 7)}…${AppScope.of(context).walletAddress.substring(36)}',
          style: context.text.bodySmall,
        ),
      ),
      const SizedBox(height: 12),
    ],
  );
}

class SellerScreen extends StatefulWidget {
  const SellerScreen({super.key, required this.name, required this.avatar});
  final String name, avatar;
  @override
  State<SellerScreen> createState() => _SellerScreenState();
}

class _SellerScreenState extends State<SellerScreen> {
  String tab = 'Collected';
  bool following = false;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: ListView(
        children: [
          ProfileHeader(name: widget.name, avatar: widget.avatar, seller: true),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    '128 items  ·  2.4k followers',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                SizedBox(
                  width: 110,
                  child: FilledButton(
                    onPressed: () => setState(() => following = !following),
                    child: Text(following ? 'Following' : 'Follow'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          CategoryTabs(
            selected: tab,
            items: const ['Collected', 'Created', 'Activity'],
            onChanged: (v) => setState(() => tab = v),
          ),
          const SizedBox(height: 16),
          if (tab == 'Activity')
            const EmptyState(
              title: 'No recent activity',
              subtitle: 'New activity from this creator will appear here.',
            )
          else
            Padding(
              padding: const EdgeInsets.all(20),
              child: NftGrid(
                tab == 'Created' ? seedNfts.skip(2).toList() : seedNfts,
                onTap: (nft) => openPage(context, DetailScreen(nft: nft)),
              ),
            ),
        ],
      ),
    ),
  );
}

class EventList extends StatelessWidget {
  const EventList({super.key, required this.events});
  final List<MarketEvent> events;
  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    if (events.isEmpty) {
      return const EmptyState(
        icon: Icons.history,
        title: 'No activity yet',
        subtitle: 'Your purchases, offers and creations will appear here.',
      );
    }
    return Column(
      children: events.map((event) {
        final nft = store.nft(event.nftId);
        final walletEvent = event.nftId == 'wallet';
        final date = event.time.toLocal();
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 8,
          ),
          leading: SizedBox(
            width: 60,
            height: 60,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: walletEvent
                  ? Icon(
                      Icons.account_balance_wallet_outlined,
                      color: coralYellow,
                      size: 38,
                    )
                  : ArtImage(nft),
            ),
          ),
          title: Text(
            walletEvent ? event.title : nft.name,
            style: context.text.titleSmall,
          ),
          subtitle: Text(
            '${event.title} for ${eth(event.amount)} ETH\n${date.month}/${date.day} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}${event.expiresAt == null ? '' : '\nExpires ${event.expiresAt!.toLocal().month}/${event.expiresAt!.toLocal().day}'}',
            style: context.text.bodySmall,
          ),
          isThreeLine: true,
          trailing: walletEvent
              ? null
              : const Icon(Icons.chevron_right, size: 18),
          onTap: walletEvent
              ? null
              : () => openPage(context, DetailScreen(nft: nft)),
        );
      }).toList(),
    );
  }
}
