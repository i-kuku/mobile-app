import 'package:flutter/material.dart';

import '../../../../core/presentation/components/custom_text_field.dart';

class GroupRegistration extends StatefulWidget {
  const GroupRegistration({super.key});

  @override
  State<GroupRegistration> createState() => _GroupRegistrationState();
}

class _GroupRegistrationState extends State<GroupRegistration> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //  group name
        CustomTextField(label: 'Group name'),

        const SizedBox(height: 16),

        //  group name
        CustomTextField(label: 'Group location'),

        const SizedBox(height: 16),

        Row(
          children: [
            const Expanded(
              child: CustomTextField(
                label: 'How many farmers are in the group?'
              ),
            ),
            Container(
              width: 100,
              height: 100,
              color: Colors.red,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_drop_up_rounded, size: 30),
                  Icon(Icons.arrow_drop_up_rounded, size: 30),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
