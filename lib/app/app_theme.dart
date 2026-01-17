import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reminder_app/utils/app_color.dart';
import 'package:reminder_app/utils/app_typography.dart';

/// App Theme configuration with Material 3
/// Professional gaming company theme with modern aesthetics
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColor.primary,
      scaffoldBackgroundColor: AppColor.background,
      textTheme: AppTypography.textTheme,
      colorScheme: ColorScheme.light(
        primary: AppColor.primary,
        primaryContainer: AppColor.primarySurface,
        secondary: AppColor.secondary,
        secondaryContainer: AppColor.secondaryLight.withValues(alpha: 0.2),
        tertiary: AppColor.accent,
        tertiaryContainer: AppColor.accentLight.withValues(alpha: 0.2),
        surface: AppColor.surface,
        error: AppColor.error,
        errorContainer: AppColor.errorLight,
        onPrimary: AppColor.white,
        onSecondary: AppColor.white,
        onSurface: AppColor.textPrimary,
        onError: AppColor.white,
        outline: AppColor.border,
        outlineVariant: AppColor.gray200,
        shadow: AppColor.gray400,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColor.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.titleLarge,
        systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.primary,
          foregroundColor: AppColor.white,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
          textStyle: AppTypography.buttonMedium,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColor.primary,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          side: const BorderSide(color: AppColor.primary, width: 1.5),
          textStyle: AppTypography.buttonMedium,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColor.primary,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTypography.buttonMedium,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColor.primary,
        foregroundColor: AppColor.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColor.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColor.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColor.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColor.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColor.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColor.error, width: 2),
        ),
        labelStyle: AppTypography.bodyMedium.copyWith(
          color: AppColor.textSecondary,
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColor.textTertiary,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColor.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        shadowColor: AppColor.gray400.withValues(alpha: 0.3),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColor.divider,
        thickness: 1,
        space: 1,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColor.white,
        selectedItemColor: AppColor.primary,
        unselectedItemColor: AppColor.gray400,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: AppTypography.labelSmall.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTypography.labelSmall,
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColor.gray800,
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: AppColor.white,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
        elevation: 8,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColor.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: AppTypography.titleLarge,
        contentTextStyle: AppTypography.bodyMedium,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColor.white,
        elevation: 16,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        dragHandleColor: AppColor.gray300,
        dragHandleSize: const Size(40, 4),
        showDragHandle: true,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColor.gray100,
        selectedColor: AppColor.primary.withValues(alpha: 0.2),
        disabledColor: AppColor.gray100,
        labelStyle: AppTypography.labelMedium,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        titleTextStyle: AppTypography.titleMedium,
        subtitleTextStyle: AppTypography.bodySmall,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColor.primary;
          }
          return AppColor.gray400;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColor.primaryLight.withValues(alpha: 0.4);
          }
          return AppColor.gray200;
        }),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColor.primary,
        linearTrackColor: AppColor.primary.withValues(alpha: 0.2),
        circularTrackColor: AppColor.primary.withValues(alpha: 0.2),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColor.primary,
        inactiveTrackColor: AppColor.gray200,
        thumbColor: AppColor.primary,
        overlayColor: AppColor.primary.withValues(alpha: 0.2),
        valueIndicatorColor: AppColor.primary,
        valueIndicatorTextStyle: AppTypography.labelMedium.copyWith(
          color: AppColor.white,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColor.primary,
      scaffoldBackgroundColor: AppColor.backgroundDark,
      textTheme: AppTypography.textThemeDark,
      colorScheme: ColorScheme.dark(
        primary: AppColor.primaryLight,
        primaryContainer: AppColor.primaryDark,
        secondary: AppColor.secondaryLight,
        secondaryContainer: AppColor.secondaryDark,
        tertiary: AppColor.accentLight,
        tertiaryContainer: AppColor.accentDark,
        surface: AppColor.surfaceDark,
        error: AppColor.error,
        errorContainer: AppColor.errorLight.withValues(alpha: 0.3),
        onPrimary: AppColor.white,
        onSecondary: AppColor.white,
        onSurface: AppColor.textPrimaryDark,
        onError: AppColor.white,
        outline: AppColor.borderDark,
        outlineVariant: AppColor.gray700,
        shadow: AppColor.black,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColor.textPrimaryDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.titleLarge.copyWith(
          color: AppColor.textPrimaryDark,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.primaryLight,
          foregroundColor: AppColor.white,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
          textStyle: AppTypography.buttonMedium,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColor.primaryLight,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          side: const BorderSide(color: AppColor.primaryLight, width: 1.5),
          textStyle: AppTypography.buttonMedium,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColor.primaryLight,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTypography.buttonMedium,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColor.primaryLight,
        foregroundColor: AppColor.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColor.surfaceDark,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColor.borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColor.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColor.primaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColor.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColor.error, width: 2),
        ),
        labelStyle: AppTypography.bodyMedium.copyWith(
          color: AppColor.textSecondaryDark,
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColor.textTertiaryDark,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColor.surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColor.dividerDark,
        thickness: 1,
        space: 1,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColor.surfaceDark,
        selectedItemColor: AppColor.primaryLight,
        unselectedItemColor: AppColor.gray500,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: AppTypography.labelSmall.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTypography.labelSmall,
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColor.gray700,
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: AppColor.textPrimaryDark,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
        elevation: 8,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColor.surfaceDark,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: AppTypography.titleLarge.copyWith(
          color: AppColor.textPrimaryDark,
        ),
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: AppColor.textSecondaryDark,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColor.surfaceDark,
        elevation: 16,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        dragHandleColor: AppColor.gray600,
        dragHandleSize: const Size(40, 4),
        showDragHandle: true,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColor.gray800,
        selectedColor: AppColor.primaryDark.withValues(alpha: 0.4),
        disabledColor: AppColor.gray800,
        labelStyle: AppTypography.labelMedium.copyWith(
          color: AppColor.textPrimaryDark,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        titleTextStyle: AppTypography.titleMedium.copyWith(
          color: AppColor.textPrimaryDark,
        ),
        subtitleTextStyle: AppTypography.bodySmall.copyWith(
          color: AppColor.textSecondaryDark,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColor.primaryLight;
          }
          return AppColor.gray500;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColor.primary.withValues(alpha: 0.4);
          }
          return AppColor.gray700;
        }),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColor.primaryLight,
        linearTrackColor: AppColor.primaryLight.withValues(alpha: 0.2),
        circularTrackColor: AppColor.primaryLight.withValues(alpha: 0.2),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColor.primaryLight,
        inactiveTrackColor: AppColor.gray700,
        thumbColor: AppColor.primaryLight,
        overlayColor: AppColor.primaryLight.withValues(alpha: 0.2),
        valueIndicatorColor: AppColor.primaryLight,
        valueIndicatorTextStyle: AppTypography.labelMedium.copyWith(
          color: AppColor.white,
        ),
      ),
    );
  }
}
