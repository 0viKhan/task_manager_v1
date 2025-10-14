import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:task_manager/data/models/task_models.dart';
import 'package:task_manager/data/service/Network_caller.dart';
import 'package:task_manager/design/widgets/snack_bar_message.dart';
import 'package:task_manager/screejn/add_new_task.dart';
import 'package:task_manager/utills/Urls.dart';

class NewTaskListScreen extends StatefulWidget {
  const NewTaskListScreen({super.key});

  @override
  State<NewTaskListScreen> createState() => _NewTaskListScreenState();
}

class _NewTaskListScreenState extends State<NewTaskListScreen> {
  bool _getNewTaskInProgress = false;
  List<TaskModel> newTaskList = [];

  @override
  void initState() {
    super.initState();
    _getNewTaskList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Task List")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 4,
                itemBuilder: (context, index) {
                  final types = ["New", "Progress", "Completed", "Cancelled"];
                  return TaskCountSummary(
                    title: types[index],
                    count: (index + 1) * 5,
                    taskType: types[index],
                  );
                },
                separatorBuilder: (context, index) => const SizedBox(width: 10),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _getNewTaskInProgress
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                itemCount: newTaskList.length,
                itemBuilder: (context, index) {
                  final task = newTaskList[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.task,
                                    size: 30,
                                    color: Colors.orange,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    task.title ?? "Untitled Task",
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(task.description ?? "No details"),
                              const SizedBox(height: 4),
                              Text("Time: ${task.createdDate ?? "N/A"}"),
                              const SizedBox(height: 4),
                              Chip(
                                label: Text(
                                  task.status ?? "New",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                                backgroundColor: Colors.blue,
                              ),
                            ],
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue),
                                  onPressed: () {},
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
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

  void _onTapAddNewTaskButton() async {
    await Navigator.pushNamed(context, AddNewTask.name);
    _getNewTaskList(); // refresh after returning
  }

  Future<void> _getNewTaskList() async {
    _getNewTaskInProgress = true;
    setState(() {});

    NetworkResponse response =
    await NetworkCaller.getRequest(url: Urls.getNewTaskUrl);

    _getNewTaskInProgress = false;

    if (response.isSuccess) {
      List<TaskModel> list = [];
      for (Map<String, dynamic> jsonData in response.body!['data']) {
        list.add(TaskModel.fromJson(jsonData));
      }
      newTaskList = list;
    } else {
      showSnackbarMessage(
          context, response.errorMessage ?? "Failed to load tasks");
    }

    setState(() {});
  }
}

class TaskCountSummary extends StatelessWidget {
  const TaskCountSummary({
    super.key,
    required this.title,
    required this.count,
    required this.taskType,
  });

  final String title;
  final int count;
  final String taskType;

  Color _getTaskChipColour() {
    switch (taskType.toLowerCase()) {
      case 'new':
        return Colors.blue;
      case 'progress':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$count',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Chip(
              label: Text(
                title,
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: _getTaskChipColour(),
            ),
          ],
        ),
      ),
    );
  }
}



