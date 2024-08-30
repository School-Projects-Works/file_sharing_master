import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../generated/assets.dart';
import '../../utils/colors.dart';

class FooterPage extends ConsumerWidget {
  const FooterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      color: primaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        children: [
          // Logo
          Image.asset(Assets.imagesLogoT, height: 30),
          const SizedBox(width: 20),
          const Expanded(
            child: Text('© 2024 Online Notice Board',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
