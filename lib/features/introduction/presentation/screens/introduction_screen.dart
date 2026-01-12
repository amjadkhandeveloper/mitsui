import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/animations.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../splash/data/datasources/local_storage_data_source.dart';

class IntroductionScreen extends StatefulWidget {
  const IntroductionScreen({super.key});

  @override
  State<IntroductionScreen> createState() => _IntroductionScreenState();
}

class _IntroductionScreenState extends State<IntroductionScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<IntroductionSlide> _slides = [
    IntroductionSlide(
      title: 'Welcome to Mitsui',
      description: 'Manage your fleet operations efficiently with our comprehensive vehicle management system.',
      icon: Icons.directions_car,
      color: AppTheme.mitsuiBlue,
    ),
    IntroductionSlide(
      title: 'Track Attendance',
      description: 'Monitor driver attendance, check-in/check-out times, and generate detailed reports.',
      icon: Icons.access_time,
      color: Colors.orange,
    ),
    IntroductionSlide(
      title: 'Manage Trips & Receipts',
      description: 'Schedule trips, track vehicle usage, and submit expense receipts for approval.',
      icon: Icons.receipt_long,
      color: Colors.green,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeIntroduction() async {
    final localStorageDataSource = di.sl<LocalStorageDataSource>();
    await localStorageDataSource.setIntroductionCompleted();
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeIntroduction();
    }
  }

  void _skip() {
    _completeIntroduction();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              AppTheme.mitsuiLightBlue.withOpacity(0.3),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip Button
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _skip,
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Page View
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: _slides.length,
                  itemBuilder: (context, index) {
                    return _buildSlide(_slides[index], index);
                  },
                ),
              ),
              // Page Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _slides.length,
                  (index) => _buildPageIndicator(index == _currentPage),
                ),
              ),
              const SizedBox(height: 32),
              // Next/Get Started Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: FadeSlideAnimation(
                  delay: const Duration(milliseconds: 200),
                  beginOffset: const Offset(0, 0.2),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.mitsuiDarkBlue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentPage == _slides.length - 1
                            ? 'Get Started'
                            : 'Next',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlide(IntroductionSlide slide, int index) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeSlideAnimation(
            delay: Duration(milliseconds: 100 + (index * 100)),
            beginOffset: const Offset(0, 0.3),
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: slide.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                slide.icon,
                size: 100,
                color: slide.color,
              ),
            ),
          ),
          const SizedBox(height: 48),
          FadeSlideAnimation(
            delay: Duration(milliseconds: 200 + (index * 100)),
            beginOffset: const Offset(0, 0.2),
            child: Text(
              slide.title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          FadeSlideAnimation(
            delay: Duration(milliseconds: 300 + (index * 100)),
            beginOffset: const Offset(0, 0.2),
            child: Text(
              slide.description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? AppTheme.mitsuiBlue : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class IntroductionSlide {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  IntroductionSlide({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

