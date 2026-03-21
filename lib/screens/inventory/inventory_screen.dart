import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui';
import 'package:voyant/blocs/avatar_bloc/avatar_bloc.dart';


// A placeholder for an inventory item model
class InventoryItem {
  final String id;
  final String name;
  final String category; // e.g., 'Hat', 'Jacket', 'Badge'
  final IconData icon;

  InventoryItem({required this.id, required this.name, required this.category, required this.icon});
}

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Dummy data for the inventory
  final List<InventoryItem> _cosmetics = [
    InventoryItem(id: 'hat1', name: 'Wizard Hat', category: 'Hat', icon: Icons.school),
    InventoryItem(id: 'glasses1', name: 'Cool Shades', category: 'Glasses', icon: Icons.visibility),
    InventoryItem(id: 'scarf1', name: 'Warm Scarf', category: 'Scarf', icon: Icons.ac_unit),
    InventoryItem(id: 'jacket1', name: 'Leather Jacket', category: 'Jacket', icon: Icons.checkroom),
    InventoryItem(id: 'shoes1', name: 'Running Shoes', category: 'Shoes', icon: Icons.directions_run),
  ];

  final List<InventoryItem> _badges = [
    InventoryItem(id: 'badge1', name: 'First Quest', category: 'Badge', icon: Icons.military_tech),
    InventoryItem(id: 'badge2', name: 'Explorer', category: 'Badge', icon: Icons.explore),
  ];

  final List<InventoryItem> _items = [
    InventoryItem(id: 'item1', name: 'Health Potion', category: 'Item', icon: Icons.local_drink),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Load inventory data
    context.read<AvatarBloc>().add(const LoadUserAvatars());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/2307-w015-n003-1237B-p15-1237 1.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: BlocListener<AvatarBloc, AvatarState>(
          listener: (context, state) {
            if (state.status == AvatarStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${state.errorMessage}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: SafeArea(
            child: Column(
              children: [
                // Custom App Bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Text(
                        'Inventory',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // Avatar Display Area
                _buildAvatarDisplay(),
                
                const SizedBox(height: 24),

                // Inventory Tabs
                _buildTabs(),
                
                // Inventory Grid
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildInventoryGrid(_cosmetics, "Equip"),
                      _buildInventoryGrid(_badges, "Display"),
                      _buildInventoryGrid(_items, "Use"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarDisplay() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 250, // Reduced height
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
              color: Colors.white.withOpacity(0.1),
            ),
            child: Center(
              child: BlocBuilder<AvatarBloc, AvatarState>(
                builder: (context, state) {
                   return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.person, size: 100, color: Colors.white70),
                      const SizedBox(height: 16),
                      if (state.draftAvatar?.cosmetics.isNotEmpty ?? false)
                        Wrap(
                          spacing: 8,
                          children: state.draftAvatar!.cosmetics
                              .map((cosmetic) => Chip(
                                    label: Text(cosmetic),
                                    backgroundColor: Colors.purple.withOpacity(0.5),
                                    labelStyle: const TextStyle(color: Colors.white),
                                  ))
                              .toList(),
                        )
                      else
                        const Text("No items equipped", style: TextStyle(color: Colors.white54)),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white54,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFFA78BFA).withOpacity(0.5),
        ),
        tabs: const [
          Tab(text: 'Cosmetics'),
          Tab(text: 'Badges'),
          Tab(text: 'Items'),
        ],
      ),
    );
  }

  Widget _buildInventoryGrid(List<InventoryItem> items, String actionText) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          // Determine if the item is equipped
          final isEquipped = context.select((AvatarBloc bloc) => bloc.state.draftAvatar?.cosmetics.contains(item.name) ?? false);

          return GestureDetector(
            onTap: () {
              // Refactored to Equip/Unequip
              if (isEquipped) {
                context.read<AvatarBloc>().add(RemoveCosmetic(item.name)); // Should be Unequip
              } else {
                context.read<AvatarBloc>().add(AddCosmetic(item.name)); // Should be Equip
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: isEquipped ? const Color(0xFFA78BFA) : Colors.white.withOpacity(0.2),
                      border: isEquipped ? Border.all(color: const Color(0xFF4C1D95), width: 2) : null,
                    ),
                    child: Center(
                      child: Icon(item.icon, color: isEquipped ? Colors.white : Colors.white70, size: 28),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.name,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
