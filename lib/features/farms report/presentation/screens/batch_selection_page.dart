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
        return Colors.grey.shade100;
      case 'kienyeji':
        return Colors.orange.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  void _alreadyReportedDialog(BuildContext context, String batchName) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(10),
        ),
        title: Text('Report Already Submitted'),
        content: Text(
          "A daily report for this batch has already been submitted today",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text("Ok"),
          ),
        ],
      ),
    );
  }

  Future<bool> _hasReportForToday(String batchId) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return false;

      final todayStr = DateTime.now().toIso8601String().split('T')[0];

      final dailyRecord = await Supabase.instance.client
      .from("daily_records")
      .select('id')
      .eq('user_id', userId)
      .eq('report_date', todayStr)
      .maybeSingle();

      if(dailyRecord == null) return false;

      final batchRecord = await Supabase.instance.client
      .from('batch_records')
      .select('id')
      .eq('daily_record_id', dailyRecord['id'])
      .eq('batch_id', batchId)
      .maybeSingle();
      
      return batchRecord != null;
    } catch (e) {
      debugPrint("Error checking todays's report status: $e");
      return false;
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
                            final exists = await _hasReportForToday(batch.id);
                            if (!context.mounted) return;

                            if (exists) {
                              _alreadyReportedDialog(context, batch.name);
                              return;
                            }
                            setState(() {
                              _selectedBatchId = batch.id;
                            });
                            context.read<FarmReportProvider>().setBatch(batch);
                            await Future.delayed(
                              const Duration(milliseconds: 100),
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
