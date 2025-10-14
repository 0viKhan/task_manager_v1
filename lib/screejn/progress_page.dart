import 'package:flutter/material.dart';
import '../data/models/task_models.dart';
import '../data/service/Network_caller.dart';
import '../design/widgets/TaskCard.dart';
import '../design/widgets/snack_bar_message.dart';
import '../utills/Urls.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  bool _getProgressTaskInProgress = false;
  List<TaskModel> _progressnewTaskList = [];

  @override
  void initState() {
    super.initState();
    _getProgressTaskList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: _getProgressTaskInProgress
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _progressnewTaskList.length,
        itemBuilder: (context, index) {
          final task = _progressnewTaskList[index];

          return TaskCard(
            taskType: TaskType.progress,
            // Pass task details if TaskCard supports it
            // title: task.title,
            // description: task.description,
          );
        },
      ),
    );
  }

  Future<void> _getProgressTaskList() async {
    setState(() {
      _getProgressTaskInProgress = true;
    });

    NetworkResponse response =
    await NetworkCaller.getRequest(url: Urls.getProgressTaskUrl);

    if (response.isSuccess) {
      List<TaskModel> list = [];
      for (Map<String, dynamic> jsonData in response.body!['data']) {
        list.add(TaskModel.fromJson(jsonData));
      }
      _progressnewTaskList = list;
    } else {
      showSnackbarMessage(
          context, response.errorMessage ?? "Failed to load tasks");
    }

    setState(() {
      _getProgressTaskInProgress = false;
    });
  }
}
