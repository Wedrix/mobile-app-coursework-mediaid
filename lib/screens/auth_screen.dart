import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import '/layouts/default_layout.dart';
import '/services/navigation.dart';
import '/widgets/logo.dart';

class AuthScreen extends StatelessWidget implements Screen {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  Page get navPage =>
      PlainPage(key: const ValueKey('AuthScreenPage'), child: this);

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      child: SignInScreen(
        headerBuilder: (_, __, ___) => const Logo(),
        providerConfigs: const [
          EmailProviderConfiguration(),
        ],
      ),
    );
  }
}
