import 'package:flutter/material.dart';

class PlayerRecord {
  final String name;
  final String character;
  final int xp;
  final String imagePath;

  PlayerRecord({
    required this.name,
    required this.character,
    required this.xp,
    required this.imagePath,
  });
}

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<PlayerRecord> dummyPlayers = [
      PlayerRecord(name: 'Aeliana', character: 'Mage', xp: 12500, imagePath: 'assets/images/2307-w015-n003-1237B-p15-1237 1.png'),
      PlayerRecord(name: 'Kaelen', character: 'Warrior', xp: 11200, imagePath: 'assets/images/2307-w015-n003-1237B-p15-1237 1.png'),
      PlayerRecord(name: 'Lyra', character: 'Archer', xp: 9800, imagePath: 'assets/images/2307-w015-n003-1237B-p15-1237 1.png'),
      PlayerRecord(name: 'Theron', character: 'Paladin', xp: 8500, imagePath: 'assets/images/2307-w015-n003-1237B-p15-1237 1.png'),
      PlayerRecord(name: 'Seraphina', character: 'Cleric', xp: 7200, imagePath: 'assets/images/2307-w015-n003-1237B-p15-1237 1.png'),
      PlayerRecord(name: 'Darian', character: 'Rogue', xp: 6800, imagePath: 'assets/images/2307-w015-n003-1237B-p15-1237 1.png'),
      PlayerRecord(name: 'Valerius', character: 'Knight', xp: 5400, imagePath: 'assets/images/2307-w015-n003-1237B-p15-1237 1.png'),
    ];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2E004E), // Dark Purple
              Color(0xFF8E24AA), // Purple
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Text(
                      'Leaderboard',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: dummyPlayers.length,
                  itemBuilder: (context, index) {
                    final player = dummyPlayers[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Rank indicator
                          Container(
                            width: 35,
                            height: 35,
                            decoration: BoxDecoration(
                              color: index < 3 ? Colors.amber : Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: index < 3 ? Colors.black : Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Avatar
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.purple.shade200,
                            backgroundImage: AssetImage(player.imagePath),
                          ),
                          const SizedBox(width: 12),
                          // Player Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  player.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  player.character,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.6),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // XP Container
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.shade900.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${player.xp} XP',
                              style: const TextStyle(
                                color: Colors.amber,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}