import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ContainerPage extends ConsumerWidget {
  const ContainerPage({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
              color: Colors.white54,
              child: Center(
                child: child,
              ),
            )

    );
  }
}
