import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class ReductionReasonCheckboxesMulti extends StatefulWidget {
  final List<String>? selectedReasons;
  final ValueChanged<List<String>>? onReasonsChanged;
  final Map<String, int> counts;
  final ValueChanged<Map<String, int>>? onCountsChanged;
  final double? salesAmount;
  final ValueChanged<double>? onSalesAmountChanged;
  final bool showCountsBelow;

  const ReductionReasonCheckboxesMulti({
    super.key,
    this.selectedReasons,
    this.onReasonsChanged,
    required this.counts,
    this.onCountsChanged,
    this.salesAmount,
    this.onSalesAmountChanged,
    this.showCountsBelow = false,
  });

  @override
  State<ReductionReasonCheckboxesMulti> createState() =>
      _ReductionReasonCheckboxesMultiState();
}

class _ReductionReasonCheckboxesMultiState
    extends State<ReductionReasonCheckboxesMulti> {
  final Map<String, bool> _checked = {
    'curled': false,
    'stolen': false,
    'death': false,
    'sold': false,
  };
  final Map<String, TextEditingController> _controllers = {};
  final TextEditingController _salesAmountController = TextEditingController();
  final Map<String, int> _counts = {};

  @override
  void initState() {
    super.initState();

    for (final reason in _checked.keys) {
      _controllers[reason] = TextEditingController();
      _counts[reason] = widget.counts[reason] ?? 0;
      if ((_counts[reason] ?? 0) > 0) {
        _controllers[reason]?.text = _counts[reason].toString();
      }
    }

    if (widget.selectedReasons != null) {
      for (final reason in widget.selectedReasons!) {
        _checked[reason] = true;
      }
    }

    if (widget.salesAmount != null) {
      _salesAmountController.text = widget.salesAmount!.toString();
    }
    _salesAmountController.addListener(_onSalesAmountChanged);
    for (final entry in _controllers.entries) {
      entry.value.addListener(() => _onCountChanged(entry.key));
    }
  }

  void _onSalesAmountChanged() {
    if (_checked['sold'] == true && widget.onSalesAmountChanged != null) {
      final amount = double.tryParse(_salesAmountController.text);
      if (amount != null) {
        widget.onSalesAmountChanged!(amount);
      }
    }
  }

  @override
  void dispose() {
    _salesAmountController.dispose();
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onCountChanged(String reason) {
    final count = int.tryParse(_controllers[reason]?.text ?? '') ?? 0;
    _counts[reason] = count;
    if (widget.onCountsChanged != null) {
      widget.onCountsChanged!(_counts);
    }
  }

  Widget _buildCountField(String reason) {
    String getQuantityLabel(String reason) {
      switch (reason) {
        case 'curled':
          return 'How many chickens curled?';
        case 'stolen':
          return 'How many chickens stolen?';
        case 'death':
          return 'How many chickens died?';
        case 'sold':
          return 'How many chickens sold?';
        default:
          return 'How many chickens $reason?';
      }
    }

    return Padding(
      padding: const EdgeInsets.only(left: 40.0, top: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _controllers[reason],
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: getQuantityLabel(reason),
                border: const OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        ..._checked.keys.map(
          (reason) => Column(
            children: [
              CheckboxListTile(
                title: Text(reason.tr()),
                value: _checked[reason],
                onChanged: (val) {
                  setState(() {
                    _checked[reason] = val ?? false;

                    if (widget.onReasonsChanged != null) {
                      final selected = _checked.entries
                          .where((e) => e.value)
                          .map((e) => e.key)
                          .toList();
                      widget.onReasonsChanged!(selected);
                    }
                  });

                  // Clear count when unchecked
                  if (val == false) {
                    _controllers[reason]?.clear();
                    _onCountChanged(reason);
                  }
                },
              ),
              if (_checked[reason] == true) _buildCountField(reason),
            ],
          ),
        ),
        if (_checked['sold'] == true) ...[
          const SizedBox(height: 16),
          TextFormField(
            controller: _salesAmountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'How much did you sell the chickens? (total)',
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ],
    );
  }
}