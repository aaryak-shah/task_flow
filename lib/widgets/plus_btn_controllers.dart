import 'package:flutter/material.dart';

import './new_task.dart';
import 'new_goal.dart';

//new task controller
void showNewTaskForm(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    builder: (_) {
      return GestureDetector(
        onTap: () {},
        child: NewTask(),
        behavior: HitTestBehavior.opaque,
      );
    },
  );
}

//new goal controller
void showNewGoalForm(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    builder: (_) {
      return GestureDetector(
        onTap: () {},
        child: NewGoal([]),
        behavior: HitTestBehavior.opaque,
      );
    },
  );
}
void showEditGoalForm(BuildContext context, List<dynamic> data) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    builder: (_) {
      return GestureDetector(
        onTap: () {},
        child: NewGoal(data),
        behavior: HitTestBehavior.opaque,
      );
    },
  );
}

//new project controller
void showNewProjectForm(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    builder: (_) {
      return GestureDetector(
        onTap: () {},
        // child: NewProject(),
        behavior: HitTestBehavior.opaque,
      );
    },
  );
}