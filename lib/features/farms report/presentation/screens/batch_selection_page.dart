import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ikuku/features/batches/model/chicken_batch_model.dart';

import 'package:ikuku/features/farms%20report/presentation/widgets/batch_card.dart';
import 'package:ikuku/features/farms%20report/provider/farm_report_provider.dart';
import 'package:ikuku/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BatchSelectionPage extends StatefulWidget {
  const BatchSelectionPage({super.key});

  @override
  State<BatchSelectionPage> createState() => _BatchSelectionPageState();
}

class _BatchSelectionPageState extends State<BatchSelectionPage> {
  late Future<List<ChickenBatch>> _batchesFuture;
  String? _selectedBatchId;

  @override
  void initState() {
    super.initState();
    _batchesFuture = _fetchUserBatches();
  }

  Future<List<ChickenBatch>> _fetchUserBatches() async {
    final session = Supabase.instance.client.auth.currentSession;

    if (session == null) {
      debugPrint('User is not logged in. Redirect to login screen.');
      return [];
    }
    final userId = session.user.id;
    final response = await Supabase.instance.client
        .from('batches')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    final List<dynamic> data = response;
    return data
        .map((json) => ChickenBatch.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Color _getBirdTypeColor(String type) {
    switch (type.toLowerCase().trim()) {
      case 'broiler':
        return Colors.green.shade100;
      case 'layer':
        return Colors.grey.shade100; // Visible dark yellow
      case 'kienyeji':
        return Colors.orange.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          color: CustomColors.primary,
          onPressed: () {
            context.pop();
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: Text(
          "farm_reports_entry".tr(),
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            fontSize: 24,
            color: CustomColors.primary,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Text(
                "select_batch_message".tr(),
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: CustomColors.text,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: FutureBuilder<List<ChickenBatch>>(
                  future: _batchesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Error loading batches: ${snapshot.error}'),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text('No active batches found.'),
                      );
                    }

                    final batches = snapshot.data!;
                    return ListView.builder(
                      itemCount: batches.length,
                      itemBuilder: (context, index) {
                        final batch = batches[index];
                        return BatchCard(
                          batch: batch,
                          onTap: () async {
                            setState(() {
                              _selectedBatchId = batch.id;
                            });
                            context.read<FarmReportProvider>().setBatch(batch);
                            await Future.delayed(
                              const Duration(milliseconds: 300),
                            );

                            if (!context.mounted) return;

                            if (mounted) {
                              await context.push(
                                '/calendar_page',
                                extra: batch.id,
                              );
                            }
                          },
                          birdTypeColor: _getBirdTypeColor(batch.typeOfBird),
                          isSelected: _selectedBatchId == batch.id,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
