import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ikuku/features/batches/model/chicken_batch_model.dart';
import 'package:ikuku/theme/app_theme.dart';

class BatchCard extends StatelessWidget {
  final ChickenBatch batch;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const BatchCard({
    super.key,
    required this.batch,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
              // height: 90,
              width: 30,
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
                  Text(
                    "${"Bird type".tr()}: ${batch.typeOfBird}",
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        "${"chicken".tr()}: ${batch.initialCount}",
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        ", ${"age".tr()}: ${batch.age} ${batch.ageUnit} ",
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 24),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildActionButton(
                  icon: Icons.edit,
                  label: "Edit".tr(),
                  color: Colors.orange,
                  onTap: onEdit,
                ),
                const SizedBox(height: 12),
                _buildActionButton(
                  icon: Icons.delete_outline,
                  label: "Remove".tr(),
                  color: Colors.red,
                  onTap: onDelete,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildActionButton({
  required IconData icon,
  required String label,
  required Color color,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
      ],
    ),
  );
}
