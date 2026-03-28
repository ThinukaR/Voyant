import 'package:flutter/material.dart';
import 'package:voyant/widgets/animated_gradient_background.dart';

class AppearanceSettingsScreen extends StatefulWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  State<AppearanceSettingsScreen> createState() =>
      _AppearanceSettingsScreenState();
}

class _AppearanceSettingsScreenState extends State<AppearanceSettingsScreen> {
  // Theme
  String _selectedTheme = 'System Default';

  // Colors
  String _selectedAccentColor = 'Cyan';
  String _selectedThemeStyle = 'Modern';

  // Typography
  String _selectedFontStyle = 'Roboto';
  String _selectedFontSize = 'Medium';

  // Display
  String _selectedLayout = 'Comfortable';
  String _selectedIconSize = 'Medium';

  // Accessibility
  bool _highContrastMode = false;
  bool _reduceAnimations = false;
  String _colorBlindnessSupport = 'None';

  // Visual Effects
  bool _animationsEnabled = true;
  bool _blurEffects = true;

  // Map Appearance
  String _selectedMapStyle = 'Standard';
  bool _showLandmarks = true;

  final List<String> _themeOptions = ['Light Mode', 'Dark Mode', 'System Default'];
  final List<String> _accentColors = [
    'Cyan',
    'Purple',
    'Green',
    'Blue',
    'Orange',
    'Pink'
  ];
  final List<String> _themeStyles = ['Modern', 'Classic', 'Minimal', 'Vibrant'];
  final List<String> _fontStyles = ['Roboto', 'Inter', 'Poppins', 'Lato'];
  final List<String> _fontSizes = ['Small', 'Medium', 'Large'];
  final List<String> _layouts = ['Compact', 'Comfortable'];
  final List<String> _iconSizes = ['Small', 'Medium', 'Large'];
  final List<String> _colorBlindnessOptions = [
    'None',
    'Protanopia',
    'Deuteranopia',
    'Tritanopia'
  ];
  final List<String> _mapStyles = ['Standard', 'Satellite', 'Dark'];

  void _saveChanges() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Appearance settings saved successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Color _getAccentColor(String colorName) {
    switch (colorName) {
      case 'Purple':
        return Colors.purple;
      case 'Green':
        return Colors.green;
      case 'Blue':
        return Colors.blue;
      case 'Orange':
        return Colors.orange;
      case 'Pink':
        return Colors.pink;
      default:
        return Colors.cyanAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      'Appearance',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // Theme Section
                        _buildSectionCard(
                          title: 'Theme',
                          icon: Icons.brightness_4,
                          children: [
                            _buildRadioGroupTile(
                              options: _themeOptions,
                              selectedValue: _selectedTheme,
                              onChanged: (value) {
                                setState(() => _selectedTheme = value);
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Colors Section
                        _buildSectionCard(
                          title: 'Colors',
                          icon: Icons.palette,
                          children: [
                            const SizedBox(height: 8),
                            const Text(
                              'Accent Color',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 60,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _accentColors.length,
                                itemBuilder: (context, index) {
                                  String color = _accentColors[index];
                                  bool isSelected =
                                      color == _selectedAccentColor;
                                  return GestureDetector(
                                    onTap: () {
                                      setState(
                                          () => _selectedAccentColor = color);
                                    },
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(right: 12),
                                      child: Container(
                                        width: 50,
                                        decoration: BoxDecoration(
                                          color: _getAccentColor(color),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.transparent,
                                            width: 3,
                                          ),
                                        ),
                                        child: isSelected
                                            ? const Icon(
                                                Icons.check,
                                                color: Colors.white,
                                              )
                                            : null,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildDropdownField(
                              label: 'Theme Style',
                              value: _selectedThemeStyle,
                              items: _themeStyles,
                              onChanged: (value) {
                                setState(() => _selectedThemeStyle = value);
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Typography Section
                        _buildSectionCard(
                          title: 'Typography',
                          icon: Icons.text_fields,
                          children: [
                            _buildDropdownField(
                              label: 'Font Style',
                              value: _selectedFontStyle,
                              items: _fontStyles,
                              onChanged: (value) {
                                setState(() => _selectedFontStyle = value);
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildDropdownField(
                              label: 'Font Size',
                              value: _selectedFontSize,
                              items: _fontSizes,
                              onChanged: (value) {
                                setState(() => _selectedFontSize = value);
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Display Section
                        _buildSectionCard(
                          title: 'Display',
                          icon: Icons.dashboard,
                          children: [
                            _buildDropdownField(
                              label: 'Layout',
                              value: _selectedLayout,
                              items: _layouts,
                              onChanged: (value) {
                                setState(() => _selectedLayout = value);
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildDropdownField(
                              label: 'Icon Size',
                              value: _selectedIconSize,
                              items: _iconSizes,
                              onChanged: (value) {
                                setState(() => _selectedIconSize = value);
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Accessibility Section
                        _buildSectionCard(
                          title: 'Accessibility',
                          icon: Icons.accessibility,
                          children: [
                            _buildToggleTile(
                              'High Contrast Mode',
                              _highContrastMode,
                              (value) {
                                setState(() => _highContrastMode = value);
                              },
                            ),
                            const SizedBox(height: 12),
                            _buildToggleTile(
                              'Reduce Animations',
                              _reduceAnimations,
                              (value) {
                                setState(() => _reduceAnimations = value);
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildDropdownField(
                              label: 'Color Blindness Support',
                              value: _colorBlindnessSupport,
                              items: _colorBlindnessOptions,
                              onChanged: (value) {
                                setState(
                                    () => _colorBlindnessSupport = value);
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Visual Effects Section
                        _buildSectionCard(
                          title: 'Visual Effects',
                          icon: Icons.auto_awesome,
                          children: [
                            _buildToggleTile(
                              'Enable Animations',
                              _animationsEnabled,
                              (value) {
                                setState(() => _animationsEnabled = value);
                              },
                            ),
                            const SizedBox(height: 12),
                            _buildToggleTile(
                              'Blur & Transparency Effects',
                              _blurEffects,
                              (value) {
                                setState(() => _blurEffects = value);
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Map Appearance Section
                        _buildSectionCard(
                          title: 'Map Appearance',
                          icon: Icons.map,
                          children: [
                            _buildDropdownField(
                              label: 'Map Style',
                              value: _selectedMapStyle,
                              items: _mapStyles,
                              onChanged: (value) {
                                setState(() => _selectedMapStyle = value);
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildToggleTile(
                              'Show Landmarks',
                              _showLandmarks,
                              (value) {
                                setState(() => _showLandmarks = value);
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        // Save Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _saveChanges,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.cyanAccent,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Save Changes',
                              style: TextStyle(
                                color: Color(0xFF1B0033),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
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

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.cyanAccent,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Icon(
                icon,
                color: Colors.cyanAccent,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Section Items
          ...children,
        ],
      ),
    );
  }

  Widget _buildToggleTile(String label, bool value, Function(bool) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.cyanAccent,
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.cyanAccent,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            dropdownColor: const Color(0xFF1B0033),
            style: const TextStyle(
              color: Colors.white,
            ),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                onChanged(newValue);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRadioGroupTile({
    required List<String> options,
    required String selectedValue,
    required Function(String) onChanged,
  }) {
    return Column(
      children: options
          .map(
            (option) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Radio<String>(
                    value: option,
                    groupValue: selectedValue,
                    onChanged: (value) {
                      if (value != null) {
                        onChanged(value);
                      }
                    },
                    activeColor: Colors.cyanAccent,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    option,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
