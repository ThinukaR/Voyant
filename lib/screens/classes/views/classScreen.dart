import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/screen_bloc.dart';

class ClassScreen extends StatefulWidget {
  const ClassScreen({super.key});

  @override
  State<ClassScreen> createState() => _ClassScreenState();
}

class _ClassScreenState extends State<ClassScreen>
    with TickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _glowController;
  late final AnimationController _starController;
  late final Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _starController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _glowAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _glowController.dispose();
    _starController.dispose();
    super.dispose();
  }

  void _goToPage(BuildContext context, int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
    context.read<ScreenBloc>().add(ScreenPageChanged(index));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ScreenBloc(),
      child: BlocConsumer<ScreenBloc, ScreenState>(
        listener: (context, state) {
          if (state.status == ScreenStatus.confirmed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${state.selectedClassName} class selected!',
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: const Color(0xFF6C63FF),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          final isFirst = state.currentPageIndex == 0;
          final isLast =
              state.currentPageIndex == state.availableClasses.length - 1;

          return Scaffold(
            backgroundColor: const Color(0xFF0D0A2E),
            body: Stack(
              children: [
                // ── Animated starfield ──────────────────────────
                AnimatedBuilder(
                  animation: _starController,
                  builder: (_, __) => CustomPaint(
                    size: MediaQuery.of(context).size,
                    painter: _StarfieldPainter(_starController.value),
                  ),
                ),

                // ── Bottom radial glow ───────────────────────────
                Positioned(
                  bottom: -80,
                  left: 0,
                  right: 0,
                  child: AnimatedBuilder(
                    animation: _glowAnimation,
                    builder: (_, __) => Container(
                      height: 320,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF5E35D1)
                                .withOpacity(0.30 * _glowAnimation.value),
                            Colors.transparent,
                          ],
                          radius: 0.85,
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Main content ─────────────────────────────────
                SafeArea(
                  child: Column(
                    children: [
                      const SizedBox(height: 32),

                      // "Select Your Class" label
                      const Text(
                        'Select Your\nClass',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFFB0A8D8),
                          fontSize: 17,
                          height: 1.5,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Animated class name swap
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 280),
                        transitionBuilder: (child, anim) => FadeTransition(
                          opacity: anim,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.2),
                              end: Offset.zero,
                            ).animate(anim),
                            child: child,
                          ),
                        ),
                        child: Text(
                          state.currentClass?.name ?? '',
                          key: ValueKey(state.currentClass?.name),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Page indicator dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          state.availableClasses.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: i == state.currentPageIndex ? 18 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              color: i == state.currentPageIndex
                                  ? const Color(0xFFFFD700)
                                  : const Color(0xFF4A3FA8),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── Card + side arrows ──────────────────────
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Left arrow
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: _ArrowButton(
                                icon: Icons.chevron_left_rounded,
                                enabled: !isFirst,
                                onTap: isFirst
                                    ? null
                                    : () => _goToPage(
                                        context, state.currentPageIndex - 1),
                              ),
                            ),

                            // PageView
                            Expanded(
                              child: PageView.builder(
                                controller: _pageController,
                                itemCount: state.availableClasses.length,
                                onPageChanged: (i) => context
                                    .read<ScreenBloc>()
                                    .add(ScreenPageChanged(i)),
                                itemBuilder: (context, index) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6),
                                  child: _GlowingClassCard(
                                    skillClass: state.availableClasses[index],
                                    glowAnimation: _glowAnimation,
                                  ),
                                ),
                              ),
                            ),

                            // Right arrow
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: _ArrowButton(
                                icon: Icons.chevron_right_rounded,
                                enabled: !isLast,
                                onTap: isLast
                                    ? null
                                    : () => _goToPage(
                                        context, state.currentPageIndex + 1),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Select Class button ─────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: _SelectClassButton(
                          onTap: () {
                            final current = state.currentClass;
                            if (current != null) {
                              context.read<ScreenBloc>()
                                ..add(ScreenClassSelected(current.name))
                                ..add(const ScreenSelectionConfirmed());
                            }
                          },
                        ),
                      ),

                      const SizedBox(height: 22),

                      // ── Home / back button ──────────────────────
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: AnimatedBuilder(
                          animation: _glowAnimation,
                          builder: (_, __) => Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF2E1F7A),
                              border: Border.all(
                                color: const Color(0xFF5E35D1).withOpacity(0.65),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF7C5CFC).withOpacity(
                                      0.4 * _glowAnimation.value),
                                  blurRadius: 18,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.home_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 22),
                    ],
                  ),
                ),

                // ── Bottom-right sparkle ─────────────────────────
                const Positioned(
                  right: 14,
                  bottom: 14,
                  child: _SparkleStar(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// ARROW BUTTON
// ============================================================

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: enabled ? const Color(0xFF2E1F7A) : const Color(0xFF16103A),
          border: Border.all(
            color: enabled
                ? const Color(0xFF5E35D1).withOpacity(0.7)
                : const Color(0xFF2E2560).withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: const Color(0xFF7C5CFC).withOpacity(0.35),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: Icon(
          icon,
          color: enabled ? Colors.white : Colors.white.withOpacity(0.18),
          size: 24,
        ),
      ),
    );
  }
}

