

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../data/Ui/controller/auth_controller.dart';
import '../data/models/user_models.dart';
import '../data/service/Network_caller.dart';
import '../design/widgets/centered_circular_progress_indicator.dart';
import '../design/widgets/screen_background.dart';
import '../design/widgets/snack_bar_message.dart';
import '../design/widgets/tm_app_bar.dart';
import '../utills/Urls.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  static const String name = '/update-profile';

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final _emailTEController = TextEditingController();
  final _firstNameTEController = TextEditingController();
  final _lastNameTEController = TextEditingController();
  final _phoneTEController = TextEditingController();
  final _passwordTEController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();

  XFile? _selectedImage;
  bool _updateProfileInProgress = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = AuthController.userModel;
    _emailTEController.text = user?.email ?? '';
    _firstNameTEController.text = user?.firstName ?? '';
    _lastNameTEController.text = user?.lastName ?? '';
    _phoneTEController.text = user?.mobile ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TMAppBar(),
      body: ScreenBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Text('Update Profile', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 24),
                _buildPhotoPicker(),
                const SizedBox(height: 8),
                _buildTextFields(),
                const SizedBox(height: 16),
                Visibility(
                  visible: !_updateProfileInProgress,
                  replacement: const CenteredCircularProgressIndicator(),
                  child: ElevatedButton(
                    onPressed: _onTapSubmitButton,
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

  Widget _buildTextFields() {
    return Column(
      children: [
        TextFormField(
          controller: _emailTEController,
          textInputAction: TextInputAction.next,
          enabled: false,
          decoration: const InputDecoration(labelText: 'Email'),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _firstNameTEController,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(hintText: 'First name'),
          validator: (value) {
            if (value?.trim().isEmpty ?? true) return 'Enter your first name';
            return null;
          },
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _lastNameTEController,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(hintText: 'Last name'),
          validator: (value) {
            if (value?.trim().isEmpty ?? true) return 'Enter your last name';
            return null;
          },
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _phoneTEController,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(hintText: 'Mobile'),
          validator: (value) {
            if (value?.trim().isEmpty ?? true) return 'Enter your mobile number';
            return null;
          },
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordTEController,
          obscureText: true,
          decoration: const InputDecoration(hintText: 'Password'),
          validator: (value) {
            final length = value?.length ?? 0;
            if (length > 0 && length <= 6) {
              return 'Enter a password longer than 6 characters';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPhotoPicker() {
    return GestureDetector(
      onTap: _onTapPhotoPicker,
      child: Container(
        height: 50,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Container(
              width: 100,
              height: 50,
              decoration: const BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Photo',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _selectedImage == null ? 'Select image' : _selectedImage!.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onTapPhotoPicker() async {
    final pickedImage = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() => _selectedImage = pickedImage);
    }
  }

  void _onTapSubmitButton() {
    if (_formKey.currentState!.validate()) {
      _updateProfile();
    }
  }



  Future<void> _updateProfile() async {
    setState(() => _updateProfileInProgress = true);

    try {
      final uri = Uri.parse(Urls.updateProfileUrl);
      final request = http.MultipartRequest('POST', uri);

      // Add token for authorization
      final token = AuthController.accessToken ?? '';
      request.headers['token'] = token;
      debugPrint('Token: $token');

      // Add form fields
      request.fields['email'] = _emailTEController.text.trim();
      request.fields['firstName'] = _firstNameTEController.text.trim();
      request.fields['lastName'] = _lastNameTEController.text.trim();
      request.fields['mobile'] = _phoneTEController.text.trim();

      if (_passwordTEController.text.isNotEmpty) {
        request.fields['password'] = _passwordTEController.text;
      }

      // Add photo if selected
      if (_selectedImage != null) {
        debugPrint('Uploading photo: ${_selectedImage!.path}');
        request.files.add(
          await http.MultipartFile.fromPath('photo', _selectedImage!.path),
        );
      } else {
        debugPrint('No photo selected.');
      }

      // Send request
      final streamedResponse = await request.send();

      // Read full response
      final responseBody = await streamedResponse.stream.bytesToString();
      debugPrint('Response Status: ${streamedResponse.statusCode}');
      debugPrint('Response Body: $responseBody');

      if (!mounted) return;

      setState(() => _updateProfileInProgress = false);

      if (streamedResponse.statusCode == 200) {
        final responseJson = jsonDecode(responseBody);
        final updatedPhotoPath = responseJson['data']?['photo'] ?? '';
        debugPrint('Updated photo path: $updatedPhotoPath');

        // Update local user data
        final userModel = UserModel(
          id: AuthController.userModel!.id,
          email: _emailTEController.text.trim(),
          firstName: _firstNameTEController.text.trim(),
          lastName: _lastNameTEController.text.trim(),
          mobile: _phoneTEController.text.trim(),
          photo: updatedPhotoPath.isNotEmpty
              ? updatedPhotoPath
              : _selectedImage?.path ?? AuthController.userModel!.photo,
        );

        await AuthController.updateUserData(userModel);
        _passwordTEController.clear();
        showSnackBarMessage(context, 'Profile updated successfully!');
      } else {
        // Show server error message if exists
        String errorMessage = 'Update failed. Try again.';
        try {
          final errorJson = jsonDecode(responseBody);
          if (errorJson['message'] != null) errorMessage = errorJson['message'];
        } catch (_) {}
        showSnackBarMessage(context, errorMessage);
      }
    } catch (e, st) {
      setState(() => _updateProfileInProgress = false);
      debugPrint('Exception occurred: $e');
      debugPrint('Stack trace: $st');
      showSnackBarMessage(context, 'Error occurred. Check logs.');
    }
  }



  @override
  void dispose() {
    _emailTEController.dispose();
    _firstNameTEController.dispose();
    _lastNameTEController.dispose();
    _phoneTEController.dispose();
    _passwordTEController.dispose();
    super.dispose();
  }
}