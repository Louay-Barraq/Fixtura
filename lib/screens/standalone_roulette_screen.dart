import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:fixtura/l10n/app_localizations.dart';
import '../widgets/main_appbar.dart';
import '../widgets/short_section_header.dart';
import '../widgets/custom_roulette_wheel.dart';
import '../widgets/dynamic_input.dart';

class StandaloneRouletteScreen extends StatefulWidget {
  const StandaloneRouletteScreen({super.key});

  @override
  State<StandaloneRouletteScreen> createState() => _StandaloneRouletteScreenState();
}

class _StandaloneRouletteScreenState extends State<StandaloneRouletteScreen> {
  List<String> _options = ['Option 1', 'Option 2', 'Option 3', 'Option 4'];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFCFC),
      body: SafeArea(
        child: Column(
          children: [
            // Fixed Top App Bar with back button navigation
            Stack(
              children: [
                const MainAppbar(),
                Positioned.directional(
                  textDirection: Directionality.of(context),
                  start: 10,
                  top: 10,
                  child: IconButton(
                    icon: Transform.flip(
                      flipX: Directionality.of(context) == TextDirection.rtl,
                      child: const Icon(Icons.arrow_back, color: Colors.black),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    // Section 1: ADD OPTIONS (Dynamic Input on Top of Wheel)
                    ShortSectionHeader(title: l10n.addOptions),
                    const Gap(12),
                    DynamicInput(
                      tagType: 'Options',
                      hintText: 'Enter roulette option...',
                      initialTags: _options,
                      onTagsChanged: (tags) {
                        setState(() {
                          _options = List.from(tags);
                        });
                      },
                    ),
                    const Gap(24),

                    // Section 2: ROULETTE WHEEL
                    ShortSectionHeader(title: l10n.rouletteWheel),
                    const Gap(16),

                    if (_options.isEmpty) ...[
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 4,
                              spreadRadius: 2,
                              color: Colors.black.withValues(alpha: 0.25),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.pie_chart_outline, size: 48, color: Colors.black),
                            const Gap(12),
                            Text(
                              l10n.wheelIsEmpty,
                              style: const TextStyle(
                                fontFamily: 'RobotoMono',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const Gap(6),
                            Text(
                              l10n.addOptionsAbove,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'RobotoMono',
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      CustomRouletteWheel(
                        items: _options,
                        onResult: (winner) {
                          // Built-in winner dialog pops automatically from CustomRouletteWheel
                        },
                      ),
                    ],
                    const Gap(30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
