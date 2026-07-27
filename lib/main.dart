import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app/app_controller.dart';
import 'app/app_localizations.dart';
import 'app/app_theme.dart';
import 'features/auth/login_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AgriGuardBootstrap());
}

class AgriGuardBootstrap extends StatefulWidget {
  const AgriGuardBootstrap({super.key});

  @override
  State<AgriGuardBootstrap> createState() => _AgriGuardBootstrapState();
}

class _AgriGuardBootstrapState extends State<AgriGuardBootstrap> {
  late final AppController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AppController();
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
        home: const LoginPage(),
      ),
    );
  }
}
