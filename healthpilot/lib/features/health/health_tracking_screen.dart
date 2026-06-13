import 'package:flutter/material.dart';
import 'package:healthpilot/features/health/health_provider.dart';
import 'package:provider/provider.dart';

import '../../theme/app_theme.dart';
import 'health_profile_screen.dart';

class HealthTrackingScreen extends StatelessWidget {
  const HealthTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final conditions = context.watch<HealthProvider>().conditions;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          style: AppTheme.circleBackButtonStyle(context),
        ),
        title: const Text(
          'Health Tracking',
          style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontWeight: FontWeight.w600,
              fontSize: 18),
        ),
        actions: [
          SizedBox(
            height: size.height * 0.035,
            width: size.width * 0.2,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color.fromRGBO(252, 34, 34, 0.25),
                padding: EdgeInsets.symmetric(vertical: size.height * 0.001),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(size.width * 0.015),
                ),
              ),
              onPressed: () => context.read<HealthProvider>().clearConditions(),
              child: const Text(
                'Clear History',
                style: TextStyle(
                  color: Color.fromRGBO(252, 34, 34, 1),
                  fontSize: 10,
                  fontFamily: 'PlusJakartaSans',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          SizedBox(width: size.width * 0.04),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.07, vertical: size.height * 0.02),
          child: conditions.isEmpty
              ? const Center(
                  child: Text(
                    'No health tracking added',
                    style: TextStyle(
                      color: Color.fromRGBO(110, 182, 255, 1),
                      fontSize: 20,
                      fontFamily: 'PlusJakartaSans',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: conditions.length,
                  itemBuilder: (context, index) {
                    return HealthTracking(
                      disorder: conditions[index].name,
                      date: conditions[index].loggedAt,
                    );
                  },
                ),
        ),
      ),
    );
  }
}
