import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:task_manager/data/models/task_models.dart';
import 'package:task_manager/data/service/Network_caller.dart';
import 'package:task_manager/design/widgets/TaskCard.dart';
import 'package:task_manager/design/widgets/snack_bar_message.dart';
import 'package:task_manager/utills/Urls.dart';

import 'new_task_list_screen.dart';

class CancelledTaskListScreen extends StatefulWidget {
  const CancelledTaskListScreen({super.key});

  @override
  State<CancelledTaskListScreen> createState() =>
      _CancelledTaskListScreenState();
}

class _CancelledTaskListScreenState extends State<CancelledTaskListScreen> {
  bool _getCancelledTaskListInProgress = false;
  List<TaskModel> _CancelledTaskList = [];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getCompletedTaskList();
    });
  }

  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Visibility(
        visible: _getCancelledTaskListInProgress==false,
        replacement: CircularProgressIndicator(),
        child: ListView.builder(
          itemCount: _CancelledTaskList.length,
          itemBuilder: (context, index) {
            return TaskCard(
              taskType: TaskType.completed,
              taskModel: _CancelledTaskList[index],
              onStatusUpdate: () {
                _getCompletedTaskList();
              },
            );
          },
        ),
      ),

    );
  }

  Future<void> _getCompletedTaskList() async {
    _getCancelledTaskListInProgress = true;
    setState(() {});

    NetworkResponse response =
    await NetworkCaller.getRequest(url: Urls.getCancelledTaskUrl);
    if (response.isSuccess) {
      List<TaskModel> list = [];
      for (Map<String, dynamic> jsonData in response.body!['data']) {
        list.add(TaskModel.fromJson(jsonData));
      }
      _CancelledTaskList = list;
    } else {
      showSnackBarMessage(context, response.errorMessage!);
    }
    _getCancelledTaskListInProgress = false;
    setState(() {});
  }
}
