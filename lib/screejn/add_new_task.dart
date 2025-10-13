import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:task_manager/data/service/Network_caller.dart';
import 'package:task_manager/design/widgets/centered_circular_progress_indicator.dart';
import 'package:task_manager/design/widgets/screen_background.dart';
import 'package:task_manager/design/widgets/snack_bar_message.dart';
import 'package:task_manager/design/widgets/tm_app_bar.dart';

import '../utills/Urls.dart';
import 'add_new_task.dart' as _descriptionTEController;
import 'add_new_task.dart' as _titleTEController;

class AddNewTask extends StatefulWidget {
  const AddNewTask({super.key});
  static const String name='/add-new-task';

  @override
  State<AddNewTask> createState() => _AddNewTaskState();
}

class _AddNewTaskState extends State<AddNewTask> {
  final TextEditingController _titleTEController =TextEditingController();
  final TextEditingController _descriptionTEController =TextEditingController();
  GlobalKey<FormState>_formkey =GlobalKey<FormState>();
  bool _addNewTaskProgress=false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TMAppBar(),
      body: ScreenBackground(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formkey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40,),
                Text("Add New Task",style: Theme.of(context).textTheme.titleLarge,),
                const SizedBox(height: 16,),
                TextFormField(
                  controller: _titleTEController,
                  validator:(String?value)
                  {
                    if (value?.trim().isEmpty??true)
                      {
                        return'Enter Your Title';
                      }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'Title'
                  ),
                ),
                const SizedBox(height: 8,),
                TextFormField(
                  controller: _descriptionTEController,

                  validator:(String?value)
                  {
                    if (value?.trim().isEmpty??true)
                    {
                      return'Enter Your deccription';
                    }
                    return null;
                  },
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: 'Enter your Description'
                  ),
                ),
                const SizedBox(height: 8,),
                Visibility(

                  visible: _addNewTaskProgress==false,
                    replacement: CenteredCircularProgressIndicator(),
                    child: ElevatedButton(onPressed:_onTapSubmitButton , child: Icon(Icons.arrow_circle_right_outlined)))
              ],

            ),
          ),
        ),
      )
    );
  }
  void _onTapSubmitButton(){
    if(_formkey.currentState!.validate())
      {
        _addNewTask();
      }
    //Navigator.pop(context);

  }
  Future<void>_addNewTask()async
  {
    _addNewTaskProgress=true;
 setState(() {});
 Map<String,String>requestBody={
   "title":_titleTEController.text.trim(),
   "description":_descriptionTEController.text.trim(),
   "status":"New"
 };
    NetworkResponse response = await NetworkCaller.postRequest(url: Urls.createNewTaskUrl,
    body: requestBody,
    );
    _addNewTaskProgress=false
    ;
    setState(() {

    });
    if(response.isSuccess) {
      _titleTEController.clear();
      _descriptionTEController.clear();
      showSnackbarMessage(context, "Add New task");
    }
      else
        {
        showSnackbarMessage(context, response.errorMessage!);
        }
      }

  }
  @override
  void dispose() {
    _descriptionTEController.dispose();
    _titleTEController.dispose();


  }

