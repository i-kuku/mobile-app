import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:ikuku/features/batches/model/chicken_batch_model.dart';
import 'package:ikuku/features/batches/presentation/Widgets/batch_card.dart';
import 'package:ikuku/features/batches/presentation/Widgets/pop_up.dart';
import 'package:ikuku/features/batches/provider/batch_provider.dart';
import 'package:ikuku/shared/widgets/feature_button.dart';
import 'package:ikuku/theme/app_theme.dart';
import 'package:provider/provider.dart';

class ManageBatchPage extends StatefulWidget {
  const ManageBatchPage({super.key});

  @override
  State<ManageBatchPage> createState() => _ManageBatchPageState();
}

class _ManageBatchPageState extends State<ManageBatchPage> {

@override

void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BatchProvider>(context, listen: false).fetchBatches();
    });
  }
  void _handleremovebatchsequence(BuildContext context, ChickenBatch batch) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopUp(
        icon: SvgPicture.asset(
          'assets/icons/remove-alert.svg',
          height: 150,
          width: 150,
          fit: BoxFit.contain,
        ),
        messagebefore: "Are_you_sure_you_want_to \nremove_this_batch?".tr(),
        mainButtonText: "yes_i'm_sure".tr(),
        secondaryButtonText: "cancel".tr(),
        onMainAction: () {
          Navigator.pop(context);
          _showsuccessRemoved(context, batch);
        },
      ),
    );
  }

  void _showsuccessRemoved(BuildContext context, ChickenBatch batch) async{
    try {
    await Provider.of<BatchProvider>(context, listen: false).removeBatch(batch.id);

    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          Future.delayed(const Duration(seconds: 1), () {
            if (dialogContext.mounted) {
              Navigator.pop(dialogContext);
            }
          });

          return PopUp(
            icon: Image.asset(
              'assets/icons/tip-chicken.png',
              height: 154,
              width: 151,
              fit: BoxFit.contain,
            ),
            batchName: batch.name,
            messageAfter: " has_been_removed".tr(),
          );
        },
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not complete deletion request: $e')),
      );
    }
  }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: (){
            context.go('/');
          },
        ),
        title: Text(
          "Batches".tr(),
          style: Theme.of(
            context,
          ).textTheme.titleLarge!.copyWith(color: CustomColors.text),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.notifications_none, color: Colors.black),
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
          child: Consumer<BatchProvider>(
            builder: (context, provider, child) {
              if (provider.batches.isEmpty) {
                
                return _buildEmptyState(context);
              } else {
                return _buildActiveState(context, provider);
              }
            },
          ),
        
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          "manage_batches".tr(),
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            color: CustomColors.text,
            fontSize: 30,
          ),
        ),
        SizedBox(height: 10),
        Container(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              Image.asset(
                'assets/icons/tip-chicken.png',
                height: 50,
                width: 49.03,
              ),
              SizedBox(width: 5),
              Text(
                "tip_batch_definition".tr(),
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: CustomColors.textDisabled,fontSize: 18,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        Text(
          "my_batches".tr(),
          style: Theme.of(
            context,
          ).textTheme.titleLarge!.copyWith(color: CustomColors.text, fontSize: 20),
        ),
        SizedBox(height: 30),
        Center(
          child: Column(
            children: [
              Image.asset('assets/icons/amico.png', width: 130, height: 130),
              Text(
                "you_have_no_batches_yet".tr(),
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: CustomColors.textDisabled,
                  fontWeight: FontWeight.w400,
                  fontSize: 18,
                ),
              ),
              Text(
                "the_batches_You_create_will_appear_here".tr(),
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: CustomColors.textDisabled,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 16),
              FeatureButton(
                onTap: () {
                  context.push('/create_batch_page');
                },
                label:"create_a_batch".tr(),
                ),
            ],
              ),
        ),
        
      ]
          );
  }

  Widget _buildActiveState(BuildContext context, BatchProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          "manage_batches".tr(),
          style: Theme.of(
            context,
          ).textTheme.titleLarge!.copyWith(color: CustomColors.text,fontSize: 30),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              onPressed: () => context.push('/create_batch_page'),
              icon: Icon(Icons.add_circle, color: CustomColors.text, size: 30),
            ),
            Text(
              "add_new_batch".tr(),
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: CustomColors.primary,
                fontSize: 18,
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            itemCount: provider.batches.length,
            itemBuilder: (context, index) {
              final batch = provider.batches[index];
              return BatchCard(
                batch: batch,
                onEdit: () {
                  context.push(
                    '/edit_batch_page',
                    extra: {
                      'name': batch.name,
                      'typeOfBird': batch.typeOfBird,
                      'initialCount': batch.initialCount.toString(),
                      'age': batch.age.toString(),
                      'ageUnit': batch.ageUnit,
                    },
                  );
                },
                onDelete: () {
                  _handleremovebatchsequence(context, batch);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
