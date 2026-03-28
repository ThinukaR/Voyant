import 'package:flutter/material.dart';
import 'package:voyant/widgets/animated_gradient_background.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  // ── State ──────────────────────────────────────────────────
  int _maxMembers = 2;
  final List<String> _members = [];
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocus = FocusNode();

  bool get _isFull => _members.length >= _maxMembers;

  @override
  void dispose() {
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
        SnackBar(
          content: const Text(
            'Add at least one member to create a group.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF7C3AED),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
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
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
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
      backgroundColor: Colors.transparent,
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Create your',
                        style: TextStyle(
                          color: Color(0xFFB0A8D8),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Group',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  // Live member count badge — rebuilds with setState
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C3AED),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_members.length} / $_maxMembers',
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

            // ── Scrollable content ───────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Info card ──────────────────────────
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF160D2E),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF2D2550),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: const Color(0xFF7C3AED)
                                  .withValues(alpha: 0.15),
                              border: Border.all(
                                color: const Color(0xFF7C3AED)
                                    .withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                            ),
                            child: const Icon(
                              Icons.group_rounded,
                              color: Color(0xFF7C3AED),
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'New Group',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 3),
                                Text(
                                  'Add members and set your group size',
                                  style: TextStyle(
                                    color: Color(0xFFB0A8D8),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Group Size ─────────────────────────
                    const Text(
                      'Group Size',
                      style: TextStyle(
                        color: Color(0xFFB0A8D8),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF160D2E),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFF2D2550),
                          width: 1,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _maxMembers,
                          dropdownColor: const Color(0xFF160D2E),
                          iconEnabledColor: const Color(0xFF7C3AED),
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

                    const SizedBox(height: 24),

                    // ── Members label + status pill ─────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Members',
                          style: TextStyle(
                            color: Color(0xFFB0A8D8),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.3,
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: _isFull
                                ? const Color(0xFF7C3AED)
                                    .withValues(alpha: 0.2)
                                : const Color(0xFF2D2550),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _isFull ? 'Full' : '${_members.length} added',
                            style: TextStyle(
                              color: _isFull
                                  ? const Color(0xFF7C3AED)
                                  : const Color(0xFFB0A8D8),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // ── Add member row ─────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF160D2E),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: _isFull
                                    ? const Color(0xFF2D2550)
                                    : const Color(0xFF7C3AED)
                                        .withValues(alpha: 0.4),
                                width: 1,
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
                                  color: const Color(0xFFB0A8D8)
                                      .withValues(alpha: 0.5),
                                  fontSize: 13,
                                ),
                                prefixIcon: Icon(
                                  Icons.person_outline_rounded,
                                  color: _isFull
                                      ? const Color(0xFF2D2550)
                                      : const Color(0xFF7C3AED),
                                  size: 20,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 14),
                                border: InputBorder.none,
                              ),
                              onSubmitted: (_) => _addMember(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Add button
                        GestureDetector(
                          onTap: _isFull ? null : _addMember,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: _isFull
                                  ? const Color(0xFF160D2E)
                                  : const Color(0xFF7C3AED),
                              border: Border.all(
                                color: _isFull
                                    ? const Color(0xFF2D2550)
                                    : const Color(0xFF7C3AED),
                                width: 1,
                              ),
                              boxShadow: _isFull
                                  ? []
                                  : [
                                      BoxShadow(
                                        color: const Color(0xFF7C3AED)
                                            .withValues(alpha: 0.35),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                            ),
                            child: Icon(
                              Icons.add_rounded,
                              color: _isFull
                                  ? const Color(0xFF2D2550)
                                  : Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ── Member list ────────────────────────
                    if (_members.isEmpty)
                      Container(
                        height: 110,
                        decoration: BoxDecoration(
                          color: const Color(0xFF160D2E),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF2D2550),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.person_add_alt_1_outlined,
                                color: Color(0xFF2D2550),
                                size: 30,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'No members yet',
                                style: TextStyle(
                                  color: Color(0xFF2D2550),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _members.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 8),
                        itemBuilder: (_, i) => _MemberTile(
                          name: _members[i],
                          index: i,
                          onRemove: () => _removeMember(i),
                        ),
                      ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // ── Create Group button ──────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: GestureDetector(
                onTap: _createGroup,
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
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
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
    Color(0xFF7C3AED),
    Color(0xFFE05252),
    Color(0xFF52B5E0),
    Color(0xFF4CAF50),
    Color(0xFFFFB74D),
    Color(0xFFEC407A),
  ];

  @override
  Widget build(BuildContext context) {
    final color = _colors[index % _colors.length];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF160D2E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF2D2550),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: color.withValues(alpha: 0.15),
              border: Border.all(
                color: color.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
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

          // Remove button
          GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: const Color(0xFF2D2550),
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