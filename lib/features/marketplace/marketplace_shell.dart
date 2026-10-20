import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../shared/widgets.dart';
import '../create/create_screen.dart';
import '../profile/profile_screen.dart';
import 'browse_screens.dart';
import 'home_screen.dart';

class MarketplaceShell extends StatefulWidget {
  const MarketplaceShell({super.key});
  @override
  State<MarketplaceShell> createState() => _MarketplaceShellState();
}

class _MarketplaceShellState extends State<MarketplaceShell> {
  int index = 0;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      bottom: false,
      child: IndexedStack(
        index: index,
        children: [
          HomeScreen(onExplore: () => setState(() => index = 1)),
          const ExploreScreen(),
          const SearchScreen(),
          const ProfileScreen(),
        ],
      ),
    ),
    floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    floatingActionButton: SizedBox(
      width: 58,
      height: 58,
      child: FloatingActionButton(
        key: const Key('create-nft'),
        tooltip: 'Create NFT',
        elevation: 0,
        shape: CircleBorder(
          side: BorderSide(color: context.colors.surface, width: 4),
        ),
        backgroundColor: coralYellow,
        foregroundColor: Colors.white,
        onPressed: () => openPage(context, const CreateScreen()),
        child: const Icon(Icons.add, size: 30),
      ),
    ),
    bottomNavigationBar: DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: .03), blurRadius: 20),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Row(
            children: [
              _tab(0, Icons.home_outlined, Icons.home_rounded, 'Home'),
              _tab(1, Icons.star_border_rounded, Icons.star_rounded, 'Explore'),
              const SizedBox(width: 64),
              _tab(2, Icons.search_rounded, Icons.search_rounded, 'Search'),
              _tab(
                3,
                Icons.person_outline_rounded,
                Icons.person_rounded,
                'Profile',
              ),
            ],
          ),
        ),
      ),
    ),
  );
  Widget _tab(int tab, IconData icon, IconData active, String label) =>
      Expanded(
        child: Semantics(
          selected: index == tab,
          label: label,
          button: true,
          child: InkWell(
            key: Key('nav-${label.toLowerCase()}'),
            onTap: () => setState(() => index = tab),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  index == tab ? active : icon,
                  color: index == tab
                      ? coralYellow
                      : context.text.bodySmall!.color,
                  size: 27,
                ),
                const SizedBox(height: 7),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: index == tab ? 22 : 0,
                  height: 4,
                  decoration: BoxDecoration(
                    color: coralYellow,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
