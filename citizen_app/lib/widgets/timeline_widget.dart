import 'package:flutter/material.dart';
import '../models/workflow_step_model.dart';
import 'workflow_step.dart';

class TimelineWidget extends StatelessWidget {
  final List<WorkflowStep> steps;

  const TimelineWidget({super.key, required this.steps});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: steps.length,
      itemBuilder: (context, index) {
        return WorkflowStepWidget(
          step: steps[index],
          isLast: index == steps.length - 1,
        );
      },
    );
  }
}
