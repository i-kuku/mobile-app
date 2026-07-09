import 'package:flutter/material.dart';
import 'package:ikuku/features/batches/model/chicken_batch_model.dart';
import 'package:ikuku/features/farms%20report/presentation/widgets/batch_card.dart';



class ReductionPage extends StatefulWidget {
  final ChickenBatch batch;
  const ReductionPage({super.key, required this.batch});

  @override
  State<ReductionPage> createState() => _ReductionPageState();
}

class _ReductionPageState extends State<ReductionPage> {
  // Track radio button state (null = unselected, true = Yes, false = No)
  bool? _hasReduced;
 

  // Track checkbox states
  bool _isCulled = false;
  bool _isStolen = false;
  bool _isDeath = false;
  bool _isSold = false;

  // Controllers to track quantities entered
  final TextEditingController _culledCountController = TextEditingController();
  final TextEditingController _stolenCountController = TextEditingController();
  final TextEditingController _deathCountController = TextEditingController();
  final TextEditingController _soldCountController = TextEditingController();

  @override
  void dispose() {
    _culledCountController.dispose();
    _stolenCountController.dispose();
    _deathCountController.dispose();
    _soldCountController.dispose();
    super.dispose();
  }
  Color _getBirdTypeColor(String type) {
    switch (type.toLowerCase().trim()) {
      case 'broiler':
        return Colors.green.shade100;
      case 'layer':
        return Colors.orange.shade100; // Visible dark yellow
      case 'kienyeji':
        return Colors.grey.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff7f9fa),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.arrow_back, color: Color(0xFF0D652D)),
        title: const Text(
          'Farm Report Entry',
          style: TextStyle(
            color: Color(0xFF0D652D),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Chicken Reduction',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E331A),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Selected Batch Information Card
                    BatchCard(
                      batch:widget.batch, 
                      birdTypeColor: _getBirdTypeColor(widget.batch.typeOfBird),
                      isSelected: false,
                      ),
                     SizedBox(height: 32),

                    // Reduction Question
                    const Text(
                      'Have your chickens reduced today?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1E331A),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Radio Buttons
                    Row(
                      children: [
                        _buildRadioButton(title: 'Yes', value: true),
                        const SizedBox(width: 24),
                        _buildRadioButton(title: 'No', value: false),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Conditional Options Layout
                    if (_hasReduced == true) ...[
                      const Divider(height: 32, color: Colors.black12),
                      const Text(
                        'What is the reason for the reduction?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1E331A),
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildCheckboxTile(
                        'Curled',
                        _isCulled,
                        (val) => setState(() => _isCulled = val!),
                      ),
                      if (_isCulled)
                        _buildQuantityField(
                          'How many chickens curled?',
                          _culledCountController,
                        ),

                      _buildCheckboxTile(
                        'Stolen',
                        _isStolen,
                        (val) => setState(() => _isStolen = val!),
                      ),
                      if (_isStolen)
                        _buildQuantityField(
                          'How many chickens stolen?',
                          _stolenCountController,
                        ),

                      _buildCheckboxTile(
                        'Death',
                        _isDeath,
                        (val) => setState(() => _isDeath = val!),
                      ),
                      if (_isDeath)
                        _buildQuantityField(
                          'How many chickens died?',
                          _deathCountController,
                        ),

                      _buildCheckboxTile(
                        'Sold',
                        _isSold,
                        (val) => setState(() => _isSold = val!),
                      ),
                      if (_isSold)
                        _buildQuantityField(
                          'How many chickens sold?',
                          _soldCountController,
                        ),
                    ],
                  ],
                ),
              ),
            ),

            // Continue Button Fixed at Bottom
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Container(
                width: double.infinity,
                height: 54,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF90C224), Color(0xFFF9B826)],
                  ),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    // Handle submission or forward flow
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'CONTINUE',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioButton({required String title, required bool value}) {
    final bool isSelected = _hasReduced == value;
    return InkWell(
      onTap: () => setState(() => _hasReduced = value),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF0D652D) : Colors.black54,
                  width: isSelected ? 6.5 : 2,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckboxTile(
    String title,
    bool currentValue,
    ValueChanged<bool?> onChanged,
  ) {
    return InkWell(
      onTap: () => onChanged(!currentValue),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: Colors.black87,
              ),
            ),
            SizedBox(
              height: 24,
              width: 24,
              child: Checkbox(
                value: currentValue,
                onChanged: onChanged,
                activeColor: const Color(0xFF0D652D),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                side: const BorderSide(color: Colors.black54, width: 2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityField(
    String hintText,
    TextEditingController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, top: 4.0),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          filled: true,
          fillColor: const Color(0xfff7f9fa),

          // Green borders
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF0D652D), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF0D652D), width: 2.0),
          ),
        ),
      ),
    );
  }
}