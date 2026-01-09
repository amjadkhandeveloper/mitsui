import 'package:flutter/material.dart';

class SplashLogo extends StatefulWidget {
  final VoidCallback? onAnimationComplete;
  final String? logoPath;
  final String? appName;

  const SplashLogo({
    super.key,
    this.onAnimationComplete,
    this.logoPath,
    this.appName,
  });

  @override
  State<SplashLogo> createState() => _SplashLogoState();
}

class _SplashLogoState extends State<SplashLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _controller.forward().then((_) {
      widget.onAnimationComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo/Icon - White square with black icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: widget.logoPath != null
                        ? Padding(
                            padding: const EdgeInsets.all(20),
                            child: Image.asset(
                              widget.logoPath!,
                              fit: BoxFit.contain,
                            ),
                          )
                        : const Icon(
                            Icons.business,
                            size: 60,
                            color: Colors.black87,
                          ),
                  ),
                  const SizedBox(height: 16),
                  // Company Name
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: const Text(
                      'MITSUI & CO.',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // App Title
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: const Text(
                      'Fleet Management System',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
