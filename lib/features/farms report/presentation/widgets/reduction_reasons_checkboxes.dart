import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ReductionReasonCheckboxesMulti extends StatefulWidget {
  final List<String>? selectedReasons;
  final ValueChanged<List<String>>? onReasonsChanged;
  final Map<String, int> counts;
  final ValueChanged<Map<String, int>>? onCountsChanged;
  final bool showCountsBelow;

  const ReductionReasonCheckboxesMulti({
    super.key,
    this.selectedReasons,
    this.onReasonsChanged,
    required this.counts,
    this.onCountsChanged,
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
  };
  final Map<String, TextEditingController> _controllers = {};
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
        if (_checked.containsKey(reason)) {
          _checked[reason] = true;
        }
      }
    }

    for (final entry in _controllers.entries) {
      entry.value.addListener(() => _onCountChanged(entry.key));
    }
  }

  @override
  void dispose() {
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
          return 'how_many_chickens_curled?'.tr();
        case 'stolen':
          return 'how_many_chickens_stolen?'.tr();
        case 'death':
          return 'how_many_chickens_died?'.tr();
        default:
          return 'how_many_chickens_$reason?'.tr();
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
      ],
    );
  }
}