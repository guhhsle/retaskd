import 'package:flutter/material.dart';

import '../data.dart';
import 'colors.dart';

ThemeData themeData({
  required Color tc,
  required Color bc,
  required bool dark,
}) {
  Color getColor(Set<MaterialState> states) {
    return tc.withOpacity(0.2);
  }

  Color getColorThumb(Set<MaterialState> states) {
    return tc;
  }

  return ThemeData(
    fontFamily: pf['font'],
    textTheme: TextTheme(
      titleLarge: TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.transparent,
        fontFamily: pf['font'],
      ),
      bodyMedium: TextStyle(
        fontWeight: FontWeight.bold,
        color: tc,
        fontFamily: pf['font'],
      ),
      bodyLarge: TextStyle(
        fontWeight: FontWeight.bold,
        color: tc,
        fontFamily: pf['font'],
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith(getColorThumb),
      trackColor: MaterialStateProperty.resolveWith(getColor),
    ),
    primaryColor: tc,
    colorScheme: ColorScheme(
      primary: tc,
      onPrimary: bc,
      background: bc,
      onBackground: tc,
      surface: bc,
      onSurface: tc,
      error: tc,
      onError: bc,
      brightness: dark ? Brightness.dark : Brightness.light,
      secondary: tc,
      onSecondary: bc,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: tc,
        textStyle: TextStyle(
          color: tc,
          fontWeight: FontWeight.bold,
          fontFamily: pf['font'],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      counterStyle: TextStyle(color: tc, fontWeight: FontWeight.bold),
      labelStyle: TextStyle(color: tc, fontWeight: FontWeight.bold),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: tc, width: 2),
      ),
      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: tc, width: 2)),
    ),
    dialogBackgroundColor: bc,
    appBarTheme: AppBarTheme(
      backgroundColor: pf['appbar'] == 'Transparent'
          ? Colors.transparent
          : pf['appbar'] == 'Primary'
              ? tc
              : Colors.black,
      foregroundColor: textColor(tc, bc),
      shadowColor: Colors.transparent,
      titleTextStyle: TextStyle(
        fontWeight: FontWeight.bold,
        color: textColor(tc, bc),
        fontFamily: pf['font'],
        fontSize: 18,
      ),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: tc,
      textColor: tc,
      style: ListTileStyle.drawer,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: bc,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: tc, width: 2),
      ),
      checkmarkColor: bc,
      selectedColor: tc,
      shadowColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      deleteIconColor: bc,
    ),
    scaffoldBackgroundColor: bc,
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: bc,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: tc,
      refreshBackgroundColor: bc,
    ),
    canvasColor: Colors.transparent,
    cardTheme: CardTheme(
      elevation: 6,
      shadowColor: tc,
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      color: tc,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    dividerColor: tc,
    iconTheme: IconThemeData(color: tc),
    shadowColor: tc,
  );
}
