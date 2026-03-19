import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ============================================================
// DATA MODEL
// ============================================================

enum NodeState { locked, available, unlocked }

class SkillNode {
  final String id;
  final String label;
  final String description;
  final IconData icon;
  final int tier;
  final String branch;
  final int skillPoint;
  NodeState state;

  SkillNode({
    required this.id,
    required this.label,
    required this.description,
    required this.icon,
    required this.tier,
    required this.branch,
    required this.state,
    required this.skillPoint,
  });
}

// ============================================================
// SCREEN
// ============================================================

class SkillTreeScreen extends StatefulWidget {
  const SkillTreeScreen({super.key});

  @override
  State<SkillTreeScreen> createState() => _SkillTreeScreenState();
}

class _SkillTreeScreenState extends State<SkillTreeScreen>
    with SingleTickerProviderStateMixin {
  // ── API ────────────────────────────────────────────────────
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  // ── State ──────────────────────────────────────────────────
  int _skillPoints = 0;
  int _branchIndex = 0;
  bool isLoading = true;
  String? error;
  // add to state variables

  // Unlock thresholds
  static const int _t2need = 2;
  static const int _t3need = 2;

  // ── Branch metadata ────────────────────────────────────────
  final List<String> _branches = ['seeker', 'trailblazer', 'wanderer', 'prime'];

  static const Map<String, Color> _color = {
    'seeker': Color(0xFF7C3AED),
    'trailblazer': Color(0xFFE05252),
    'wanderer': Color(0xFF52B5E0),
    'prime': Color(0xFF4CAF50),
  };

  static const Map<String, IconData> _branchIcon = {
    'seeker': Icons.search_rounded,
    'trailblazer': Icons.directions_run_rounded,
    'wanderer': Icons.explore_rounded,
    'prime': Icons.storefront_rounded,
  };

  static const Map<String, String> _branchName = {
    'seeker': 'Seeker',
    'trailblazer': 'Trailblazer',
    'wanderer': 'Wanderer',
    'prime': 'Prime',
  };

  // ── Icon mapping from string names ──────────────────────────
  static const Map<String, IconData> _iconMap = {
    'visibility_rounded': Icons.visibility_rounded,
    'auto_awesome_rounded': Icons.auto_awesome_rounded,
    'lock_rounded': Icons.lock_rounded,
    'timer_rounded': Icons.timer_rounded,
    'directions_run_rounded': Icons.directions_run_rounded,
    'skip_next_rounded': Icons.skip_next_rounded,
    'add_circle_rounded': Icons.add_circle_rounded,
    'explore_rounded': Icons.explore_rounded,
    'storefront_rounded': Icons.storefront_rounded,
    'search_rounded': Icons.search_rounded,
    'shield_outlined': Icons.shield_outlined,
    'auto_fix_high_rounded': Icons.auto_fix_high_rounded,
    'flash_on_rounded': Icons.flash_on_rounded,
    'map_rounded': Icons.map_rounded,
    'timeline_rounded': Icons.timeline_rounded,
    'layers_rounded': Icons.layers_rounded,
    'diamond_rounded': Icons.diamond_rounded,
    'public_rounded': Icons.public_rounded,
    'sports_mma_rounded': Icons.sports_mma_rounded,
    'backpack_rounded': Icons.backpack_rounded,
    'military_tech_rounded': Icons.military_tech_rounded,
    'health_and_safety_rounded': Icons.health_and_safety_rounded,
    'campaign_rounded': Icons.campaign_rounded,
    'local_fire_department_rounded': Icons.local_fire_department_rounded,
    'emoji_events_rounded': Icons.emoji_events_rounded,
    'menu_book_rounded': Icons.menu_book_rounded,
    'psychology_rounded': Icons.psychology_rounded,
    'flare_rounded': Icons.flare_rounded,
    'remove_red_eye_rounded': Icons.remove_red_eye_rounded,
    'stars_rounded': Icons.stars_rounded,
    'lightbulb_rounded': Icons.lightbulb_rounded,
    'inventory_rounded': Icons.inventory_rounded,
    'alarm_rounded': Icons.alarm_rounded,
    'touch_app_rounded': Icons.touch_app_rounded,
    'visibility_off_rounded': Icons.visibility_off_rounded,
    'nights_stay_rounded': Icons.nights_stay_rounded,
    'blur_on_rounded': Icons.blur_on_rounded,
  };

  IconData _stringToIcon(String iconName) {
    return _iconMap[iconName] ?? Icons.question_mark_rounded;
  }

  // ── Branch slide animation ─────────────────────────────────
  late final AnimationController _slideCtrl;
  late Animation<Offset> _slideAnim;

  // ── Nodes ──────────────────────────────────────────────────
  late List<SkillNode> _nodes;

  @override
  void initState() {
    super.initState();
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnim = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(_slideCtrl);
    _nodes = [];
    _loadSkillPoints();
    _loadSkills();
  }

  // load SP from Firestore
  Future<void> _loadSkillPoints() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    setState(() {
      _skillPoints = (doc.data()?['skillPoints'] ?? 0) as int;
    });
  }

  Future<void> _loadSkills() async {
    try {
      // get Firebase token for auth
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();

      final response = await http.get(
        Uri.parse('$baseUrl/skills'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        // get user's unlocked skills from backend
        final unlockedResponse = await http.get(
          Uri.parse('$baseUrl/user-skills/my-skills'),
          headers: {'Authorization': 'Bearer $token'},
        );
        final List<dynamic> unlockedData = unlockedResponse.statusCode == 200
            ? jsonDecode(unlockedResponse.body)
            : [];
        final unlockedIds = unlockedData
            .map((us) => us['skillId']?['_id']?.toString() ?? '')
            .toSet();

        final loadedNodes = data.map((skill) {
          final isUnlocked = unlockedIds.contains(skill['_id'].toString());
          return SkillNode(
            id: skill['_id'].toString(),
            label: skill['label'] ?? skill['name'] ?? '',
            description: skill['description'] ?? '',
            icon: _stringToIcon(skill['icon'] ?? 'stars_rounded'),
            tier: skill['tier'] ?? 1,
            branch: skill['branch'] ?? 'seeker',
            skillPoint: skill['skillPoint'] ?? 2,
            state: isUnlocked ? NodeState.unlocked : NodeState.locked,
          );
        }).toList();

        setState(() {
          _nodes = loadedNodes;
          isLoading = false;
        });
        _recalc();
      } else {
        setState(() {
          error = 'Failed to load skills: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading skills: $e');
      setState(() {
        error = 'Connection error: $e';
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _slideCtrl.dispose();
    super.dispose();
  }

  // ── Logic ──────────────────────────────────────────────────

  int _countUnlocked(String branch, int tier) => _nodes
      .where(
        (n) =>
            n.branch == branch &&
            n.tier == tier &&
            n.state == NodeState.unlocked,
      )
      .length;

  void _recalc() {
    for (final n in _nodes) {
      if (n.state == NodeState.unlocked) continue;
      if (n.tier == 2) {
        n.state = _countUnlocked(n.branch, 1) >= _t2need
            ? NodeState.available
            : NodeState.locked;
      } else if (n.tier == 3) {
        n.state = _countUnlocked(n.branch, 2) >= _t3need
            ? NodeState.available
            : NodeState.locked;
      }
    }
  }

  void _switchBranch(int direction) {
    _slideCtrl.reset();
    _slideAnim = Tween<Offset>(
      begin: Offset(direction > 0 ? 0.15 : -0.15, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut));
    setState(() {
      _branchIndex =
          (_branchIndex + direction + _branches.length) % _branches.length;
    });
    _slideCtrl.forward();
  }

  void _onNodeTap(SkillNode node) async {
    if (node.state == NodeState.unlocked) {
      _showInfo(node);
      return;
    }
    if (node.state == NodeState.locked) {
      final req = node.tier == 2
          ? 'Unlock $_t2need Tier 1 skills first'
          : 'Unlock $_t3need Tier 2 skills first';
      _snack(req, const Color(0xFF160D2E));
      return;
    }
    if (_skillPoints < node.skillPoint) {
      _snack(
        'Need ${node.skillPoint} SP. You have $_skillPoints SP.',
        const Color(0xFF2D2550),
      );
      return;
    }

    // call backend to unlock
    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
      final response = await http.post(
        Uri.parse('$baseUrl/user-skills/${node.id}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'skillId': node.id}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = jsonDecode(response.body);
        setState(() {
          node.state = NodeState.unlocked;
          _skillPoints =
              result['remainingSP'] ?? _skillPoints - node.skillPoint;
          _recalc();
        });
        _snack(
          '${node.label} unlocked!',
          _color[node.branch]!,
          duration: const Duration(seconds: 1),
        );
      } else {
        final result = jsonDecode(response.body);
        _snack(
          result['message'] ?? 'Failed to unlock',
          const Color(0xFF2D2550),
        );
      }
    } catch (e) {
      _snack('Connection error', const Color(0xFF2D2550));
    }
  }

  void _snack(
    String msg,
    Color bg, {
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white)),
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showInfo(SkillNode node) {
    final c = _color[node.branch]!;
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 48),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF120A2E),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: c.withValues(alpha: 0.4), width: 1.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: c.withValues(alpha: 0.15),
                  border: Border.all(
                    color: c.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: Icon(node.icon, color: c, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                node.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tier ${node.tier}',
                style: TextStyle(
                  color: c,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                node.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFB0A8D8),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: double.infinity,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D2550),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      color: Color(0xFFB0A8D8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0D0A1E),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF7C3AED)),
        ),
      );
    }

    if (error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0D0A1E),
        body: Center(
          child: Text(error!, style: const TextStyle(color: Colors.white)),
        ),
      );
    }

    final branch = _branches[_branchIndex];
    final c = _color[branch]!;
    final bName = _branchName[branch]!;
    final bIcon = _branchIcon[branch]!;

    final t1 = _nodes.where((n) => n.branch == branch && n.tier == 1).toList();
    final t2 = _nodes.where((n) => n.branch == branch && n.tier == 2).toList();
    final t3 = _nodes.where((n) => n.branch == branch && n.tier == 3).toList();

    final t1u = _countUnlocked(branch, 1);
    final t2u = _countUnlocked(branch, 2);
    final tier2Open = t1u >= _t2need;
    final tier3Open = t2u >= _t3need;

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
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Skill Tree',
                        style: TextStyle(
                          color: Color(0xFFB0A8D8),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Your Skills',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  // SP badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF160D2E),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF7C3AED).withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.stars_rounded,
                          color: Color(0xFF7C3AED),
                          size: 15,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '$_skillPoints SP',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Branch switcher ──────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _ArrowBtn(
                    icon: Icons.chevron_left_rounded,
                    onTap: () => _switchBranch(-1),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: c.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: c.withValues(alpha: 0.35),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(bIcon, color: c, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            bName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _ArrowBtn(
                    icon: Icons.chevron_right_rounded,
                    onTap: () => _switchBranch(1),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Branch indicator dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_branches.length, (i) {
                final dc = _color[_branches[i]]!;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: i == _branchIndex ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: i == _branchIndex ? dc : const Color(0xFF2D2550),
                  ),
                );
              }),
            ),

            const SizedBox(height: 20),

            // ── Skill tree ───────────────────────────────
            Expanded(
              child: SlideTransition(
                position: _slideAnim,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // Tier 1
                      _TierHeader(
                        label: 'Tier 1',
                        color: c,
                        subtitle: 'Available from the start',
                      ),
                      const SizedBox(height: 12),
                      _NodeRow(nodes: t1, color: c, onTap: _onNodeTap),

                      // Connector T1 → T2
                      _TreeConnector(
                        unlocked: tier2Open,
                        color: c,
                        label: tier2Open ? null : '$t1u/$_t2need unlocked',
                      ),

                      // Tier 2
                      _TierHeader(
                        label: 'Tier 2',
                        color: tier2Open ? c : const Color(0xFF2D2550),
                        subtitle: tier2Open
                            ? 'Unlocked'
                            : 'Unlock $_t2need Tier 1 skills',
                        locked: !tier2Open,
                      ),
                      const SizedBox(height: 12),
                      _NodeRow(nodes: t2, color: c, onTap: _onNodeTap),

                      // Connector T2 → T3
                      _TreeConnector(
                        unlocked: tier3Open,
                        color: c,
                        label: tier3Open ? null : '$t2u/$_t3need unlocked',
                      ),

                      // Tier 3
                      _TierHeader(
                        label: 'Tier 3',
                        color: tier3Open ? c : const Color(0xFF2D2550),
                        subtitle: tier3Open
                            ? 'Unlocked'
                            : 'Unlock $_t3need Tier 2 skills',
                        locked: !tier3Open,
                      ),
                      const SizedBox(height: 12),
                      _NodeRow(nodes: t3, color: c, onTap: _onNodeTap),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// TREE CONNECTOR
// ============================================================

class _TreeConnector extends StatelessWidget {
  const _TreeConnector({
    required this.unlocked,
    required this.color,
    this.label,
  });

  final bool unlocked;
  final Color color;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            width: 2,
            height: 20,
            color: unlocked
                ? color.withValues(alpha: 0.6)
                : const Color(0xFF1A1230),
          ),
          if (label != null) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF160D2E),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF2D2550), width: 1),
              ),
              child: Text(
                label!,
                style: const TextStyle(
                  color: Color(0xFFB0A8D8),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 4),
          ],
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            width: 2,
            height: 20,
            color: unlocked
                ? color.withValues(alpha: 0.6)
                : const Color(0xFF1A1230),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// TIER HEADER
