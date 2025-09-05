import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sims4_name_generator/theme/app_theme.dart';
import 'package:sims4_name_generator/navigation/app_routes.dart';
import 'package:sims4_name_generator/providers/state_providers.dart';

void main() {
  runApp(const ProviderScope(child: Sims4NameGeneratorApp()));
}

class Sims4NameGeneratorApp extends ConsumerWidget {
  const Sims4NameGeneratorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Sims 4 - Name & Trait Generator',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
      onGenerateRoute: (settings) {
        // Handle any dynamic routes here if needed
        return MaterialPageRoute(
          builder: (context) =>
              const Scaffold(body: Center(child: Text('Page not found'))),
        );
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
