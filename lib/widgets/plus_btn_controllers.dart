import 'package:flutter/material.dart';
import 'package:task_flow/widgets/new_project.dart';

import './new_task.dart';
import 'new_goal.dart';

// Controls the action of the '+' floating action button on different pages

void showNewTaskForm(BuildContext context) {
  // Arguments => context: The context for the modal sheet to be created in
  //
  // Opens up the NewTask modal sheet to add a new task

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    builder: (_) {
      return GestureDetector(
        onTap: () {},
        behavior: HitTestBehavior.opaque,
        child: const NewTask([]),
      );
    },
  );
}

void showEditTaskForm(BuildContext context, List<dynamic> data) {
  // Arguments => context: The context for the modal sheet to be created in
  //              data: The list of data of the existing task which was restarted
  //
  // Opens up the NewTask modal sheet and populates the fields
  // with the data of the existing task which was restarted

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    builder: (_) {
      return GestureDetector(
        onTap: () {},
        behavior: HitTestBehavior.opaque,
        child: NewTask(data),
      );
    },
  );
}

//new goal controller
void showNewGoalForm(BuildContext context) {
  // Arguments => context: The context for the modal sheet to be created in
  //
  // Opens up the NewGoal modal sheet to add a new goal

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    builder: (_) {
      return GestureDetector(
        onTap: () {},
        behavior: HitTestBehavior.opaque,
        child: const NewGoal([]),
      );
    },
  );
}
void showEditGoalForm(BuildContext context, List<dynamic> data) {
  // Arguments => context: The context for the modal sheet to be created in
  //              data: The list of data of the existing goal which was restarted
  //
  // Opens up the NewGoal modal sheet and populates the fields
  // with the data of the existing goal which was restarted

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    builder: (_) {
      return GestureDetector(
        onTap: () {},
        behavior: HitTestBehavior.opaque,
        child: NewGoal(data),
      );
    },
  );
}

// not yet implemented
void showNewProjectForm(BuildContext context) {
  // Arguments => context: The context for the modal sheet to be created in
  //
  // Opens up the NewProject modal sheet to add a new project

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    builder: (_) {
      return GestureDetector(
        onTap: () {},
        behavior: HitTestBehavior.opaque,
        child: NewProject(),
      );
    },
  );
}