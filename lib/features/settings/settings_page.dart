import 'package:flutter/material.dart';

import '../../app/app_controller.dart';
import '../../app/app_localizations.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppControllerScope.of(context);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          context.tr('appearanceLanguage'),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Card(
          child: RadioGroup<String>(
            groupValue: controller.locale.languageCode,
            onChanged: (value) {
              if (value != null) controller.setLocale(Locale(value));
            },
            child: Column(
              children: [
                RadioListTile<String>(
                  value: 'en',
                  title: Text(context.tr('english')),
                ),
                RadioListTile<String>(
                  value: 'sw',
                  title: Text(context.tr('swahili')),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.school_outlined),
            title: Text(context.tr('localPrototype')),
            subtitle: Text(context.tr('localPrototypeDescription')),
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          key: const Key('logoutButton'),
          onPressed: controller.busy ? null : controller.logout,
          icon: const Icon(Icons.logout),
          label: Text(context.tr('logout')),
        ),
      ],
    );
  }
}
