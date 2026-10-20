import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../domain/models.dart';
import '../state/marketplace_store.dart';

Future<T?> openPage<T>(BuildContext context, Widget page) =>
    Navigator.of(context).push<T>(MaterialPageRoute(builder: (_) => page));
void message(BuildContext context, String text) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

class PageFrame extends StatelessWidget {
  const PageFrame({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.bottom,
  });
  final String title;
  final Widget child;
  final List<Widget>? actions;
  final Widget? bottom;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(title),
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: CircleButton(
          icon: Icons.arrow_back,
          label: 'Back',
          onPressed: () => Navigator.pop(context),
        ),
      ),
      actions: actions,
    ),
    body: SafeArea(top: false, child: child),
    bottomNavigationBar: bottom,
  );
}

class CircleButton extends StatelessWidget {
  const CircleButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.color,
  });
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final Color? color;
  @override
  Widget build(BuildContext context) => IconButton.filledTonal(
    tooltip: label,
    onPressed: onPressed,
    icon: Icon(icon, size: 22),
    style: IconButton.styleFrom(
      backgroundColor: context.panel.withValues(alpha: .65),
      foregroundColor: color ?? context.colors.onSurface,
    ),
  );
}

class ArtImage extends StatelessWidget {
  const ArtImage(this.nft, {super.key, this.fit = BoxFit.cover});
  final Nft nft;
  final BoxFit fit;
  @override
  Widget build(BuildContext context) => Semantics(
    label: nft.altText.isEmpty ? nft.name : nft.altText,
    image: true,
    child: nft.imageBase64 == null
        ? Image.asset('assets/images/${nft.image}.png', fit: fit)
        : Image.memory(nft.imageBytes!, fit: fit, gaplessPlayback: true),
  );
}

class Avatar extends StatelessWidget {
  const Avatar({
    super.key,
    this.name = 'casey',
    this.size = 32,
    this.verified = false,
  });
  final String name;
  final double size;
  final bool verified;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        ClipOval(
          child: Image.asset(
            'assets/images/avatar_$name.png',
            width: size,
            height: size,
          ),
        ),
        if (verified)
          Positioned(
            right: -2,
            bottom: 0,
            child: Icon(
              Icons.verified,
              color: const Color(0xFF269BFF),
              size: size * .31,
            ),
          ),
      ],
    ),
  );
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.onSeeAll});
  final String title;
  final VoidCallback? onSeeAll;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Row(
      children: [
        Expanded(child: Text(title, style: context.text.titleMedium)),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            child: const Text('See All', style: TextStyle(color: coralYellow)),
          ),
      ],
    ),
  );
}

class CategoryTabs extends StatelessWidget {
  const CategoryTabs({
    super.key,
    required this.selected,
    required this.onChanged,
    this.items = categories,
  });
  final String selected;
  final ValueChanged<String> onChanged;
  final List<String> items;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 54,
    child: ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      scrollDirection: Axis.horizontal,
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(width: 18),
      itemBuilder: (_, i) => Semantics(
        selected: selected == items[i],
        child: InkWell(
          onTap: () => onChanged(items[i]),
          child: Center(
            child: Container(
              padding: const EdgeInsets.only(bottom: 5),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: selected == items[i]
                        ? coralYellow
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                items[i],
                style: TextStyle(
                  fontSize: 14,
                  color: selected == items[i]
                      ? coralYellow
                      : context.text.bodySmall!.color,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class FavoriteButton extends StatelessWidget {
  const FavoriteButton(this.nft, {super.key, this.compact = false});
  final Nft nft;
  final bool compact;
  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final liked = store.favorites.contains(nft.id);
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => store.toggleFavorite(nft.id),
      child: Semantics(
        button: true,
        label: '${liked ? 'Unfavorite' : 'Favorite'} ${nft.name}',
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                liked ? Icons.favorite : Icons.favorite_border,
                size: compact ? 18 : 22,
                color: liked
                    ? const Color(0xFFFA4148)
                    : context.text.bodySmall!.color,
              ),
              const SizedBox(width: 5),
              Text(
                '${nft.likes + (liked ? 1 : 0)}',
                style: context.text.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NftCard extends StatelessWidget {
  const NftCard(
    this.nft, {
    super.key,
    required this.onTap,
    this.featured = false,
  });
  final Nft nft;
  final VoidCallback onTap;
  final bool featured;
  @override
  Widget build(BuildContext context) => Material(
    color: context.panel,
    borderRadius: BorderRadius.circular(18),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: ArtImage(nft),
                  ),
                  if (featured)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F2937),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Text(
                          '19:33:02 Left',
                          style: TextStyle(color: Colors.white, fontSize: 11),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Avatar(name: 'degods', size: 22),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    '@${nft.creator}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodySmall!.copyWith(fontSize: 10),
                  ),
                ),
                if (featured) FavoriteButton(nft, compact: true),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              nft.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.titleSmall!.copyWith(fontSize: 14),
            ),
            if (featured) ...[
              const Divider(height: 20),
              Row(
                children: [
                  Text('Time Auction', style: context.text.bodySmall),
                  const Spacer(),
                  const Text('1 of 1', style: TextStyle(fontSize: 12)),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Text('Top Bid', style: context.text.bodySmall),
                  const Spacer(),
                  Text(
                    '${eth(nft.price)} wETH',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ] else
              Row(
                children: [
                  const Icon(Icons.diamond_outlined, size: 15),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text(
                      eth(nft.price),
                      style: context.text.bodySmall!.copyWith(fontSize: 10),
                    ),
                  ),
                  FavoriteButton(nft, compact: true),
                ],
              ),
          ],
        ),
      ),
    ),
  );
}

class NftGrid extends StatelessWidget {
  const NftGrid(this.items, {super.key, required this.onTap});
  final List<Nft> items;
  final ValueChanged<Nft> onTap;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: constraints.maxWidth > 500 ? 3 : 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent:
            (constraints.maxWidth - (constraints.maxWidth > 500 ? 32 : 16)) /
                (constraints.maxWidth > 500 ? 3 : 2) +
            108 * MediaQuery.textScalerOf(context).scale(1),
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => NftCard(items[i], onTap: () => onTap(items[i])),
    ),
  );
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.search_off,
    this.action,
  });
  final String title, subtitle;
  final IconData icon;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
    child: Column(
      children: [
        Icon(icon, size: 48, color: coralYellow),
        const SizedBox(height: 18),
        Text(
          title,
          style: context.text.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: context.text.bodySmall,
          textAlign: TextAlign.center,
        ),
        if (action != null) ...[const SizedBox(height: 20), action!],
      ],
    ),
  );
}