// ============================================================
// GLOWING CLASS CARD
// ============================================================

class _GlowingClassCard extends StatelessWidget {
  const _GlowingClassCard({
    required this.skillClass,
    required this.glowAnimation,
  });

  final SkillClassModel skillClass;
  final Animation<double> glowAnimation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: glowAnimation,
      builder: (_, __) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E1550), Color(0xFF130D3A)],
          ),
          border: Border.all(
            color: const Color(0xFF4A3FA8).withOpacity(0.55),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  const Color(0xFF3EC6FF).withOpacity(0.22 * glowAnimation.value),
              blurRadius: 28,
              spreadRadius: 2,
            ),
            BoxShadow(
              color:
                  const Color(0xFFFFD700).withOpacity(0.10 * glowAnimation.value),
              blurRadius: 40,
              spreadRadius: -4,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon circle
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1A1240),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700)
                          .withOpacity(0.28 * glowAnimation.value),
                      blurRadius: 22,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: Icon(skillClass.icon,
                    color: const Color(0xFFFFD700), size: 40),
              ),

              const SizedBox(height: 26),

              // Subtitle
              Text(
                skillClass.subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16.5,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 16),

              // Perk row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '+  ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      skillClass.perkLabel,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Description
              Text(
                skillClass.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFB0A8D8),
                  fontSize: 13.5,
                  height: 1.65,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// SELECT CLASS BUTTON
// ============================================================

class _SelectClassButton extends StatelessWidget {
  const _SelectClassButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: const LinearGradient(
            colors: [Color(0xFF5535D1), Color(0xFFB04FC8)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          border: Border.all(
            color: const Color(0xFFFFD700).withOpacity(0.45),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C5CFC).withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: const Text(
          'Select Class',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// SPARKLE STAR
// ============================================================

class _SparkleStar extends StatelessWidget {
  const _SparkleStar();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size(22, 22), painter: _SparklePainter());
  }
}

class _SparklePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final path = Path();
    for (int i = 0; i < 8; i++) {
      final angle = i * math.pi / 4 - math.pi / 2;
      final r = i.isEven ? size.width / 2 : size.width / 5;
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ============================================================
// STARFIELD PAINTER
// ============================================================

class _StarfieldPainter extends CustomPainter {
  final double progress;

  static final List<_Star> _stars = List.generate(60, (_) {
    final rng = math.Random();
    return _Star(
      x: rng.nextDouble(),
      y: rng.nextDouble(),
      radius: rng.nextDouble() * 1.4 + 0.3,
      phase: rng.nextDouble(),
    );
  });

  const _StarfieldPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final star in _stars) {
      final opacity =
          (0.3 + 0.7 * math.sin((progress + star.phase) * 2 * math.pi))
              .clamp(0.0, 1.0);
      paint.color = Colors.white.withOpacity(opacity * 0.75);
      canvas.drawCircle(
          Offset(star.x * size.width, star.y * size.height), star.radius, paint);
    }
    paint.color = const Color(0xFFFFD700).withOpacity(0.65);
    for (final pos in const [
      Offset(0.08, 0.10),
      Offset(0.88, 0.16),
      Offset(0.14, 0.52),
      Offset(0.82, 0.44),
      Offset(0.50, 0.06),
      Offset(0.35, 0.90),
      Offset(0.70, 0.88),
    ]) {
      canvas.drawCircle(
          Offset(pos.dx * size.width, pos.dy * size.height), 2.2, paint);
    }
  }

  @override
  bool shouldRepaint(_StarfieldPainter old) => old.progress != progress;
}

class _Star {
  final double x, y, radius, phase;
  const _Star(
      {required this.x,
      required this.y,
      required this.radius,
      required this.phase});
}