import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_theme.dart';
import 'screens/main_layout.dart';
import 'screens/auth/login_page.dart';
import 'providers/auth_provider.dart';

void main() {
  runApp(
    const ProviderScope(
      child: TaskitoApp(),
    ),
  );
}

class TaskitoApp extends ConsumerWidget {
  const TaskitoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Taskito',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light, // Enforce light theme
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (authState.isAuthenticated) {
      return const MainLayout();
    }

    return const LoginPage();
  }
}
