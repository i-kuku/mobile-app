import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ikuku/features/Inventory/model/inventoryitem.dart';
import 'package:ikuku/features/Inventory/provider/inventory_provider.dart';
import 'package:ikuku/features/farms%20report/provider/farm_report_provider.dart';
import 'package:ikuku/shared/widgets/feature_button.dart';
import 'package:ikuku/theme/app_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

class FeedsSelector extends StatefulWidget {
  final List<InventoryItem> feeds;
  final List<Map<String, dynamic>> selectedFeeds;
  final void Function(List<Map<String, dynamic>>) onSelectedFeedsChanged;

  const FeedsSelector({
    super.key,
    required this.feeds,
    required this.selectedFeeds,
    required this.onSelectedFeedsChanged,
  });

  @override
  State<FeedsSelector> createState() => _FeedsSelectorState();
}

class _FeedsSelectorState extends State<FeedsSelector> {
  // A separate field on the STATE (not the widget), so it can be reassigned freely.
  late List<Map<String, dynamic>> _mergedSelectedFeeds;

  @override
  void initState() {
    super.initState();
    final providerFeeds = context.read<FarmReportProvider>().feedsUsed;
    _mergedSelectedFeeds = List<Map<String, dynamic>>.from(
      providerFeeds.isNotEmpty ? providerFeeds : widget.selectedFeeds,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InventoryProvider>().fetchInventory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InventoryProvider>();

    if (provider.isloading) {
      return Scaffold(
        appBar: AppBar(elevation: 0),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(CustomColors.primary),
          ),
        ),
      );
    }
    return FeedsSelectionPage(
      feeds: widget.feeds,
      selectedFeeds: _mergedSelectedFeeds, // <-- merged value now actually used
      onSelectedFeedsChanged: widget.onSelectedFeedsChanged,
    );
  }
}

class FeedsSelectionPage extends StatefulWidget {
  final List<InventoryItem> feeds;
  final List<Map<String, dynamic>> selectedFeeds;
  final void Function(List<Map<String, dynamic>>) onSelectedFeedsChanged;

  const FeedsSelectionPage({
    super.key,
    required this.feeds,
    required this.selectedFeeds,
    required this.onSelectedFeedsChanged,
  });

  @override
  State<FeedsSelectionPage> createState() => _FeedsSelectionPage();
}

class _FeedsSelectionPage extends State<FeedsSelectionPage> {
  late List<Map<String, dynamic>> _selectedFeeds;
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _selectedFeeds = List<Map<String, dynamic>>.from(widget.selectedFeeds);
    _initializeControllers();
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initializeControllers() {
    for (final feed in _selectedFeeds) {
      final name = feed['name'] as String;
      if (!_controllers.containsKey(name)) {
        _controllers[name] = TextEditingController(
          text: feed['quantity']?.toString() ?? '',
        );
      }
    }
  }

  void _toggleFeed(InventoryItem feed, bool selected) {
    setState(() {
      if (selected) {
        if (!_selectedFeeds.any((f) => f['name'] == feed.name)) {
          _selectedFeeds.add({'name': feed.name, 'quantity': null});
          _controllers[feed.name] = TextEditingController();
        }
      } else {
        _selectedFeeds.removeWhere((f) => f['name'] == feed.name);
        _controllers[feed.name]?.dispose();
        _controllers.remove(feed.name);
      }
      widget.onSelectedFeedsChanged(_selectedFeeds);
      context.read<FarmReportProvider>().updateFeeds(
        _selectedFeeds,
      ); // <-- added (was missing)
    });
  }

  void _updateQuantity(String feedName, String value) {
    setState(() {
      final idx = _selectedFeeds.indexWhere((f) => f['name'] == feedName);
      if (idx != -1) {
        final quantity = double.tryParse(value);
        if (quantity != null && quantity >= 0) {
          final feed = widget.feeds.firstWhere((f) => f.name == feedName);
          if (quantity <= feed.quantity) {
            _selectedFeeds[idx]['quantity'] = quantity;
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'quantity_exceeds_stock'.tr(args: [feedName.tr()]),
                ),
              ),
            );
            _controllers[feedName]?.text =
                _selectedFeeds[idx]['quantity']?.toString() ?? '';
            return;
          }
        } else {
          _selectedFeeds[idx]['quantity'] = null;
        }
        widget.onSelectedFeedsChanged(_selectedFeeds);
        context.read<FarmReportProvider>().updateFeeds(_selectedFeeds);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.pop();
          },
        ),
        title: Text('farm_reports_entry'.tr()),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "select_feed_types_today".tr(),
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: CustomColors.text),
            ),
            const SizedBox(height: 8),
            if (widget.feeds.isEmpty) ...[
              Column(
                children: [
                  Text(
                    "cannot_see_any_feed_in_the_list".tr(),
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: CustomColors.text),
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: () {
                      context.push('/inventory/feedspage');
                    },
                    label: Text("add_feed_to_store".tr()),
                    icon: Icon(Icons.add),
                  ),
                ],
              ),
            ] else ...[
              ...widget.feeds.map((feed) {
                final isSelected = _selectedFeeds.any(
                  (f) => f['name'] == feed.name,
                );
                return CheckboxListTile(
                  value: isSelected,
                  title: Text(
                    '${feed.name.tr()} (${"stock".tr()}: ${feed.quantity} ${feed.unit.tr()})',
                  ),
                  onChanged: (checked) => _toggleFeed(feed, checked ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                );
              }),
              const SizedBox(height: 16),
              ..._selectedFeeds.map((f) {
                final feedName = f['name'] as String;
                final feed = widget.feeds.firstWhere(
                  (feed) => feed.name == feedName,
                );
                final unit = feed.unit;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feedName.tr(),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _controllers[feedName],
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText:
                            'How much ${feedName.tr()} did you use in ${unit.tr()}?',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        suffixText: unit.tr(),
                      ),
                      onChanged: (v) => _updateQuantity(feedName, v),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }),
            ],
            FeatureButton(
              label: "continue".tr(),
              onTap: () {
                context.push('/vaccine_selection');
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
