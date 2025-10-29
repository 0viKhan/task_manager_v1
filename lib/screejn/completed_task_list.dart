import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:task_manager/data/models/task_models.dart';
import 'package:task_manager/data/service/Network_caller.dart';
import 'package:task_manager/design/widgets/TaskCard.dart';
import 'package:task_manager/design/widgets/screen_background.dart';
import 'package:task_manager/design/widgets/snack_bar_message.dart';
import 'package:task_manager/utills/Urls.dart';

import 'new_task_list_screen.dart';

class CompletedTaskListScreen extends StatefulWidget {
  const CompletedTaskListScreen({super.key});

  @override
  State<CompletedTaskListScreen> createState() =>
      _CompletedTaskListScreenState();
}

class _CompletedTaskListScreenState extends State<CompletedTaskListScreen> {
  bool _getCompletedTaskListInProgress = false;
  List<TaskModel> _CompletedTaskList = [];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getCompletedTaskList();
    });
  }

  Widget build(BuildContext context) {
    return ScreenBackground(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Visibility(
          visible: _getCompletedTaskListInProgress==false,
          replacement: CircularProgressIndicator(),
          child: ListView.builder(
            itemCount: _CompletedTaskList.length,
            itemBuilder: (context, index) {
              return TaskCard(
                taskType: TaskType.completed,
                taskModel: _CompletedTaskList[index],
                onStatusUpdate: () {
                  _getCompletedTaskList();
                },
              );
            },
          ),
        ),
      
      ),
    );
  }

  Future<void> _getCompletedTaskList() async {
    _getCompletedTaskListInProgress = true;
    setState(() {});

    NetworkResponse response =
        await NetworkCaller.getRequest(url: Urls.getCompletedTaskUrl);
    if (response.isSuccess) {
      List<TaskModel> list = [];
      for (Map<String, dynamic> jsonData in response.body!['data']) {
        list.add(TaskModel.fromJson(jsonData));
      }
      _CompletedTaskList = list;
    } else {
      showSnackBarMessage(context, response.errorMessage!);
    }
    _getCompletedTaskListInProgress = false;
    setState(() {});
  }
}