// ============================================================

class _TierHeader extends StatelessWidget {
  const _TierHeader({
    required this.label,
    required this.color,
    required this.subtitle,
    this.locked = false,
  });

  final String label;
  final Color color;
  final String subtitle;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(height: 1, color: color.withValues(alpha: 0.2)),
        ),
        const SizedBox(width: 12),
        Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (locked)
                  Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: Icon(Icons.lock_rounded, color: color, size: 12),
                  ),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            Text(
              subtitle,
              style: TextStyle(
                color: color.withValues(alpha: 0.6),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(height: 1, color: color.withValues(alpha: 0.2)),
        ),
      ],
    );
  }
}

// ============================================================
// NODE ROW
// ============================================================

class _NodeRow extends StatelessWidget {
  const _NodeRow({
    required this.nodes,
    required this.color,
    required this.onTap,
  });

  final List<SkillNode> nodes;
  final Color color;
  final void Function(SkillNode) onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (nodes.length > 1)
          CustomPaint(
            size: const Size(double.infinity, 16),
            painter: _HLinePainter(count: nodes.length, color: color),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: nodes
              .map(
                (n) =>
                    _NodeBubble(node: n, color: color, onTap: () => onTap(n)),
              )
              .toList(),
        ),
      ],
    );
  }
}

// ============================================================
// NODE BUBBLE
// ============================================================

