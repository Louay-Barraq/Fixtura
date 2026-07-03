import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/roulette_wheel.dart';

class StandaloneRouletteScreen extends StatefulWidget {
  const StandaloneRouletteScreen({super.key});

  @override
  State<StandaloneRouletteScreen> createState() => _StandaloneRouletteScreenState();
}

class _StandaloneRouletteScreenState extends State<StandaloneRouletteScreen> {
  final TextEditingController _inputController = TextEditingController();
  final List<String> _options = [];
  String? _result;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _addOption() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    if (_options.contains(text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This option already exists!'), backgroundColor: AppTheme.accent),
      );
      return;
    }
    setState(() {
      _options.add(text);
      _inputController.clear();
      _result = null; // Clear previous result when options change
    });
  }

  void _removeOption(int index) {
    setState(() {
      _options.removeAt(index);
      _result = null;
    });
  }

  void _quickAddNumbers(int count) {
    setState(() {
      _options.clear();
      for (int i = 1; i <= count; i++) {
        _options.add('Option $i');
      }
      _result = null;
    });
  }

  void _showResultDialog(String winner) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppTheme.primary, width: 2),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.stars, color: AppTheme.primary, size: 64),
            const SizedBox(height: 16),
            const Text(
              'ROULETTE RESULT',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            ShaderMask(
              shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(bounds),
              child: Text(
                winner.toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: AppTheme.background,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text('AWESOME', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Roulette'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // List / input area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Input Row
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _inputController,
                            style: const TextStyle(color: AppTheme.textPrimary),
                            decoration: InputDecoration(
                              labelText: 'Add Custom Option',
                              hintText: 'e.g. Player Name or Team',
                              labelStyle: const TextStyle(color: AppTheme.textSecondary),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppTheme.divider),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppTheme.primary),
                              ),
                              filled: true,
                              fillColor: AppTheme.surface,
                            ),
                            onSubmitted: (_) => _addOption(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _addOption,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          ),
                          child: const Icon(Icons.add, color: AppTheme.background),
                        )
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Quick helpers
                    Row(
                      children: [
                        const Text('Quick Add: ', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                        ActionChip(
                          label: const Text('4 Options'),
                          labelStyle: const TextStyle(color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.bold),
                          backgroundColor: AppTheme.surface,
                          side: const BorderSide(color: AppTheme.divider),
                          onPressed: () => _quickAddNumbers(4),
                        ),
                        const SizedBox(width: 8),
                        ActionChip(
                          label: const Text('8 Options'),
                          labelStyle: const TextStyle(color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.bold),
                          backgroundColor: AppTheme.surface,
                          side: const BorderSide(color: AppTheme.divider),
                          onPressed: () => _quickAddNumbers(8),
                        ),
                        const SizedBox(width: 8),
                        if (_options.isNotEmpty)
                          TextButton(
                            onPressed: () => setState(() {
                              _options.clear();
                              _result = null;
                            }),
                            child: const Text('Clear All', style: TextStyle(color: AppTheme.accent, fontSize: 12)),
                          )
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Wheel container
                    Center(
                      child: RouletteWheel(
                        options: _options,
                        size: 280,
                        onResult: (winner) {
                          setState(() {
                            _result = winner;
                          });
                          _showResultDialog(winner);
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    if (_result != null) ...[
                      Text(
                        'Landed on: $_result',
                        style: const TextStyle(
                          color: AppTheme.primary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Current list items
                    if (_options.isNotEmpty) ...[
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'WHEEL OPTIONS',
                          style: TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _options.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppTheme.divider.withOpacity(0.5)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _options[index],
                                  style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, color: AppTheme.accent, size: 18),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () => _removeOption(index),
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    ]
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
