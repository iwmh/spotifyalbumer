import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme => ThemeData(
    colorScheme: const ColorScheme.dark(
      primary: AppColors.spotifyGreen,
      secondary: AppColors.spotifyGreen,
    ),
    useMaterial3: true,
  );
}
