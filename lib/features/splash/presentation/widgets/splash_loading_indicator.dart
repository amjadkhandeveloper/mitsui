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

    return Positioned(
      bottom: 80,
      left: 0,
      right: 0,
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