class _NodeBubble extends StatelessWidget {
  const _NodeBubble({
    required this.node,
    required this.color,
    required this.onTap,
  });

  final SkillNode node;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final unlocked = node.state == NodeState.unlocked;
    final available = node.state == NodeState.available;
    final locked = node.state == NodeState.locked;
    final nc = locked ? const Color(0xFF2D2550) : color;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: unlocked
                  ? nc.withValues(alpha: 0.18)
                  : available
                  ? const Color(0xFF160D2E)
                  : const Color(0xFF0F0920),
              border: Border.all(
                color: unlocked
                    ? nc
                    : available
                    ? nc.withValues(alpha: 0.35)
                    : const Color(0xFF1A1230),
                width: unlocked ? 2.5 : 1.5,
              ),
              boxShadow: unlocked
                  ? [
                      BoxShadow(
                        color: nc.withValues(alpha: 0.3),
                        blurRadius: 16,
                        spreadRadius: 1,
                      ),
                    ]
                  : [],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  locked ? Icons.lock_rounded : node.icon,
                  color: unlocked
                      ? nc
                      : available
                      ? nc.withValues(alpha: 0.5)
                      : const Color(0xFF2D2550),
                  size: unlocked ? 22 : 20,
                ),
                if (unlocked) ...[
                  const SizedBox(height: 2),
                  Icon(Icons.check_rounded, color: nc, size: 10),
                ],
              ],
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 72,
            child: Text(
              node.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: TextStyle(
                color: unlocked
                    ? Colors.white
                    : available
                    ? const Color(0xFFB0A8D8)
                    : const Color(0xFF2D2550),
                fontSize: 10,
                fontWeight: unlocked ? FontWeight.w700 : FontWeight.w500,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// HORIZONTAL LINE PAINTER
// ============================================================

class _HLinePainter extends CustomPainter {
  const _HLinePainter({required this.count, required this.color});

  final int count;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (count < 2) return;
    final paint = Paint()
      ..color = color.withValues(alpha: 0.25)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final spacing = size.width / count;
    final y = size.height / 2;
    final firstX = spacing / 2;
    final lastX = spacing * (count - 0.5);

    canvas.drawLine(Offset(firstX, y), Offset(lastX, y), paint);

    for (int i = 0; i < count; i++) {
      final x = spacing * (i + 0.5);
      canvas.drawLine(Offset(x, y), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(_HLinePainter old) =>
      old.count != count || old.color != color;
}

// ============================================================
// ARROW BUTTON
// ============================================================

class _ArrowBtn extends StatelessWidget {
  const _ArrowBtn({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF160D2E),
          border: Border.all(color: const Color(0xFF2D2550), width: 1),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}
