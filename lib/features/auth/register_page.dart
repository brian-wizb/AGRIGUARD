import 'package:flutter/material.dart';

import '../../app/app_controller.dart';
import '../../app/app_localizations.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await AppControllerScope.of(context).register(
      username: _usernameController.text,
      password: _passwordController.text,
    );
    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppControllerScope.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('registerTitle'))),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      context.tr('registerSubtitle'),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      key: const Key('registerUsernameField'),
                      controller: _usernameController,
                      autocorrect: false,
                      decoration: InputDecoration(
                        labelText: context.tr('username'),
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                      validator: (value) {
                        final username = value?.trim() ?? '';
                        if (username.isEmpty) {
                          return context.tr('requiredField');
                        }
                        if (username.length < 3) {
                          return context.tr('usernameLength');
                        }
                        return null;
                      },
                      onChanged: (_) => controller.clearAuthError(),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      key: const Key('registerPasswordField'),
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: context.tr('password'),
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return context.tr('requiredField');
                        }
                        if (value.length < 8) {
                          return context.tr('passwordLength');
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      key: const Key('confirmPasswordField'),
                      controller: _confirmationController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: context.tr('confirmPassword'),
                        prefixIcon: const Icon(Icons.lock_reset_outlined),
                      ),
                      validator: (value) => value != _passwordController.text
                          ? context.tr('passwordMismatch')
                          : null,
                    ),
                    if (controller.authErrorCode != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        context.tr(controller.authErrorCode!),
                        key: const Key('registerError'),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 24),
                    FilledButton(
                      key: const Key('registerButton'),
                      onPressed: controller.busy ? null : _register,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: controller.busy
                            ? const SizedBox.square(
                                dimension: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(context.tr('register')),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
