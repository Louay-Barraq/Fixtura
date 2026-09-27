import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fixtura/l10n/app_localizations.dart';
import 'dashboard_screen.dart';

class OnboardingScreen extends StatefulWidget {
  final bool isReplay;
  const OnboardingScreen({super.key, this.isReplay = false});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  static const int _totalSteps = 5;

  final List<OnboardingStepData> _steps = const [
    OnboardingStepData(
      stepNumber: 1,
      title: 'WELCOME TO FIXTURA',
      body:
          'Host and manage local tournaments with your friends: round robin leagues, knockout brackets, and more. All offline, all yours.',
      iconType: StepIconType.trophy,
    ),
    OnboardingStepData(
      stepNumber: 2,
      title: 'PLAYERS & TEAMS',
      body:
          'Players are the real people competing: you, your friends.\n\nTeams are the clubs they play as like PSG, Real Madrid, Barcelona, ... \n\nAdd your players first, then build your team pool.',
      iconType: StepIconType.playersAndTeams,
    ),
    OnboardingStepData(
      stepNumber: 3,
      title: 'SPIN THE ROULETTE',
      body:
          'Can\'t decide who plays as what? Enable Team Roulette and let the wheel pick for you.\n\nSet it to unique so no two players get the same team, or distinct across rounds so nobody repeats.',
      iconType: StepIconType.roulette,
    ),
    OnboardingStepData(
      stepNumber: 4,
      title: 'TRACK EVERY GAME',
      body:
          'Tap any match to enter the score. Standings update automatically the points, the goal difference, everything.\n\nSwitch between rounds using the chips at the top.',
      iconType: StepIconType.fixtures,
    ),
    OnboardingStepData(
      stepNumber: 5,
      title: 'YOU\'RE ALL SET',
      body:
          'Create your first tournament from the home screen, or spin a quick roulette for fun.\n\nLet\'s go!',
      iconType: StepIconType.ready,
    ),
  ];

  Future<void> _completeOnboarding() async {
    if (widget.isReplay) {
      // Opened from settings — just go back
      if (mounted) Navigator.of(context).pop();
      return;
    }

    // First launch — persist the flag so onboarding won't show again
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const DashboardScreen()),
    );
  }

  void _nextPage() {
    if (_currentPage < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final double progress = (_currentPage + 1) / _totalSteps;
    final bool isLastPage = _currentPage == _totalSteps - 1;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFCFC),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar: Red Progress Bar + Skip Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  // Incremental Red Progress Bar
                  Expanded(
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E5E5),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return Stack(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                width: constraints.maxWidth * progress,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD71212),
                                  borderRadius: BorderRadius.circular(3),
                                  boxShadow: [
                                    BoxShadow(
                                      offset: const Offset(0, 1),
                                      blurRadius: 3,
                                      color: const Color(0xFFD71212).withValues(alpha: 0.4),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  const Gap(16),

                  // Skip Button (fades out on last step)
                  AnimatedOpacity(
                    opacity: isLastPage ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: GestureDetector(
                      onTap: isLastPage ? null : _completeOnboarding,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.black.withValues(alpha: 0.15)),
                          boxShadow: [
                            BoxShadow(
                              offset: const Offset(0, 1),
                              blurRadius: 2,
                              color: Colors.black.withValues(alpha: 0.1),
                            ),
                          ],
                        ),
                        child: Text(
                          l10n.skip,
                          style: const TextStyle(
                            fontFamily: 'RobotoMono',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Middle: Swipeable PageView with illustrations & explanations
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _steps.length,
                itemBuilder: (context, index) {
                  final step = _steps[index];
                  return _OnboardingStepContent(step: step);
                },
              ),
            ),

            // Bottom Section: Dots indicator & Next / Get Started Action Button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                children: [
                  // Dot Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_totalSteps, (index) {
                      final bool isSelected = index == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isSelected ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFD71212) : Colors.black.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    offset: const Offset(0, 1),
                                    blurRadius: 3,
                                    color: const Color(0xFFD71212).withValues(alpha: 0.4),
                                  ),
                                ]
                              : null,
                        ),
                      );
                    }),
                  ),
                  const Gap(24),

                  // Next / Get Started Button (Neo-Brutalist design matching CreateTournamentButton)
                  GestureDetector(
                    onTap: _nextPage,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD71212),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                            spreadRadius: 0,
                            color: Colors.black.withValues(alpha: 0.25),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isLastPage ? l10n.getStarted : l10n.next,
                              style: const TextStyle(
                                fontFamily: 'BebasNeue',
                                fontSize: 20,
                                color: Colors.white,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const Gap(8),
                            Transform.flip(
                              flipX: Directionality.of(context) == TextDirection.rtl && !isLastPage,
                              child: Icon(
                                isLastPage ? Icons.rocket_launch_rounded : Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum StepIconType {
  trophy,
  playersAndTeams,
  roulette,
  fixtures,
  ready,
}

class OnboardingStepData {
  final int stepNumber;
  final String title;
  final String body;
  final StepIconType iconType;

  const OnboardingStepData({
    required this.stepNumber,
    required this.title,
    required this.body,
    required this.iconType,
  });
}

class _OnboardingStepContent extends StatelessWidget {
  final OnboardingStepData step;

  const _OnboardingStepContent({required this.step});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration Card
          _buildIllustrationCard(step.iconType),
          const Gap(32),

          // Title
          Text(
            step.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'BebasNeue',
              fontSize: 34,
              color: Colors.black,
              letterSpacing: 1.2,
            ),
          ),
          const Gap(16),

          // Body text card with Neo-brutalist container
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                  spreadRadius: 0,
                  color: Colors.black.withValues(alpha: 0.1),
                ),
              ],
            ),
            child: Text(
              step.body,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'RobotoMono',
                fontSize: 13,
                height: 1.5,
                color: Color(0xFF222222),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIllustrationCard(StepIconType type) {
    Widget iconContent;

    switch (type) {
      case StepIconType.trophy:
        iconContent = const Icon(
          Icons.emoji_events_rounded,
          size: 72,
          color: Color(0xFFD71212),
        );
        break;

      case StepIconType.playersAndTeams:
        iconContent = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.person_rounded,
                size: 38,
                color: Colors.white,
              ),
            ),
            const Gap(16),
            const Icon(
              Icons.swap_horiz_rounded,
              size: 28,
              color: Color(0xFFD71212),
            ),
            const Gap(16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFD71212),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.shield_rounded,
                size: 38,
                color: Colors.white,
              ),
            ),
          ],
        );
        break;

      case StepIconType.roulette:
        iconContent = Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black, width: 3),
            color: const Color(0xFFFFFCFC),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.rotate(
                angle: 0.4,
                child: const Icon(
                  Icons.pie_chart_rounded,
                  size: 64,
                  color: Color(0xFFD71212),
                ),
              ),
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        );
        break;

      case StepIconType.fixtures:
        iconContent = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.sports_soccer_rounded,
                size: 38,
                color: Colors.white,
              ),
            ),
            const Gap(16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFD71212),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.leaderboard_rounded,
                size: 38,
                color: Colors.white,
              ),
            ),
          ],
        );
        break;

      case StepIconType.ready:
        iconContent = const Icon(
          Icons.rocket_launch_rounded,
          size: 72,
          color: Color(0xFFD71212),
        );
        break;
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 170,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withValues(alpha: 0.12), width: 1.5),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 4),
            blurRadius: 8,
            spreadRadius: 0,
            color: Colors.black.withValues(alpha: 0.18),
          ),
        ],
      ),
      child: Center(child: iconContent),
    );
  }
}
