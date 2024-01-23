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

        CustomTextField(
          label: 'How many farmers are in the group?',
        ),

        const SizedBox(height: 16),

        CustomTextField(
          label: 'How many farmers are female?',
        ),

        const SizedBox(height: 16),

        CustomTextField(
          label: 'How many farmers are male?',
        ),
      ],
    );
  }
}
