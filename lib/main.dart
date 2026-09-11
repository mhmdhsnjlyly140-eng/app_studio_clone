import 'package:flutter/material.dart';
import 'theme/theme_notifier.dart';
import 'screens/splash_screen.dart';

void main() => runApp(const AppLand());

class AppLand extends StatelessWidget {
  const AppLand({super.key});
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeNotifier,
      builder: (context, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'اپ لند',
        themeMode: themeNotifier.isDark ? ThemeMode.dark : ThemeMode.light,
        theme: ThemeData(
          brightness: Brightness.light,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6A11CB), brightness: Brightness.light),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6A11CB), brightness: Brightness.dark),
          useMaterial3: true,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}