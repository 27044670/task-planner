import 'package:flutter/material.dart';

class ColorPickerBottomSheet extends StatelessWidget {
  final String? selectedColor;
  final Function(String color) onColorSelected;

  const ColorPickerBottomSheet({
    super.key,
    this.selectedColor,
    required this.onColorSelected,
  });

  static const List<Map<String, dynamic>> colors = [
    {'name': '红色', 'value': 'red', 'color': Colors.red},
    {'name': '橙色', 'value': 'orange', 'color': Colors.orange},
    {'name': '黄色', 'value': 'yellow', 'color': Colors.yellow},
    {'name': '绿色', 'value': 'green', 'color': Colors.green},
    {'name': '蓝色', 'value': 'blue', 'color': Colors.blue},
    {'name': '紫色', 'value': 'purple', 'color': Colors.purple},
    {'name': '粉色', 'value': 'pink', 'color': Colors.pink},
    {'name': '灰色', 'value': 'grey', 'color': Colors.grey},
  ];

  static Color getColorValue(String colorName) {
    final color = colors.firstWhere(
      (c) => c['value'] == colorName,
      orElse: () => {'color': Colors.transparent},
    );
    return color['color'] as Color;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '选择颜色',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 15,
            runSpacing: 15,
            children: colors.map((colorData) {
              final isSelected = selectedColor == colorData['value'];
              return GestureDetector(
                onTap: () {
                  onColorSelected(colorData['value'] as String);
                  Navigator.pop(context);
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: colorData['color'] as Color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.black : Colors.grey.shade300,
                      width: isSelected ? 3 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white)
                      : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () {
              onColorSelected(''); // 清除颜色
              Navigator.pop(context);
            },
            child: const Text('清除颜色'),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

// 显示颜色选择器
Future<String?> showColorPicker(BuildContext context, String? currentColor) async {
  String? selectedColor = currentColor;
  await showModalBottomSheet(
    context: context,
    builder: (context) => ColorPickerBottomSheet(
      selectedColor: currentColor,
      onColorSelected: (color) {
        selectedColor = color;
      },
    ),
  );
  return selectedColor;
}
