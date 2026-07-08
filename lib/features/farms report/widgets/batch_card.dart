import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ikuku/features/batches/model/chicken_batch_model.dart';
import 'package:ikuku/theme/app_theme.dart';

class BatchCard extends StatelessWidget {
  final ChickenBatch batch;

  const BatchCard({
    super.key,
    required this.batch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 100,
      width: 100,
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade500, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Container(
              height: 90,
              width: 50,
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    batch.name,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: CustomColors.text,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        "${batch.initialCount} ${batch.typeOfBird}",
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: CustomColors.textDisabled,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(width: 25),
                      Text(
                        "${batch.age} ${batch.ageUnit} ${"old".tr()}",
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: CustomColors.textDisabled,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      )
    );
  }
}