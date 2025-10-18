import 'package:flutter/material.dart';
import '../data/models/task_models.dart';
import '../data/models/task_status_count.dart';

import '../data/service/Network_caller.dart';
import '../design/widgets/TaskCard.dart';
import '../design/widgets/centered_circular_progress_indicator.dart';
import '../design/widgets/snack_bar_message.dart';
import '../design/widgets/task_count_summary.dart';
import '../utills/Urls.dart';
import 'add_new_task.dart';


class NewTaskListScreen extends StatefulWidget {
  const NewTaskListScreen({super.key});

  @override
  State<NewTaskListScreen> createState() => _NewTaskListScreenState();
}

class _NewTaskListScreenState extends State<NewTaskListScreen> {
  bool _getNewTasksInProgress = false;
  bool _getTaskStatusCountInProgress = false;

  List<TaskModel> _newTaskList = [];
  List<TaskStatusCountModel> _taskStatusCountList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getNewTaskList();
      _getTaskStatusCountList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            const SizedBox(height: 16),
            SizedBox(
              height: 100,
              child: Visibility(
                visible: !_getTaskStatusCountInProgress,
                replacement: const CenteredCircularProgressIndicator(),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _taskStatusCountList.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 4),
                  itemBuilder: (context, index) {
                    final item = _taskStatusCountList[index];
                    return TaskCountSummaryCard(
                      title: item.id,
                      count: item.count,
                    );
                  },
                ),
              ),
            ),
            Expanded(
              child: Visibility(
                visible: !_getNewTasksInProgress,
                replacement: const CenteredCircularProgressIndicator(),
                child: ListView.builder(
                  itemCount: _newTaskList.length,
                  itemBuilder: (context, index) {
                    return TaskCard(
                      taskType: TaskType.tNew,


                      taskModel: _newTaskList[index],
                      onStatusUpdate: () {
                        _getNewTaskList();
                        _getTaskStatusCountList();
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onTapAddNewTaskButton,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _getNewTaskList() async {
    _getNewTasksInProgress = true;
    setState(() {});

    final response = await NetworkCaller.getRequest(url: Urls.getNewTaskUrl);

    if (response.isSuccess) {
      _newTaskList = (response.body!['data'] as List)
          .map((json) => TaskModel.fromJson(json))
          .toList();
    } else {
      if (mounted) showSnackBarMessage(context, response.errorMessage ?? 'Failed to load tasks');
    }

    _getNewTasksInProgress = false;
    if (mounted) setState(() {});
  }

  Future<void> _getTaskStatusCountList() async {
    _getTaskStatusCountInProgress = true;
    setState(() {});

    final response = await NetworkCaller.getRequest(url: Urls.getTaskStatusCountUrl);

    if (response.isSuccess) {
      _taskStatusCountList = (response.body!['data'] as List)
          .map((json) => TaskStatusCountModel.fromJson(json))
          .toList();
    } else {
      if (mounted) showSnackBarMessage(context, response.errorMessage ?? 'Failed to load summary');
    }

    _getTaskStatusCountInProgress = false;
    if (mounted) setState(() {});
  }

  void _onTapAddNewTaskButton() {
    Navigator.pushNamed(context, AddNewTaskScreen.name);
  }
}
