import 'package:flutter/material.dart';
import 'colors.dart';

class AdminTheme {
  AdminTheme._();
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AdminColors.dark,
        colorScheme: ColorScheme.dark(
          primary: AdminColors.primary,
          surface: AdminColors.sidebar,
          background: AdminColors.dark,
        ),
        cardTheme: CardTheme(
          color: AdminColors.sidebar,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AdminColors.sidebar,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: AdminColors.textLight,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AdminColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AdminColors.card,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AdminColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AdminColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AdminColors.primary),
          ),
          labelStyle: const TextStyle(color: AdminColors.textMuted),
        ),
        dataTableTheme: DataTableThemeData(
          headingRowColor: WidgetStateProperty.all(AdminColors.card),
          dataRowColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.hovered)
                  ? AdminColors.card.withOpacity(0.5)
                  : AdminColors.sidebar),
          headingTextStyle: const TextStyle(
            color: AdminColors.textMuted,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          dataTextStyle: const TextStyle(color: AdminColors.textLight, fontSize: 13),
          dividerThickness: 0.5,
        ),
      );
}
