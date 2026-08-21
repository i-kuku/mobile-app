import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:ikuku/theme/app_theme.dart';

class RecordChickenSalePage extends StatefulWidget {
  const RecordChickenSalePage({super.key});

  @override
  State<RecordChickenSalePage> createState() => _RecordChickenSalePageState();
}

class _RecordChickenSalePageState extends State<RecordChickenSalePage> {
  final Set<String> _selectedTypes = {'chicken'};
  String? _selectedBirdType;

  final _countController = TextEditingController();
  final _priceController = TextEditingController();
  final _eggsCountController = TextEditingController();
  final _eggsPriceController = TextEditingController();

  @override
  void dispose() {
    _countController.dispose();
    _priceController.dispose();
    _eggsCountController.dispose();
    _eggsPriceController.dispose();
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
                    icon: SvgPicture.asset(
                      'assets/icons/animal-chicken.svg',
                      width: 16,
                      height: 16,
                      colorFilter: ColorFilter.mode(
                        _selectedTypes.contains('chicken')
                            ? Colors.white
                            : Colors.grey,
                        BlendMode.srcIn,
                      ),
                    ),
                    selected: _selectedTypes.contains('chicken'),
                    color: CustomColors.primary,
                    onTap: () => _toggleType('chicken'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _pillChip(
                    label: 'Eggs',
                    icon: Icon(
                      Icons.egg,
                      size: 16,
                      color: _selectedTypes.contains('eggs')
                          ? Colors.white
                          : Colors.grey,
                    ),
                    selected: _selectedTypes.contains('eggs'),
                    color: Colors.orange,
                    onTap: () => _toggleType('eggs'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _pillChip(
                    label: 'Manure',
                    icon: const Icon(
                      Icons.shopping_bag_outlined,
                      size: 16,
                      color: Colors.grey,
                    ),
                    selected: false,
                    color: Colors.grey,
                    onTap: () => context.pushReplacement('/record_manure_sale'),
                  ),
                ),
              ],
            ),
            if (_selectedTypes.contains('chicken')) ...[
              const SizedBox(height: 28),
              const Text(
                'Chicken type',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _outlineChip(
                      label: 'Kienyeji',
                      selected: _selectedBirdType == 'kienyeji',
                      onTap: () =>
                          setState(() => _selectedBirdType = 'kienyeji'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _outlineChip(
                      label: 'Broiler',
                      selected: _selectedBirdType == 'broiler',
                      onTap: () =>
                          setState(() => _selectedBirdType = 'broiler'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _outlineChip(
                      label: 'Layer',
                      selected: _selectedBirdType == 'layer',
                      onTap: () => setState(() => _selectedBirdType = 'layer'),
                    ),
                  ),
                ],
              ),
              if (_selectedBirdType != null) ...[
                const SizedBox(height: 28),
                const Text(
                  'How many chicken ?',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                _inputField(controller: _countController, hint: '0'),
                const SizedBox(height: 20),
                const Text(
                  'Price of Chicken',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                _inputField(controller: _priceController, hint: '0'),
              ],
            ],
            if (_selectedTypes.contains('eggs')) ...[
              const SizedBox(height: 28),
              const Text(
                'How many eggs ?',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              _inputField(controller: _eggsCountController, hint: '0'),
              const SizedBox(height: 20),
              const Text(
                'Price of eggs',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              _inputField(controller: _eggsPriceController, hint: '0'),
            ],
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

  void _toggleType(String type) {
    setState(() {
      if (_selectedTypes.contains(type)) {
        // keep at least one type selected
        if (_selectedTypes.length > 1) _selectedTypes.remove(type);
      } else {
        _selectedTypes.add(type);
      }
    });
  }

  Widget _pillChip({
    required String label,
    required Widget icon,
    required bool selected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: selected ? color : Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  color: selected ? Colors.white : Colors.grey.shade700,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _outlineChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? CustomColors.primary : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 13,
            color: selected ? CustomColors.primary : Colors.grey.shade700,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
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
