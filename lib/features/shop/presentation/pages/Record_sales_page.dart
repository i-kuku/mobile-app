import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ikuku/theme/app_theme.dart';

class RecordSalePage extends StatefulWidget {
  const RecordSalePage({super.key});

  @override
  State<RecordSalePage> createState() => _RecordSalePageState();
}

class _RecordSalePageState extends State<RecordSalePage> {
  String? _selectedType; // 'chicken' | 'eggs' | 'manure'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff7f9fa),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'My Shop',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'What have You Sold?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _typeChip(
                    label: 'Chicken',
                    icon: Icons.pets,
                    type: 'chicken',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _typeChip(
                    label: 'Eggs',
                    icon: Icons.egg,
                    type: 'eggs',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _typeChip(
                    label: 'Manure',
                    icon: Icons.shopping_bag_outlined,
                    type: 'manure',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeChip({
    required String label,
    required IconData icon,
    required String type,
  }) {
    final isSelected = _selectedType == type;
    return InkWell(
      onTap: () {
        setState(() => _selectedType = type);
        if (type == 'chicken') {
          context.push('/record_chicken_sale');
        }
        if (type == 'eggs') {
          context.push('/record_eggs_sale');
        }
        if (type == 'manure') {
          context.push('/record_manure_sale');
        }
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? CustomColors.primary.withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? CustomColors.primary : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? CustomColors.primary : Colors.grey,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  color: isSelected
                      ? CustomColors.primary
                      : Colors.grey.shade700,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
