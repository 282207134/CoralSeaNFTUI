import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../shared/widgets.dart';
import '../../state/marketplace_store.dart';
import '../wallet/onboarding_screen.dart';
import '../wallet/wallet_screen.dart';
import 'profile_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    return PageFrame(
      title: 'Settings',
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _tile(
            context,
            Icons.account_balance_wallet,
            'My Wallet',
            () => openPage(context, const WalletScreen()),
          ),
          const Divider(),
          _tile(
            context,
            Icons.notifications,
            'Notification',
            () => openPage(context, const NotificationSettingsScreen()),
          ),
          const Divider(),
          _tile(
            context,
            Icons.help,
            'FAQ & Support',
            () => openPage(context, const SupportScreen()),
          ),
          const Divider(),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.dark_mode_outlined),
            title: Text('Dark Mode', style: context.text.titleSmall),
            value: store.dark,
            activeThumbColor: coralYellow,
            onChanged: store.setDark,
          ),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.info_outline),
            title: Text('About CoralSea', style: context.text.titleSmall),
            subtitle: const Text('Version 1.0.0 · Local demo'),
            onTap: () => showAboutDialog(
              context: context,
              applicationName: 'CoralSea',
              applicationVersion: '1.0.0',
              applicationIcon: Image.asset(
                'assets/images/logo.png',
                width: 48,
                height: 48,
              ),
              children: [
                const Text(
                  'A digital art marketplace inspired by the CoralSea NFT UI KIT. All transactions and wallet balances in this app are simulated.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 80),
          FilledButton(
            onPressed: () async {
              if (store.wallet != null) {
                await store.disconnect();
                if (context.mounted) {
                  message(context, 'Demo wallet disconnected');
                }
              } else if (context.mounted) {
                openPage(context, const ConnectWalletScreen());
              }
            },
            child: Text(store.wallet == null ? 'Connect Wallet' : 'Disconnect'),
          ),
        ],
      ),
    );
  }

  Widget _tile(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(icon),
    title: Text(title, style: context.text.titleSmall),
    trailing: const Icon(Icons.chevron_right),
    onTap: onTap,
  );
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    return PageFrame(
      title: 'Notifications',
      actions: [
        IconButton(
          tooltip: 'Notification settings',
          icon: const Icon(Icons.tune),
          onPressed: () =>
              openPage(context, const NotificationSettingsScreen()),
        ),
      ],
      child: ListView(
        children: [
          const SizedBox(height: 16),
          if (!store.notifications)
            const EmptyState(
              icon: Icons.notifications_off_outlined,
              title: 'Notifications are paused',
              subtitle: 'You can turn on in-app activity updates in Settings.',
            )
          else ...[
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text('Latest Activity', style: context.text.titleMedium),
            ),
            EventList(events: store.events),
            const Divider(),
            const ListTile(
              leading: Avatar(name: 'degods', verified: true, size: 40),
              title: Text('Welcome to CoralSea'),
              subtitle: Text(
                'Discover your next favorite piece of digital art.',
              ),
            ),
            const ListTile(
              leading: Icon(Icons.auto_awesome, color: coralYellow),
              title: Text('A new world of creativity'),
              subtitle: Text(
                'Explore the latest drops from our featured creators.',
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    return PageFrame(
      title: 'Notification',
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Activity Notifications',
              style: context.text.titleSmall,
            ),
            subtitle: const Text(
              'Show your purchases, offers and creations in the in-app activity feed.',
            ),
            value: store.notifications,
            activeThumbColor: coralYellow,
            onChanged: store.setNotifications,
          ),
          const Divider(),
          Text(
            'Notification preferences are saved on this device. This demo does not send push notifications.',
            style: context.text.bodySmall,
          ),
        ],
      ),
    );
  }
}

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});
  @override
  Widget build(BuildContext context) => PageFrame(
    title: 'FAQ & Support',
    child: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Icon(Icons.support_agent, size: 64, color: coralYellow),
        const SizedBox(height: 20),
        Text(
          'A little help, a lot of possibility.',
          style: context.text.headlineMedium,
        ),
        const SizedBox(height: 24),
        ...const {
          'What is CoralSea?':
              'CoralSea is a digital art marketplace demo adapted from the Pixso CoralSea UI kit. Browse original art, save favorites and explore collecting.',
          'Is this a real crypto wallet?':
              'No. Connecting Metamask, Rainbow or an address here creates a simulated local wallet with demo ETH. This app never requests a seed phrase or private key.',
          'How do purchases and offers work?':
              'A purchase reduces your demo balance and adds the item to Collected. An offer records the amount and expiration without locking funds. Nothing is sent to a blockchain.',
          'How do I create an NFT?':
              'Tap +, choose a sample artwork or photo, enter a name and price, then select Create Item. Your item is saved locally; it is not minted on-chain.',
          'Where is my data stored?':
              'Favorites, settings, artwork and activity are stored on this device. Clearing app data removes this local demo. They do not sync to another device.',
          'How do I change the theme?':
              'Open Profile → Settings → Dark Mode. Your preference is remembered for your next visit.',
        }.entries.map(
          (e) => ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: Text(e.key, style: context.text.titleSmall),
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(e.value, style: context.text.bodyMedium),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
