import 'dart:math' as math;
import 'package:flutter/material.dart';

// ============================================================
// CREATE GROUP SCREEN
// ============================================================

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen>
    with TickerProviderStateMixin {
  late final AnimationController _glowController;
  late final AnimationController _starController;
  late final Animation<double> _glowAnimation;

  int _maxMembers = 2;
  final List<String> _members = [];
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocus = FocusNode();

  bool get _isFull => _members.length >= _maxMembers;

  @override
  void initState() {
    super.initState();
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
    _glowController.dispose();
    _starController.dispose();
    _nameController.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  // ── Logic ──────────────────────────────────────────────────

  void _addMember() {
    if (_isFull) return;
    final name = _nameController.text.trim();
    setState(() {
      _members.add(name.isEmpty ? 'Member ${_members.length + 1}' : name);
    });
    _nameController.clear();
    _nameFocus.requestFocus();
  }

  void _removeMember(int index) {
    setState(() => _members.removeAt(index));
  }

  void _onMaxChanged(int? newMax) {
    if (newMax == null) return;
    setState(() {
      _maxMembers = newMax;
      if (_members.length > newMax) {
        _members.removeRange(newMax, _members.length);
      }
    });
  }

  void _createGroup() {
    if (_members.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Add at least one member to create a group.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color(0xFFB04FC8),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Group of ${_members.length} created!',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF6C63FF),
        behavior: SnackBarBehavior.floating,
      ),
    );
    setState(() {
      _members.clear();
      _maxMembers = 2;
      _nameController.clear();
    });
  }

  // ── Build ──────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0A2E),
      body: Stack(
        children: [
          // ── Starfield ──────────────────────────────────────
          AnimatedBuilder(
            animation: _starController,
            builder: (_, __) => CustomPaint(
              size: MediaQuery.of(context).size,
              painter: _StarfieldPainter(_starController.value),
            ),
          ),

          // ── Bottom radial glow ─────────────────────────────
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
                          .withValues(alpha: 0.28 * _glowAnimation.value),
                      Colors.transparent,
                    ],
                    radius: 0.85,
                  ),
                ),
              ),
            ),
          ),

          // ── Content ────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 28),

                const Text(
                  'Create Your',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFB0A8D8),
                    fontSize: 17,
                    height: 1.5,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Group',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),

                const SizedBox(height: 20),

                // ── Glowing card ───────────────────────────────
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: AnimatedBuilder(
                      animation: _glowAnimation,
                      builder: (_, __) => Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF1E1550), Color(0xFF130D3A)],
                          ),
                          border: Border.all(
                            color: const Color(0xFF4A3FA8).withValues(alpha: 0.55),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF3EC6FF)
                                  .withValues(alpha: 0.20 * _glowAnimation.value),
                              blurRadius: 28,
                              spreadRadius: 2,
                            ),
                            BoxShadow(
                              color: const Color(0xFFFFD700)
                                  .withValues(alpha: 0.08 * _glowAnimation.value),
                              blurRadius: 40,
                              spreadRadius: -4,
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Icon
                              Center(
                                child: AnimatedBuilder(
                                  animation: _glowAnimation,
                                  builder: (_, __) => Container(
                                    width: 72,
                                    height: 72,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(0xFF1A1240),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFFFD700)
                                              .withValues(alpha: 
                                                  0.25 * _glowAnimation.value),
                                          blurRadius: 20,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.group_rounded,
                                      color: Color(0xFFFFD700),
                                      size: 34,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Dropdown label
                              const Text(
                                'Group Member Count',
                                style: TextStyle(
                                  color: Color(0xFFB0A8D8),
                                  fontSize: 13,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Dropdown
                              AnimatedBuilder(
                                animation: _glowAnimation,
                                builder: (_, __) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 2),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    color: const Color(0xFF1A1240),
                                    border: Border.all(
                                      color: const Color(0xFF5E35D1).withValues(alpha: 
                                          0.4 + 0.3 * _glowAnimation.value),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF7C5CFC)
                                            .withValues(alpha: 
                                                0.12 * _glowAnimation.value),
                                        blurRadius: 12,
                                      ),
                                    ],
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<int>(
                                      value: _maxMembers,
                                      dropdownColor: const Color(0xFF1A1240),
                                      iconEnabledColor: const Color(0xFFFFD700),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      isExpanded: true,
                                      items: List.generate(
                                        6,
                                        (i) => DropdownMenuItem(
                                          value: i + 1,
                                          child: Text(
                                              '${i + 1} ${i + 1 == 1 ? 'member' : 'members'}'),
                                        ),
                                      ),
                                      onChanged: _onMaxChanged,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Members label
                              const Text(
                                'Members',
                                style: TextStyle(
                                  color: Color(0xFFB0A8D8),
                                  fontSize: 13,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Add member row
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(14),
                                        color: const Color(0xFF1A1240),
                                        border: Border.all(
                                          color: const Color(0xFF4A3FA8)
                                              .withValues(alpha: _isFull ? 0.25 : 0.7),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: TextField(
                                        controller: _nameController,
                                        focusNode: _nameFocus,
                                        enabled: !_isFull,
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 14),
                                        decoration: InputDecoration(
                                          hintText: _isFull
                                              ? 'Group is full'
                                              : 'Enter member name…',
                                          hintStyle: TextStyle(
                                            color: const Color(0xFF7A6FC0)
                                                .withValues(alpha: 0.7),
                                            fontSize: 13,
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 14, vertical: 12),
                                          border: InputBorder.none,
                                        ),
                                        onSubmitted: (_) => _addMember(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  GestureDetector(
                                    onTap: _isFull ? null : _addMember,
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      width: 46,
                                      height: 46,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(14),
                                        gradient: _isFull
                                            ? null
                                            : const LinearGradient(colors: [
                                                Color(0xFF5535D1),
                                                Color(0xFFB04FC8),
                                              ]),
                                        color: _isFull
                                            ? const Color(0xFF1A1240)
                                            : null,
                                        border: Border.all(
                                          color: _isFull
                                              ? const Color(0xFF2E2560)
                                                  .withValues(alpha: 0.3)
                                              : const Color(0xFFFFD700)
                                                  .withValues(alpha: 0.4),
                                          width: 1.5,
                                        ),
                                        boxShadow: _isFull
                                            ? []
                                            : [
                                                BoxShadow(
                                                  color: const Color(0xFF7C5CFC)
                                                      .withValues(alpha: 0.4),
                                                  blurRadius: 12,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                      ),
                                      child: Icon(
                                        Icons.add_rounded,
                                        color: _isFull
                                            ? Colors.white.withValues(alpha: 0.2)
                                            : Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 6),

                              // Capacity counter
                              Text(
                                '${_members.length} / $_maxMembers members',
                                style: TextStyle(
                                  color: _isFull
                                      ? const Color(0xFFFFD700)
                                      : const Color(0xFF7A6FC0),
                                  fontSize: 12,
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Member list
                              Expanded(
                                child: _members.isEmpty
                                    ? Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.person_add_alt_1_outlined,
                                              color: const Color(0xFF4A3FA8)
                                                  .withValues(alpha: 0.6),
                                              size: 36,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'No members yet',
                                              style: TextStyle(
                                                color: const Color(0xFF7A6FC0)
                                                    .withValues(alpha: 0.7),
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : ListView.separated(
                                        itemCount: _members.length,
                                        separatorBuilder: (_, __) =>
                                            const SizedBox(height: 8),
                                        itemBuilder: (_, i) => _MemberTile(
                                          name: _members[i],
                                          index: i,
                                          onRemove: () => _removeMember(i),
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ── Create Group button ────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: GestureDetector(
                    onTap: _createGroup,
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
                          color: const Color(0xFFFFD700).withValues(alpha: 0.45),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF7C5CFC).withValues(alpha: 0.5),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.group_add_rounded,
                              color: Colors.white, size: 20),
                          SizedBox(width: 10),
                          Text(
                            'Create Group',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ── Home / back button(May remove this later) ─────────────────────────
                AnimatedBuilder(
                  animation: _glowAnimation,
                  builder: (_, __) => GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF2E1F7A),
                        border: Border.all(
                          color: const Color(0xFF5E35D1).withValues(alpha: 0.65),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF7C5CFC)
                                .withValues(alpha: 0.4 * _glowAnimation.value),
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

          // ── Sparkle corner ─────────────────────────────────
          const Positioned(
            right: 14,
            bottom: 14,
            child: _SparkleStar(),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// MEMBER TILE
// ============================================================

class _MemberTile extends StatelessWidget {
  const _MemberTile({
    required this.name,
    required this.index,
    required this.onRemove,
  });

  final String name;
  final int index;
  final VoidCallback onRemove;

  static const _colors = [
    Color(0xFF5535D1),
    Color(0xFFB04FC8),
    Color(0xFF3EC6FF),
    Color(0xFFFFD700),
    Color(0xFF4CAF50),
    Color(0xFFFF6B6B),
  ];

  @override
  Widget build(BuildContext context) {
    final color = _colors[index % _colors.length];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFF1A1240),
        border: Border.all(
          color: const Color(0xFF4A3FA8).withValues(alpha: 0.45),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.5)]),
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2E1F7A),
                border: Border.all(
                  color: const Color(0xFFB04FC8).withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Color(0xFFB0A8D8),
                size: 16,
              ),
            ),
          ),
        ],
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
      paint.color = Colors.white.withValues(alpha: opacity * 0.75);
      canvas.drawCircle(
          Offset(star.x * size.width, star.y * size.height),
          star.radius,
          paint);
    }
    paint.color = const Color(0xFFFFD700).withValues(alpha: 0.65);
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