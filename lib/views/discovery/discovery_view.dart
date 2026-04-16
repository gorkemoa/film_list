import 'package:flutter/material.dart';
import '../../app/app_theme.dart';

class DiscoveryView extends StatelessWidget {
  const DiscoveryView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Center(
        child: Text(
          'Discovery',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}
