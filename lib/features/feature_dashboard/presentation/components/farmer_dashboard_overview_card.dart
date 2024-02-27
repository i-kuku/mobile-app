import 'package:flutter/material.dart';

class FarmerDashboardOverviewCard extends StatefulWidget {
  const FarmerDashboardOverviewCard({super.key});

  @override
  State<FarmerDashboardOverviewCard> createState() => _FarmerDashboardOverviewCardState();
}

class _FarmerDashboardOverviewCardState extends State<FarmerDashboardOverviewCard> {
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 3 / 1,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Text('Hello'),
      ),
    );
  }
}
