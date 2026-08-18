import 'package:flutter/material.dart';

import '../../app/app_localizations.dart';
import '../devices/device_page.dart';
import '../help/crop_guide_page.dart';
import '../help/help_page.dart';
import '../history/history_page.dart';
import '../home/home_page.dart';
import '../scan/scan_page.dart';
import '../settings/settings_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  void _open(Widget page) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));

  @override
  Widget build(BuildContext context) {
    final titles = [
      context.tr('home'),
      context.tr('scan'),
      context.tr('history'),
      context.tr('devices'),
      context.tr('settings'),
    ];
    final pages = [
      HomePage(
        onScan: () => setState(() => _index = 1),
        onHistory: () => setState(() => _index = 2),
        onDevices: () => setState(() => _index = 3),
        onCropGuide: () => _open(const CropGuidePage()),
        onHelp: () => _open(const HelpPage()),
      ),
      ScanPage(onRecoveredCameraImage: () => setState(() => _index = 1)),
      const HistoryPage(),
      const DevicePage(),
      const SettingsPage(),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(titles[_index]), centerTitle: false),
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: context.tr('home'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.document_scanner_outlined),
            selectedIcon: const Icon(Icons.document_scanner),
            label: context.tr('scan'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.history),
            label: context.tr('history'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.cable_outlined),
            selectedIcon: const Icon(Icons.cable),
            label: context.tr('devices'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: context.tr('settings'),
          ),
        ],
      ),
    );
  }
}
