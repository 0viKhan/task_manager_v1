import 'package:flutter/material.dart';
import '../../data/models/task_models.dart';
import '../../data/service/network_caller.dart';
import '../../screejn/new_task_list_screen.dart';
import '../../utills/urls.dart';
import 'centered_circular_progress_indicator.dart';
import 'snack_bar_message.dart';


class TaskCard extends StatefulWidget {
  const TaskCard({
    super.key,
    required this.taskType,
    required this.taskModel,
    required this.onStatusUpdate,

  });

  final TaskType taskType;
  final TaskModel taskModel;
  final VoidCallback onStatusUpdate;

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  bool _updateTaskStatusInProgress = false;
  bool _deleteTaskInProgress=false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.taskModel.title, style: Theme.of(context).textTheme.titleMedium),
            Text(widget.taskModel.description, style: const TextStyle(color: Colors.black54)),
            Text('Created: ${_formatDateTime(widget.taskModel.createdDate)}'),

            const SizedBox(height: 8),
            Row(
              children: [
                Chip(
                  label: Text(_getTaskTypeName(), style: const TextStyle(color: Colors.white)),
                  backgroundColor: _getTaskChipColor(),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const Spacer(),
                Visibility(
                    visible: !_deleteTaskInProgress,
                    replacement: CircularProgressIndicator(),

                    child: IconButton(onPressed: _deleteTask, icon: const Icon(Icons.delete))),
                Visibility(
                  visible: !_updateTaskStatusInProgress,
                  replacement: const CenteredCircularProgressIndicator(),
                  child: IconButton(
                    onPressed: _showEditTaskStatusDialog,
                    icon: const Icon(Icons.edit),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getTaskChipColor(

      ) {
    switch (widget.taskType) {
      case TaskType.tNew:
        return Colors.blue;
      case TaskType.progress:
        return Colors.purple;
      case TaskType.completed:
        return Colors.green;
      case TaskType.cancelled:
        return Colors.red;
    }
  }

  String _getTaskTypeName() {
    switch (widget.taskType) {
      case TaskType.tNew:
        return 'New';
      case TaskType.progress:
        return 'Progress';
      case TaskType.completed:
        return 'Completed';
      case TaskType.cancelled:
        return 'Cancelled';
    }
  }

  void _showEditTaskStatusDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Change Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _statusOption('New', TaskType.tNew),
              _statusOption('In Progress', TaskType.progress),
              _statusOption('Completed', TaskType.completed),
              _statusOption('Cancelled', TaskType.cancelled),
            ],
          ),
        );
      },
    );
  }

  ListTile _statusOption(String title, TaskType type) {
    return ListTile(
      title: Text(title),
      trailing: widget.taskType == type ? const Icon(Icons.check) : null,
      onTap: () {
        if (widget.taskType != type) {
          _updateTaskStatus(title);
        }
      },
    );
  }

  Future<void> _updateTaskStatus(String status) async {
    Navigator.pop(context);
    setState(() => _updateTaskStatusInProgress = true);

    final response = await NetworkCaller.getRequest(
      url: Urls.updateTaskStatusUrl(widget.taskModel.id, status),
    );

    setState(() => _updateTaskStatusInProgress = false);

    if (response.isSuccess) {
      widget.onStatusUpdate();
    } else {
      if (mounted) showSnackBarMessage(context, response.errorMessage ?? 'Update failed');
    }
  }

  Future<void> _deleteTask() async {
    final confirm=await showDialog(context: context,
        builder: (ctx)=>AlertDialog(
          title: const Text('DeleteTask'),
          content: const Text('Are You sure'),
          actions: [
            TextButton(onPressed: ()=>Navigator.pop(ctx,false),
                child: const Text('Cancel')),
            ElevatedButton(onPressed: ()=>Navigator.pop(ctx,true),

                child: const Text('Delete'))
          ],
        )


    );
    if(confirm!=true) return;
    setState(()=>_deleteTaskInProgress=true);
    final response =await NetworkCaller.getRequest(url: Urls.deleteTaskUrl(widget.taskModel.id));
    if(response.isSuccess)
      {
        if(mounted)
          showSnackBarMessage(context,'Task Deleted');
        widget.onStatusUpdate();
      }

    else
    {
 if(mounted)
   showSnackBarMessage(context, response.errorMessage??'Delete Failed');
    }
  }
  String _formatDateTime(String rawDate) {
    try {
      final dateTime = DateTime.parse(rawDate); // No need for .toLocal() if already local
      final date = '${dateTime.day.toString().padLeft(2, '0')} '
          '${_monthName(dateTime.month)} ${dateTime.year}';
      final time = TimeOfDay.fromDateTime(dateTime).format(context);
      return '$date, $time';
    } catch (_) {
      return rawDate;
    }
  }

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];


  }





}