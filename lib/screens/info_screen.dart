import 'package:flutter/material.dart';
import '/layouts/default_layout.dart';
import '/services/navigation.dart';

class InfoScreen extends StatelessWidget implements Screen {
  const InfoScreen({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Page get navPage =>
      PlainPage(key: const ValueKey('InfoScreenPage'), child: this);
}
