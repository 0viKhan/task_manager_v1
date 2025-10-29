import 'package:flutter/material.dart';
import 'package:task_manager/data/service/network_caller.dart' hide NetworkResponse, NetworkCaller;
import '../data/service/Network_caller.dart' show NetworkResponse, NetworkCaller;
import '../design/widgets/centered_circular_progress_indicator.dart';
import '../design/widgets/screen_background.dart';
import '../design/widgets/snack_bar_message.dart';
import '../design/widgets/tm_app_bar.dart';
import '../utills/Urls.dart';

class AddNewTaskScreen extends StatefulWidget {
  final VoidCallback? onTaskAdded;
  final Map<String, dynamic>? task;

  const AddNewTaskScreen({
    super.key,
    this.onTaskAdded,
    this.task,
  });

  static const String name = '/add-new-task';

  @override
  State<AddNewTaskScreen> createState() => _AddNewTaskScreenState();
}

class _AddNewTaskScreenState extends State<AddNewTaskScreen> {
  final TextEditingController _titleTEController = TextEditingController();
  final TextEditingController _descriptionTEController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _inProgress = false;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleTEController.text = widget.task!['title'] ?? '';
      _descriptionTEController.text = widget.task!['description'] ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;

    return Scaffold(
      appBar: TMAppBar(),
      body: ScreenBackground(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Text(
                  isEditing ? 'Edit Task' : 'Add New Task',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleTEController,
                  validator: (value) => (value?.trim().isEmpty ?? true) ? 'Enter your title' : null,
                  decoration: const InputDecoration(hintText: 'Title'),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionTEController,
                  maxLines: 5,
                  validator: (value) => (value?.trim().isEmpty ?? true) ? 'Enter your description' : null,
                  decoration: const InputDecoration(hintText: 'Description'),
                ),
                const SizedBox(height: 16),
                Visibility(
                  visible: !_inProgress,
                  replacement: const CenteredCircularProgressIndicator(),
                  child: ElevatedButton(
                    onPressed: _onSubmit,
                    child: const Icon(Icons.arrow_circle_right_outlined),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      widget.task != null ? _updateTask() : _addNewTask();
    }
  }

  Future<void> _addNewTask() async {
    setState(() => _inProgress = true);

    final now = DateTime.now();
    final formattedDate = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

    final requestBody = <String, String>{
      "title": _titleTEController.text.trim(),
      "description": _descriptionTEController.text.trim(),
      "status": "New",
      "createdDate": formattedDate,
    };

    final response = await NetworkCaller.postRequest(
      url: Urls.createNewTaskUrl,
      body: requestBody,
    );

    setState(() => _inProgress = false);

    if (response.isSuccess) {
      _titleTEController.clear();
      _descriptionTEController.clear();
      showSnackBarMessage(context, 'Task added successfully');
      widget.onTaskAdded?.call();
      if (mounted) Navigator.pop(context, true);
    } else {
      showSnackBarMessage(context, response.errorMessage ?? 'Failed to add task');
    }
  }

  Future<void> _updateTask() async {
    setState(() => _inProgress = true);

    final requestBody = <String, String>{
      "title": _titleTEController.text.trim(),
      "description": _descriptionTEController.text.trim(),
      "status": widget.task!['status']?.toString() ?? 'New',
      "createdDate": widget.task!['createdDate']?.toString() ?? '',
    };

    final updateUrl = Urls.updateTaskUrl(widget.task!['id']);

    final response = await NetworkCaller.postRequest(
      url: updateUrl,
      body: requestBody,
    );

    setState(() => _inProgress = false);

    if (response.isSuccess) {
      showSnackBarMessage(context, 'Task updated successfully');
      widget.onTaskAdded?.call();
      if (mounted) Navigator.pop(context, true);
    } else {
      showSnackBarMessage(context, response.errorMessage ?? 'Failed to update task');
    }
  }

  @override
  void dispose() {
    _titleTEController.dispose();
    _descriptionTEController.dispose();
    super.dispose();
  }
}
