import 'package:flutter/material.dart';
import 'package:ikuku/features/home/presentation/widgets/analytics.dart';
import 'package:ikuku/features/home/presentation/widgets/quick_actions_container.dart';
import 'package:ikuku/features/home/presentation/widgets/salutation_widget.dart';
import 'package:ikuku/features/home/provider/analytics_provider.dart';
import 'package:ikuku/features/home/provider/tutorial_provider.dart';

import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
   

    Future.microtask(() async {
      if (mounted) {
        Provider.of<TutorialProvider>(
          context,
          listen: false,
        ).maybeShowTutorial(context);
        Provider.of<AnalyticsProvider>(context, listen: false).fetchSummary();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 15,
        children:const [SalutationWidget(), Analytics(), QuickActionsContainer()],
      ),
    );
  }
}
