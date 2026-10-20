import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../domain/models.dart';
import '../../shared/widgets.dart';
import '../../state/marketplace_store.dart';
import '../profile/settings_screen.dart';
import '../profile/profile_screen.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onExplore});
  final VoidCallback onExplore;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String category = 'Trending';
  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final items = store.search('', category);
    return ListView(
      key: const PageStorageKey('home'),
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
          child: Row(
            children: [
              Image.asset('assets/images/logo.png', width: 44, height: 44),
              const SizedBox(width: 10),
              Text('CoralSea.', style: context.text.titleSmall),
              const Spacer(),
              Badge(
                label: Text(
                  '${store.events.isEmpty ? 2 : store.events.length}',
                ),
                offset: const Offset(-6, 6),
                child: CircleButton(
                  icon: Icons.notifications_rounded,
                  label: 'Notifications',
                  onPressed: () =>
                      openPage(context, const NotificationsScreen()),
                ),
              ),
            ],
          ),
        ),
        CategoryTabs(
          selected: category,
          onChanged: (v) => setState(() => category = v),
        ),
        SectionTitle('New Drop', onSeeAll: widget.onExplore),
        const SizedBox(height: 12),
        if (items.isEmpty)
          const EmptyState(
            title: 'New drops are coming',
            subtitle: 'Explore another category to find your next favorite.',
          )
        else
          SizedBox(
            height: 248 + 138 * MediaQuery.textScalerOf(context).scale(1),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(width: 16),
              itemBuilder: (_, i) => SizedBox(
                width: 248,
                child: NftCard(
                  items[i],
                  featured: true,
                  onTap: () => openPage(context, DetailScreen(nft: items[i])),
                ),
              ),
            ),
          ),
        const SizedBox(height: 18),
        SectionTitle(
          'Top Sellers',
          onSeeAll: () => openPage(context, const SellersScreen()),
        ),
        const SizedBox(height: 12),
        const SellersRow(),
        const SizedBox(height: 20),
        SectionTitle('Popular Collection', onSeeAll: widget.onExplore),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: NftGrid(
            category == 'Trending' ? seedNfts.skip(2).toList() : items,
            onTap: (nft) => openPage(context, DetailScreen(nft: nft)),
          ),
        ),
      ],
    );
  }
}

const sellers = [
  ('DeGods', 'degods', '+518.1%'),
  ('Azuka', 'azuka', '-34.3%'),
  ('CryptoPunk', 'crypto', '+128.8%'),
];

class SellersRow extends StatelessWidget {
  const SellersRow({super.key});
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 56,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: sellers.length,
      separatorBuilder: (_, _) => const SizedBox(width: 20),
      itemBuilder: (_, i) {
        final (name, avatar, change) = sellers[i];
        return InkWell(
          onTap: () =>
              openPage(context, SellerScreen(name: name, avatar: avatar)),
          child: Row(
            children: [
              Avatar(name: avatar, size: 48, verified: true),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(name, style: context.text.titleSmall),
                  const SizedBox(height: 3),
                  Text(
                    change,
                    style: TextStyle(
                      fontSize: 12,
                      color: change.startsWith('+')
                          ? const Color(0xFF16C784)
                          : const Color(0xFFFA4148),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    ),
  );
}

class SellersScreen extends StatelessWidget {
  const SellersScreen({super.key});
  @override
  Widget build(BuildContext context) => PageFrame(
    title: 'Top Sellers',
    child: ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: sellers.length,
      separatorBuilder: (_, _) => const Divider(),
      itemBuilder: (_, i) {
        final (name, avatar, change) = sellers[i];
        return ListTile(
          leading: Avatar(name: avatar, size: 48, verified: true),
          title: Text(name, style: context.text.titleSmall),
          subtitle: Text('Volume 967.3 ETH · $change'),
          trailing: Text('#${i + 1}', style: context.text.titleMedium),
          onTap: () =>
              openPage(context, SellerScreen(name: name, avatar: avatar)),
        );
      },
    ),
  );
}
