import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../domain/models.dart';
import '../../shared/widgets.dart';
import '../../state/marketplace_store.dart';
import '../profile/profile_screen.dart';
import 'detail_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});
  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String category = 'Trending', sort = 'Trending';
  @override
  Widget build(BuildContext context) {
    final items = AppScope.of(context).search('', category);
    if (sort == 'Price: low to high') {
      items.sort((a, b) => a.price.compareTo(b.price));
    }
    if (sort == 'Price: high to low') {
      items.sort((a, b) => b.price.compareTo(a.price));
    }
    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
          child: Row(
            children: [
              Expanded(
                child: Text('All Categories', style: context.text.titleMedium),
              ),
              PopupMenuButton<String>(
                tooltip: 'Sort NFTs',
                initialValue: sort,
                icon: const Icon(Icons.tune, size: 22),
                onSelected: (value) => setState(() => sort = value),
                itemBuilder: (_) => [
                  'Trending',
                  'Price: low to high',
                  'Price: high to low',
                ].map((v) => PopupMenuItem(value: v, child: Text(v))).toList(),
              ),
            ],
          ),
        ),
        CategoryTabs(
          selected: category,
          onChanged: (v) => setState(() => category = v),
        ),
        const SizedBox(height: 12),
        if (items.isEmpty)
          const EmptyState(
            title: 'Nothing here yet',
            subtitle: 'Try another category. New art is always on the horizon.',
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

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final controller = TextEditingController();
  String category = 'Trending';
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = AppScope.of(context).search(controller.text, category);
    final searching =
        controller.text.trim().isNotEmpty || category != 'Trending';
    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
          child: TextField(
            key: const Key('search-input'),
            controller: controller,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Find NFTs',
              prefixIcon: const Icon(Icons.search, size: 22),
              suffixIcon: controller.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => setState(controller.clear),
                    ),
            ),
          ),
        ),
        const SectionTitle('All Categories'),
        CategoryTabs(
          selected: category,
          onChanged: (v) => setState(() => category = v),
        ),
        const SizedBox(height: 14),
        SectionTitle(
          searching ? '${items.length} results' : 'Popular Collection',
        ),
        const SizedBox(height: 18),
        if (items.isEmpty)
          const EmptyState(
            title: 'No NFTs found',
            subtitle: 'Try a different name, creator or category.',
          )
        else if (searching)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: NftGrid(
              items,
              onTap: (nft) => openPage(context, DetailScreen(nft: nft)),
            ),
          )
        else
          ...List.generate(
            3,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 28),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    leading: Avatar(
                      name: i == 0 ? 'crypto' : 'casey',
                      size: 44,
                      verified: true,
                    ),
                    title: Text(
                      i == 0
                          ? 'QQI Mint Pass'
                          : i == 1
                          ? 'Casey Kaspol'
                          : 'Tamara',
                      style: context.text.titleSmall,
                    ),
                    subtitle: Text(
                      'Volume 967.3 ETH  −10.9%',
                      style: context.text.bodySmall,
                    ),
                    onTap: () => openPage(
                      context,
                      SellerScreen(
                        name: i == 0 ? 'QQI Mint Pass' : 'Casey Kaspol',
                        avatar: i == 0 ? 'crypto' : 'casey',
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 120,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: 4,
                      separatorBuilder: (_, _) => const SizedBox(width: 10),
                      itemBuilder: (_, j) {
                        final nft = items[(i + j) % items.length];
                        return InkWell(
                          onTap: () =>
                              openPage(context, DetailScreen(nft: nft)),
                          child: SizedBox(
                            width: 120,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  ArtImage(nft),
                                  Positioned(
                                    bottom: 5,
                                    left: 5,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 9,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: coralYellow,
                                        borderRadius: BorderRadius.circular(9),
                                      ),
                                      child: Text(
                                        '${eth(nft.price)} ETH',
                                        style: const TextStyle(
                                          color: ink,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
