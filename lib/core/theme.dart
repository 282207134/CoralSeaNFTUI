import 'package:flutter/material.dart';

const coralYellow = Color(0xFFFFBB00);
const ink = Color(0xFF1A1A1A);
ThemeData coralTheme(bool dark) {
  final surface = dark ? const Color(0xFF1F2937) : const Color(0xFFFDFDFD);
  final card = dark ? const Color(0xFF374151) : const Color(0xFFF3F4F6);
  final foreground = dark ? Colors.white : ink;
  final scheme = ColorScheme.fromSeed(
    seedColor: coralYellow,
    brightness: dark ? Brightness.dark : Brightness.light,
    primary: coralYellow,
    onPrimary: ink,
    surface: surface,
    onSurface: foreground,
    surfaceContainerHighest: card,
    outlineVariant: dark ? const Color(0xFF4B5563) : const Color(0xFFE8ECF1),
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: surface,
    fontFamily: 'PlusJakartaSans',
    textTheme: TextTheme(
      headlineMedium: TextStyle(
        fontSize: 25,
        height: 1.4,
        fontWeight: FontWeight.w700,
        color: foreground,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: foreground,
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: foreground,
      ),
      titleSmall: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: foreground,
      ),
      bodyMedium: TextStyle(fontSize: 14, height: 1.5, color: foreground),
      bodySmall: TextStyle(
        fontSize: 12,
        height: 1.5,
        color: dark ? Colors.white60 : const Color(0xFF8C8C8C),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: surface,
      foregroundColor: foreground,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: foreground,
      ),
    ),
    dividerTheme: DividerThemeData(
      color: scheme.outlineVariant,
      thickness: 1,
      space: 28,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: coralYellow,
        foregroundColor: ink,
        minimumSize: const Size(double.infinity, 48),
        textStyle: const TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: foreground,
        minimumSize: const Size(double.infinity, 48),
        side: BorderSide(color: scheme.outline),
        textStyle: const TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: card,
      hintStyle: TextStyle(
        fontSize: 12,
        color: dark ? Colors.white38 : const Color(0xFF999999),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: coralYellow),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}

extension CoralContext on BuildContext {
  TextTheme get text => Theme.of(this).textTheme;
  ColorScheme get colors => Theme.of(this).colorScheme;
  Color get panel => colors.surfaceContainerHighest;
}
