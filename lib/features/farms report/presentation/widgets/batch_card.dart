import 'package:flutter/material.dart';
import 'package:ikuku/features/batches/model/chicken_batch_model.dart';
import 'package:ikuku/theme/app_theme.dart';

class BatchCard extends StatelessWidget {
  final ChickenBatch batch;
  final bool isSelected;
  final VoidCallback? onTap;
  final Color birdTypeColor;

  const BatchCard({
    super.key,
    required this.batch,
    this.onTap,
    required this.birdTypeColor,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: isSelected ? Colors.yellow.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 12,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
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

                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: birdTypeColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            " ${batch.typeOfBird}",
                            style: Theme.of(context).textTheme.bodyLarge!
                                .copyWith(color: Colors.grey, fontSize: 12),
                          ),
                        ),
                        SizedBox(width: 10),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Text(
                            "${"Batch Age"}: ${batch.age} ${batch.ageUnit} ",
                            style: Theme.of(context).textTheme.bodyLarge!
                                .copyWith(color: Colors.grey, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isSelected) ...[
                Icon(Icons.check_circle, color: Colors.orange, size: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
