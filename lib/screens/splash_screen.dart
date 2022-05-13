import 'package:flutter/material.dart';
import '/layouts/default_layout.dart';
import '/services/navigation.dart';
import '/widgets/logo.dart';

class SplashScreen extends StatelessWidget implements Screen {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Page get navPage =>
      PlainPage(key: const ValueKey('SplashScreenPage'), child: this);

  @override
  Widget build(BuildContext context) {
    return const DefaultLayout(
      child: Center(
        child: Logo(),
      ),
    );
  }
}
