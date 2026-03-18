import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui';
import 'package:voyant/blocs/avatar_bloc/avatar_bloc.dart';
import 'package:user_repository/user_repository.dart';

class AvatarScreen extends StatefulWidget {
  const AvatarScreen({super.key});

  @override
  State<AvatarScreen> createState() => _AvatarScreenState();
}

class _AvatarScreenState extends State<AvatarScreen> {
  @override
  void initState() {
    super.initState();
    // Load user's avatars or initialize with empty draft
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
            // Initialize draft if no current avatar exists
            if (state.draftAvatar == null && state.status == AvatarStatus.success) {
              context.read<AvatarBloc>().add(
                    CreateAvatar(
                      Avatar(
                        aid: DateTime.now().toString(),
                        uid: '',
                        characterData: [],
                        cosmetics: [],
                      ),
                    ),
                  );
            }

            if (state.status == AvatarStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${state.errorMessage}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
            
            // Only show success snackbar when save completes
            if (state.showSaveSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Avatar saved successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: Column(
                children: [
                  // Avatar Display Area
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          height: 350,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 2,
                            ),
                            color: Colors.white.withOpacity(0.1),
                          ),
                          child: Center(
                            child: Container(
                              width: 200,
                              height: 250,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                  width: 1,
                                ),
                              ),
                              child: BlocBuilder<AvatarBloc, AvatarState>(
                                builder: (context, state) {
                                  if (state.draftAvatar?.cosmetics.isNotEmpty ??
                                      false) {
                                    return Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.person,
                                          size: 80,
                                          color: Colors.white70,
                                        ),
                                        const SizedBox(height: 16),
                                        Wrap(
                                          spacing: 8,
                                          children: state.draftAvatar!.cosmetics
                                              .map(
                                                (cosmetic) => Chip(
                                                  label: Text(cosmetic),
                                                  backgroundColor: Colors.purple
                                                      .withOpacity(0.5),
                                                  labelStyle:
                                                      const TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                        ),
                                      ],
                                    );
                                  }
                                  return const Center(
                                    child: Icon(
                                      Icons.person,
                                      size: 120,
                                      color: Colors.white70,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Items Available Section
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Items available',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ),

                  // Items Grid
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 2,
                            ),
                            color: Colors.white.withOpacity(0.1),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: BlocBuilder<AvatarBloc, AvatarState>(
                            builder: (context, state) {
                              final itemsList = [
                                'Hat',
                                'Glasses',
                                'Scarf',
                                'Jacket',
                                'Shoes',
                                'Ring',
                                'Necklace',
                                'Gloves'
                              ];

                              return GridView.builder(
                                shrinkWrap: true,
                                physics:
                                    const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  mainAxisSpacing: 12,
                                  crossAxisSpacing: 12,
                                ),
                                itemCount: itemsList.length,
                                itemBuilder: (context, index) {
                                  final item = itemsList[index];
                                  final isSelected = state.draftAvatar
                                          ?.cosmetics
                                          .contains(item) ??
                                      false;

                                  return GestureDetector(
                                    onTap: () {
                                      if (isSelected) {
                                        context
                                            .read<AvatarBloc>()
                                            .add(RemoveCosmetic(item));
                                      } else {
                                        context
                                            .read<AvatarBloc>()
                                            .add(AddCosmetic(item));
                                      }
                                    },
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Expanded(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              color: isSelected
                                                  ? const Color(0xFFA78BFA)
                                                  : Colors.white,
                                              border: isSelected
                                                  ? Border.all(
                                                      color: const Color(
                                                          0xFF4C1D95),
                                                      width: 2,
                                                    )
                                                  : null,
                                            ),
                                            child: Center(
                                              child: Icon(
                                                Icons.checkroom,
                                                color: isSelected
                                                    ? Colors.white
                                                    : Colors.grey,
                                                size: 28,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          item,
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall
                                              ?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Action Buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: BlocBuilder<AvatarBloc, AvatarState>(
                      builder: (context, state) {
                        final isLoading =
                            state.status == AvatarStatus.loading;

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Discard Button
                            ElevatedButton(
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      context
                                          .read<AvatarBloc>()
                                          .add(const DiscardAvatar());
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4C1D95),
                                disabledBackgroundColor:
                                    const Color(0xFF4C1D95).withOpacity(0.5),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Discard',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Save Button
                            ElevatedButton(
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      context
                                          .read<AvatarBloc>()
                                          .add(const SaveAvatar());
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFA78BFA),
                                disabledBackgroundColor:
                                    const Color(0xFFA78BFA).withOpacity(0.5),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                      ),
                                    )
                                  : Text(
                                      'Save',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 32),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
