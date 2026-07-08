import 'package:flutter/material.dart';

class SplashLoadingIndicator extends StatelessWidget {
  final bool show;

  const SplashLoadingIndicator({
    super.key,
    this.show = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!show) return const SizedBox.shrink();

    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    );
  }
}
