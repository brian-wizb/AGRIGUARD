import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app/app_controller.dart';
import 'app/app_localizations.dart';
import 'app/app_theme.dart';
import 'core/preferences/app_preferences.dart';
import 'core/security/password_hasher.dart';
import 'core/storage/app_database.dart';
import 'features/auth/data/sqlite_auth_repository.dart';
import 'features/auth/login_page.dart';
import 'features/shell/app_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AgriGuardBootstrap());
}

class AgriGuardBootstrap extends StatefulWidget {
  const AgriGuardBootstrap({this.controller, super.key});

  final AppController? controller;

  @override
  State<AgriGuardBootstrap> createState() => _AgriGuardBootstrapState();
}

class _AgriGuardBootstrapState extends State<AgriGuardBootstrap> {
  late final AppController _controller;

  @override
  void initState() {
    super.initState();
    final database = AppDatabase();
    _controller =
        widget.controller ??
        AppController(
          SqliteAuthRepository(
            database: database,
            passwordHasher: PasswordHasher(),
          ),
          SharedAppPreferences(),
        );
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) => AgriGuardApp(controller: _controller),
    );
  }
}

class AgriGuardApp extends StatelessWidget {
  const AgriGuardApp({required this.controller, super.key});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return AppControllerScope(
      controller: controller,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'AgriGuard',
        theme: AppTheme.light,
        locale: controller.locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: !controller.initialized
            ? const _StartupPage()
            : controller.isAuthenticated
            ? const AppShell()
            : const LoginPage(),
      ),
    );
  }
}

class _StartupPage extends StatelessWidget {
  const _StartupPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
