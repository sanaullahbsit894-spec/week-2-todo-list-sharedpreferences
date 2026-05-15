import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/storage_service.dart';

class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key});

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen>
    with SingleTickerProviderStateMixin {
  int _counter = 0;
  bool _isLoading = true;
  final StorageService _storage = StorageService();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _loadCounter();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadCounter() async {
    final value = await _storage.loadCounter();
    setState(() {
      _counter = value;
      _isLoading = false;
    });
  }

  Future<void> _updateCounter(int delta) async {
    HapticFeedback.lightImpact();
    _pulseController.forward().then((_) => _pulseController.reverse());
    setState(() => _counter += delta);
    await _storage.saveCounter(_counter);
  }

  Future<void> _resetCounter() async {
    HapticFeedback.mediumImpact();
    setState(() => _counter = 0);
    await _storage.saveCounter(0);
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFE8FF47);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 48),
            Text(
              'Counter',
              style: GoogleFonts.spaceMono(
                fontSize: 13,
                letterSpacing: 4,
                color: const Color(0xFF555555),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Track\nanything.',
              style: GoogleFonts.dmSans(
                fontSize: 36,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFF5F5F5),
                height: 1.1,
              ),
            ),
            const SizedBox(height: 64),
            // Use Flexible + SingleChildScrollView to avoid overflow
            Flexible(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            decoration: BoxDecoration(
                              color: const Color(0xFF111111),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: const Color(0xFF2A2A2A),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                AnimatedBuilder(
                                  animation: _pulseAnimation,
                                  builder: (context, child) => Transform.scale(
                                    scale: _pulseAnimation.value,
                                    child: child,
                                  ),
                                  child: Text(
                                    '$_counter',
                                    style: GoogleFonts.spaceMono(
                                      fontSize: 96,
                                      fontWeight: FontWeight.w700,
                                      color: _counter == 0
                                          ? const Color(0xFF333333)
                                          : _counter > 0
                                          ? accent
                                          : const Color(0xFFFF6B6B),
                                      height: 1,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _counter == 0
                                      ? 'Start counting'
                                      : _counter > 0
                                      ? 'above zero'
                                      : 'below zero',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 13,
                                    color: const Color(0xFF444444),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          Row(
                            children: [
                              Expanded(
                                child: _CounterButton(
                                  label: '−',
                                  onTap: () => _updateCounter(-1),
                                  color: const Color(0xFF1C1C1C),
                                  textColor: const Color(0xFFFF6B6B),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _CounterButton(
                                  label: '+',
                                  onTap: () => _updateCounter(1),
                                  color: accent,
                                  textColor: const Color(0xFF0A0A0A),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: _resetCounter,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFF2A2A2A),
                                ),
                              ),
                              child: Text(
                                'Reset',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.dmSans(
                                  fontSize: 15,
                                  color: const Color(0xFF555555),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24), // extra bottom padding
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

class _CounterButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color color;
  final Color textColor;

  const _CounterButton({
    required this.label,
    required this.onTap,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.spaceMono(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: textColor,
            height: 1,
          ),
        ),
      ),
    );
  }
}
