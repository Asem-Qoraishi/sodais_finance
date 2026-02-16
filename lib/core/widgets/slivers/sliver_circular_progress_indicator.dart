import 'package:flutter/material.dart';

class SliverCircularProgressIndicator extends StatelessWidget {
  const SliverCircularProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Center(child: CircularProgressIndicator()),
    );
  }
}
