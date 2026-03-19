import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/screen_bloc.dart';

// ── How to use ────────────────────────────────────────────────────────────────
//
// 1. Provide the BLoC ABOVE this screen in the widget tree (e.g. in your router
//    or parent widget), NOT inside ClassScreen itself:
//
//      BlocProvider(
//        create: (_) => ScreenBloc(),
//        child: const ClassScreen(),
//      )
//
// 2. Navigate to it normally:
//
//      Navigator.of(context).push(
//        MaterialPageRoute(
//          builder: (_) => BlocProvider(
//            create: (_) => ScreenBloc(),
//            child: const ClassScreen(),
//          ),
//        ),
//      );
//
// ─────────────────────────────────────────────────────────────────────────────

class ClassScreen extends StatefulWidget {
  const ClassScreen({super.key});

  @override
  State<ClassScreen> createState() => _ClassScreenState();
}

class _ClassScreenState extends State<ClassScreen>
    with TickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _glowController;
  late final Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.88);

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _glowController.dispose();
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
    // BlocConsumer only — BlocProvider must live above this widget
    return BlocConsumer<ScreenBloc, ScreenState>(
      // listenWhen ensures the snackbar fires exactly once per confirmation
      listenWhen: (previous, current) =>
          previous.status != current.status &&
          current.status == ScreenStatus.confirmed,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${state.selectedClassName} class selected!',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: const Color(0xFF6C63FF),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      },
      builder: (context, state) {
        final isFirst = state.currentPageIndex == 0;
        final isLast =
            state.currentPageIndex == state.availableClasses.length - 1;

        return Scaffold(
          backgroundColor: const Color(0xFF0D0A1E),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Choose your',
                            style: TextStyle(
                              color: Color(0xFFB0A8D8),
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Class',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      // Class count badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7C3AED),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${state.availableClasses.length} Classes',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // ── Page indicator dots ──────────────────────
                Padding(
                  padding: const EdgeInsets.only(left: 24),
                  child: Row(
                    children: List.generate(
                      state.availableClasses.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.only(right: 6),
                        width: i == state.currentPageIndex ? 20 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: i == state.currentPageIndex
                              ? const Color(0xFF7C3AED)
                              : const Color(0xFF2D2550),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ── Cards + arrows ───────────────────────────
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Left arrow
                      _NavArrow(
                        icon: Icons.chevron_left_rounded,
                        enabled: !isFirst,
                        onTap: isFirst
                            ? null
                            : () => _goToPage(
                                context, state.currentPageIndex - 1),
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
                            padding:
                                const EdgeInsets.symmetric(horizontal: 6),
                            child: _ClassCard(
                              skillClass: state.availableClasses[index],
                              isActive: index == state.currentPageIndex,
                              glowAnimation: _glowAnimation,
                            ),
                          ),
                        ),
                      ),

                      // Right arrow
                      _NavArrow(
                        icon: Icons.chevron_right_rounded,
                        enabled: !isLast,
                        onTap: isLast
                            ? null
                            : () => _goToPage(
                                context, state.currentPageIndex + 1),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Animated class name ──────────────────────
                Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.15),
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
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                // ── Subtitle ─────────────────────────────────
                Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    child: Text(
                      state.currentClass?.subtitle
                              .replaceAll('\n', ' ') ??
                          '',
                      key: ValueKey(state.currentClass?.subtitle),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFFB0A8D8)
                            .withValues(alpha: 0.8),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // ── Select Class button ──────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
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

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ============================================================
// CLASS CARD
// ============================================================

class _ClassCard extends StatelessWidget {
  const _ClassCard({
    required this.skillClass,
    required this.isActive,
    required this.glowAnimation,
  });

  final SkillClassModel skillClass;
  final bool isActive;
  final Animation<double> glowAnimation;

  Color get _accentColor {
    switch (skillClass.name) {
      case 'Warrior':
        return const Color(0xFFE05252);
      case 'Mage':
        return const Color(0xFF52B5E0);
      default: // Seeker
        return const Color(0xFF7C3AED);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: glowAnimation,
      builder: (_, __) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: const Color(0xFF160D2E),
            border: Border.all(
              color: isActive
                  ? _accentColor.withValues(
                      alpha: 0.5 + 0.3 * glowAnimation.value)
                  : const Color(0xFF2D2550),
              width: isActive ? 1.5 : 1,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: _accentColor.withValues(
                          alpha: 0.25 * glowAnimation.value),
                      blurRadius: 32,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon container
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: _accentColor.withValues(alpha: 0.15),
                    border: Border.all(
                      color: _accentColor.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: _accentColor.withValues(
                                  alpha: 0.3 * glowAnimation.value),
                              blurRadius: 16,
                              spreadRadius: 1,
                            ),
                          ]
                        : [],
                  ),
                  child: Icon(
                    skillClass.icon,
                    color: isActive
                        ? _accentColor
                        : _accentColor.withValues(alpha: 0.6),
                    size: 36,
                  ),
                ),

                const SizedBox(height: 28),

                // Perk chip
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _accentColor.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bolt_rounded,
                          color: _accentColor, size: 14),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          skillClass.perkLabel,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _accentColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Description
                Text(
                  skillClass.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFFB0A8D8)
                        .withValues(alpha: isActive ? 0.9 : 0.5),
                    fontSize: 13,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ============================================================
// NAV ARROW
// ============================================================

class _NavArrow extends StatelessWidget {
  const _NavArrow({
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: enabled
                ? const Color(0xFF2D2550)
                : const Color(0xFF160D2E),
            border: Border.all(
              color: enabled
                  ? const Color(0xFF7C3AED).withValues(alpha: 0.5)
                  : const Color(0xFF2D2550),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: enabled
                ? Colors.white
                : Colors.white.withValues(alpha: 0.15),
            size: 20,
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
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFF7C3AED),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline_rounded,
                color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text(
              'Select Class',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}