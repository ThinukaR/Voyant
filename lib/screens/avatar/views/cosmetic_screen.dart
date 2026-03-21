import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:voyant/widgets/animated_gradient_background.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CosmeticScreen extends StatefulWidget {
  const CosmeticScreen({super.key});

  @override
  State<CosmeticScreen> createState() => _CosmeticScreenState();
}

class _CosmeticScreenState extends State<CosmeticScreen> {
  static const String baseUrl = 'http://192.168.8.148:3000/api';

  Map<String, dynamic>? avatar;
  List<dynamic> allItems = [];
  String selectedCategory = 'hair';
  bool isLoading = true;

  final List<String> categories = ['hair', 'hat', 'shirt', 'pants', 'shoes'];
  final Map<String, IconData> categoryIcons = {
    'hair': Icons.face,
    'hat': Icons.sports_baseball,
    'shirt': Icons.checkroom,
    'pants': Icons.accessibility_new,
    'shoes': Icons.directions_walk,
  };

  @override
  void initState() {
    super.initState();
    _loadAvatar();
  }

  Future<String?> _getToken() async {
    return await FirebaseAuth.instance.currentUser?.getIdToken();
  }

  Future<void> _loadAvatar() async {
    try {
      final token = await _getToken();
      final headers = {'Authorization': 'Bearer $token'};

      final avatarRes = await http.get(
        Uri.parse('$baseUrl/cosmetics'),
        headers: headers,
      );
      final itemsRes = await http.get(
        Uri.parse('$baseUrl/cosmetics/items'),
        headers: headers,
      );

      if (mounted) {
        if (avatarRes.statusCode == 200 && itemsRes.statusCode == 200) {
          setState(() {
            avatar = jsonDecode(avatarRes.body);
            allItems = jsonDecode(itemsRes.body);
          });
        } else {
          debugPrint(
              'Failed to load cosmetics data: ${avatarRes.statusCode}, ${itemsRes.statusCode}');
        }
      }
    } catch (e) {
      debugPrint('Error loading avatar: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _equipItem(String itemId) async {
    debugPrint('Equipping item: $itemId');
    try {
      final token = await _getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/cosmetics/equip/$itemId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      debugPrint('Equip status: ${response.statusCode}'); // ← add
      debugPrint('Equip body: ${response.body}');

      if (response.statusCode == 200) {
        await _loadAvatar();
      }
    } catch (e) {
      debugPrint('Equip error: $e');
    }
  }

  // get equipped color for a category
  String? _getEquippedColor(String category) {
    final equipped = avatar?['equipped'];
    if (equipped == null) return null;
    final item = equipped[category];
    if (item == null) return null;
    return item['color'];
  }

  Future<void> _unlockItem(Map<String, dynamic> item) async {
    final xpCost = item['xpCost'] ?? 0;

    // get user's current XP from Firestore
    final user = FirebaseAuth.instance.currentUser;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .get();
    final currentXP = doc.data()?['totalXP'] ?? 0;

    // show confirmation dialog
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A0A2E),
        title: Text(item['name'], style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Color(
                  int.parse(item['color'].replaceFirst('#', '0xFF')),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Unlock for $xpCost XP?',
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Your XP: $currentXP',
              style: TextStyle(
                color: currentXP >= xpCost ? Colors.green : Colors.red,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (currentXP < xpCost)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Need ${xpCost - currentXP} more XP',
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          if (currentXP >= xpCost)
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _confirmUnlock(item, xpCost, currentXP);
              },
              child: const Text(
                'Unlock',
                style: TextStyle(
                  color: Color(0xFFB020DD),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _confirmUnlock(
    Map<String, dynamic> item,
    int xpCost,
    int currentXP,
  ) async {
    try {
      // deduct XP from Firestore
      final user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .update({'totalXP': currentXP - xpCost});

      // call backend to add item to owned items
      final token = await _getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/cosmetics/unlock/${item['_id']}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${item['name']} unlocked!'),
              backgroundColor: Colors.green,
            ),
          );
        }
        await _loadAvatar();
      }
    } catch (e) {
      debugPrint('Unlock error: $e');
    }
  }

  String? _getEquippedId(String category) {
    final equipped = avatar?['equipped'];
    if (equipped == null) return null;
    final item = equipped[category];
    if (item == null) return null;
    return item['_id'];
  }

  List<dynamic> get _categoryItems =>
      allItems.where((i) => i['category'] == selectedCategory).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFFB020DD)),
                )
              : Column(
                  children: [
                    // header
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(
                              Icons.arrow_back_ios,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Avatar',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // character display
                    _buildCharacter(),

                    const SizedBox(height: 16),

                    // category selector
                    _buildCategorySelector(),

                    const SizedBox(height: 12),

                    // items for selected category
                    Expanded(child: _buildItemsGrid()),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildCharacter() {
    final skinColor = Color(
      int.parse((avatar?['skinColor'] ?? '#F5CBA7').replaceFirst('#', '0xFF')),
    );
    final hairColor = _getEquippedColor('hair');
    final hatColor = _getEquippedColor('hat');
    final shirtColor = _getEquippedColor('shirt');
    final pantsColor = _getEquippedColor('pants');
    final shoesColor = _getEquippedColor('shoes');

    return Container(
      height: 220,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFB020DD).withOpacity(0.3)),
      ),
      child: Center(
        child: SizedBox(
          width: 120,
          height: 200,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              // HAIR (behind head)
              if (hairColor != null && hairColor != 'transparent')
                Positioned(
                  top: 0,
                  child: Container(
                    width: 60,
                    height: 35,
                    decoration: BoxDecoration(
                      color: Color(
                        int.parse(hairColor.replaceFirst('#', '0xFF')),
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                  ),
                ),

              // HEAD
              Positioned(
                top: 10,
                child: Container(
                  width: 56,
                  height: 60,
                  decoration: BoxDecoration(
                    color: skinColor,
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
              ),

              // HAT
              if (hatColor != null && hatColor != 'transparent')
                Positioned(
                  top: 2,
                  child: Container(
                    width: 64,
                    height: 22,
                    decoration: BoxDecoration(
                      color: Color(
                        int.parse(hatColor.replaceFirst('#', '0xFF')),
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                    ),
                  ),
                ),

              // BODY / SHIRT
              Positioned(
                top: 65,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: shirtColor != null
                        ? Color(int.parse(shirtColor.replaceFirst('#', '0xFF')))
                        : Colors.grey.shade600,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                ),
              ),

              // ARMS
              Positioned(
                top: 68,
                left: 10,
                child: Container(
                  width: 18,
                  height: 45,
                  decoration: BoxDecoration(
                    color: shirtColor != null
                        ? Color(int.parse(shirtColor.replaceFirst('#', '0xFF')))
                        : Colors.grey.shade600,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              Positioned(
                top: 68,
                right: 10,
                child: Container(
                  width: 18,
                  height: 45,
                  decoration: BoxDecoration(
                    color: shirtColor != null
                        ? Color(int.parse(shirtColor.replaceFirst('#', '0xFF')))
                        : Colors.grey.shade600,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

              // PANTS
              Positioned(
                top: 120,
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 50,
                      decoration: BoxDecoration(
                        color: pantsColor != null
                            ? Color(
                                int.parse(pantsColor.replaceFirst('#', '0xFF')),
                              )
                            : Colors.blueGrey.shade700,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 28,
                      height: 50,
                      decoration: BoxDecoration(
                        color: pantsColor != null
                            ? Color(
                                int.parse(pantsColor.replaceFirst('#', '0xFF')),
                              )
                            : Colors.blueGrey.shade700,
                        borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // SHOES
              Positioned(
                top: 165,
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 14,
                      decoration: BoxDecoration(
                        color: shoesColor != null
                            ? Color(
                                int.parse(shoesColor.replaceFirst('#', '0xFF')),
                              )
                            : Colors.brown.shade800,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(6),
                          bottomRight: Radius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(width: 2),
                    Container(
                      width: 30,
                      height: 14,
                      decoration: BoxDecoration(
                        color: shoesColor != null
                            ? Color(
                                int.parse(shoesColor.replaceFirst('#', '0xFF')),
                              )
                            : Colors.brown.shade800,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(2),
                          bottomRight: Radius.circular(6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = cat == selectedCategory;
          return GestureDetector(
            onTap: () => setState(() => selectedCategory = cat),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFB020DD)
                    : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFB020DD)
                      : Colors.white.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(categoryIcons[cat], color: Colors.white, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    cat[0].toUpperCase() + cat.substring(1),
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildItemsGrid() {
    final items = _categoryItems;
    if (items.isEmpty) {
      return const Center(
        child: Text(
          'No items available in this category.',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    final ownedIds =
        (avatar?['ownedItems'] as List<dynamic>?)
            ?.map((i) => i['_id'].toString())
            .toSet() ??
        {};

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isEquipped = _getEquippedId(selectedCategory) == item['_id'];
        final isOwned = ownedIds.contains(item['_id'].toString());
        final xpCost = item['xpCost'] ?? 0;
        final color = item['color'] == 'transparent'
            ? Colors.transparent
            : Color(int.parse(item['color'].replaceFirst('#', '0xFF')));

        return GestureDetector(
          onTap: isOwned
              ? () => _equipItem(item['_id'])
              : () => _unlockItem(item),
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    // item color box
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: color == Colors.transparent
                            ? Colors.white.withOpacity(0.05)
                            : isOwned
                            ? color
                            : color.withOpacity(0.3), // dimmed if locked
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isEquipped
                              ? const Color(0xFFB020DD)
                              : Colors.white.withOpacity(0.2),
                          width: isEquipped ? 2 : 1,
                        ),
                      ),
                      child: isEquipped
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 20,
                            )
                          : null,
                    ),

                    // lock overlay for unowned items
                    if (!isOwned)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.lock,
                                color: Colors.white70,
                                size: 16,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$xpCost XP',
                                style: const TextStyle(
                                  color: Colors.amber,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item['name'],
                style: TextStyle(
                  color: isOwned ? Colors.white : Colors.white38,
                  fontSize: 9,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }
}
