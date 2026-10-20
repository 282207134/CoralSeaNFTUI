import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme.dart';
import 'features/marketplace/marketplace_shell.dart';
import 'features/wallet/onboarding_screen.dart';
import 'state/marketplace_store.dart';

class CoralSeaApp extends StatelessWidget {
  const CoralSeaApp({super.key, required this.store});
  final MarketplaceStore store;
  @override
  Widget build(BuildContext context) => AppScope(
    store: store,
    child: ListenableBuilder(
      listenable: store,
      builder: (context, _) => MaterialApp(
        title: 'CoralSea',
        debugShowCheckedModeBanner: false,
        theme: coralTheme(false),
        darkTheme: coralTheme(true),
        themeMode: store.dark ? ThemeMode.dark : ThemeMode.light,
        home: store.onboarded
            ? const MarketplaceShell()
            : const OnboardingScreen(),
        builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
          value:
              (store.dark
                      ? SystemUiOverlayStyle.light
                      : SystemUiOverlayStyle.dark)
                  .copyWith(
                    statusBarColor: Colors.transparent,
                    systemNavigationBarColor: context.colors.surface,
                  ),
          child: ColoredBox(
            color: store.dark
                ? const Color(0xFF111827)
                : const Color(0xFFE9ECF0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  children: [
                    Expanded(child: child!),
                    if (store.storageError != null)
                      Material(
                        color: context.colors.errorContainer,
                        child: SafeArea(
                          top: false,
                          child: ListTile(
                            dense: true,
                            title: Text(
                              store.storageError!,
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: TextButton(
                              onPressed: store.retrySave,
                              child: const Text('Retry'),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
