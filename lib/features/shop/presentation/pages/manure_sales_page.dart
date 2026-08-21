import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ikuku/theme/app_theme.dart';

class RecordManureSalePage extends StatefulWidget {
  const RecordManureSalePage({super.key});

  @override
  State<RecordManureSalePage> createState() => _RecordManureSalePageState();
}

class _RecordManureSalePageState extends State<RecordManureSalePage> {
  final _bagsController = TextEditingController();
  final _priceController = TextEditingController();

  @override
  void dispose() {
    _bagsController.dispose();
    _priceController.dispose();
    super.dispose();
  }

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'RECORD SALE',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'What have You Sold?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _pillChip(
                    label: 'Chicken',
                    icon: Icons.pets,
                    selected: false,
                    onTap: () =>
                        context.pushReplacement('/record_chicken_sale'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _pillChip(
                    label: 'Eggs',
                    icon: Icons.egg,
                    selected: false,
                    onTap: () => context.pushReplacement('/record_eggs_sale'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _pillChip(
                    label: 'Manure',
                    icon: Icons.shopping_bag_outlined,
                    selected: true,
                    onTap: () {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            const Text(
              'How bags of manure?',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            _inputField(controller: _bagsController, hint: '0'),
            const SizedBox(height: 20),
            const Text(
              'Price of manure bags',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            _inputField(controller: _priceController, hint: '0'),
            const SizedBox(height: 28),
            _recordSaleButton(
              onTap: () {
                // No functionality yet — UI only
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _pillChip({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEAF7EC) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? CustomColors.primary : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? CustomColors.primary : Colors.grey,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  color: selected ? CustomColors.primary : Colors.grey.shade700,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }

  Widget _recordSaleButton({required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: CustomColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text(
          'RECORD SALE',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
