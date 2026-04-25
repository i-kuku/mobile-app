import 'package:flutter/material.dart';
import 'package:ikuku/features/batches/model/chicken_batch_model.dart';

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
      height: 66,
      width: 100,
      margin: EdgeInsets.only(bottom:12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200,width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Container(
              height: 56,
              width: 175,
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
              ),
              child:Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:[
                  Text(
                    batch.name,
                    style:const TextStyle(fontWeight:FontWeight.bold),
                  ),
                  const SizedBox(height:10),
                  Row(
                    children: [
                      Text("${batch.initialNumberOfBirds} ${batch.typeOfBird}",
                      style: TextStyle(color:Colors.grey.shade200,fontSize: 13),
                      ),
                      const SizedBox(width:25),
                      Text("${batch.age} ${batch.ageUnit} old",
                      style: TextStyle(color: Colors.grey.shade600,fontSize: 13),
                      )
                    ],
                  )
                ]
              ),
            ),
            ),
            const SizedBox(width: 60),
            Container(
              height: 175,
              width: 56,
              padding: EdgeInsets.only(right: 16,top: 12,bottom: 12),
              child:Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildActionButton(
                    icon:Icons.edit,
                    label:"edit",
                    color:Colors.orange,
                    onTap:onEdit,
                  ),
                  const SizedBox(height: 12),
                  _buildActionButton(
                    icon:Icons.delete_outline,
                    label:"Remove",
                    color:Colors.red,
                    onTap:onDelete,
                  ),
                ],
              )
            )
        ],
      ),
    );
  }
}

Widget _buildActionButton({
  required IconData icon, 
  required String label, 
  required Color color, 
  required VoidCallback onTap
}) {
  return InkWell(
    onTap: onTap,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    ),
  );
}