import 'package:flutter/material.dart';
import 'package:task_manager/design/widgets/centered_circular_progress_indicator.dart';
import 'package:task_manager/design/widgets/snack_bar_message.dart';
import '../../data/models/task_models.dart';
import '../../data/models/task_status_count.dart';
import '../../data/service/network_caller.dart';
import '../../utills/urls.dart';
import '../design/widgets/TaskCard.dart';
import '../design/widgets/task_count_summary.dart';
import 'add_new_task.dart';

enum TaskType { tNew, progress, completed, cancelled }


class NewTaskListScreen extends StatefulWidget {
  const NewTaskListScreen({super.key});
  static const String name = "NewTaskListScreen";

  @override
  State<NewTaskListScreen> createState() => _NewTaskListScreenState();
}

class _NewTaskListScreenState extends State<NewTaskListScreen> {
  bool _isLoadingTasks = false;
  bool _isLoadingSummary = false;

  List<TaskModel> _tasks = [];
  List<TaskStatusCountModel> _taskSummary = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchTasks();
      _fetchTaskSummary();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Task List")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _buildTaskSummary(),
            const SizedBox(height: 16),
            _buildTaskList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddTask,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTaskSummary() {
    if (_isLoadingSummary) {
      return const SizedBox(
          height: 150, child: CenteredCircularProgressIndicator());
    }

    if (_taskSummary.isEmpty) {
      return const SizedBox(
          height: 150, child: Center(child: Text('No summary data available')));
    }

    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _taskSummary.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = _taskSummary[index];
          return SizedBox(
            width: 140,
            child: TaskCountSummaryCard(title: item.id, count: item.count),
          );
        },
      ),
    );
  }

  Widget _buildTaskList() {
    if (_isLoadingTasks) {
      return const Expanded(child: CenteredCircularProgressIndicator());
    }

    if (_tasks.isEmpty) {
      return const Expanded(child: Center(child: Text('No tasks available')));
    }

    return Expanded(
      child: ListView.builder(
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          final task = _tasks[index];
          return TaskCard(
            taskModel: task,
            taskType: _mapStatusToTaskType(task.status),
            onStatusUpdate: _fetchTasks,
          );
        },
      ),
    );
  }

  TaskType _mapStatusToTaskType(String? status) {
    final normalized = (status ?? '').toLowerCase().trim();
    switch (normalized) {
      case 'new':
      case 'tnew':
      case 'created':
        return TaskType.tNew;
      case 'progress':
      case 'inprogress':
      case 'in progress':
        return TaskType.progress;
      case 'completed':
      case 'done':
        return TaskType.completed;
      case 'cancelled':
      case 'canceled':
        return TaskType.cancelled;
      default:
        return TaskType.tNew;
    }
  }

  Future<void> _fetchTasks() async {
    setState(() => _isLoadingTasks = true);

    final response = await NetworkCaller.getRequest(url: Urls.getNewTaskUrl);
    if (response.isSuccess && response.body?['data'] is List) {
      _tasks = (response.body!['data'] as List)
          .map((json) => TaskModel.fromJson(json))
          .toList()
        ..sort((a, b) =>
            DateTime.parse(b.createdDate).compareTo(
                DateTime.parse(a.createdDate)));
    } else {
      if (mounted) {
        showSnackBarMessage(
            context, response.errorMessage ?? 'Failed to load tasks.');
      }
    }

    if (mounted) setState(() => _isLoadingTasks = false);
  }

  Future<void> _fetchTaskSummary() async {
    setState(() => _isLoadingSummary = true);

    final response = await NetworkCaller.getRequest(
        url: Urls.getTaskStatusCountUrl);
    if (response.isSuccess && response.body?['data'] is List) {
      Map<String, int> mergedSummary = {};
      for (var json in response.body!['data'] as List) {
        String rawId = json['_id']?.toString() ?? 'Unknown';
        String normalizedId = _normalizeStatus(rawId);
        int count = (json['sum'] ?? 0).toInt();
        mergedSummary[normalizedId] =
            (mergedSummary[normalizedId] ?? 0) + count;
      }
      _taskSummary = mergedSummary.entries.map((e) =>
          TaskStatusCountModel(id: e.key, count: e.value)).toList();
    } else {
      if (mounted) {
        showSnackBarMessage(
            context, response.errorMessage ?? 'Failed to load task summary.');
      }
    }

    if (mounted) setState(() => _isLoadingSummary = false);
  }

  String _normalizeStatus(String status) {
    final normalized = status.toLowerCase().trim();
    switch (normalized) {
      case 'new':
      case 'tnew':
      case 'created':
        return 'New';
      case 'progress':
      case 'Progress':

      case 'inprogress':
      case 'in progress':
        return 'Progress';
      case 'completed':
      case 'done':
        return 'Completed';
      case 'cancelled':
      case 'canceled':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  Future<void> _navigateToAddTask() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AddNewTaskScreen(onTaskAdded: () {
              _fetchTasks();
              _fetchTaskSummary();
            }),
      ),
    );
  }
}