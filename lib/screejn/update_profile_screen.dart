import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/Ui/controller/auth_controller.dart';
import '../data/models/user_models.dart';
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
  String? _localPhotoPath;
  bool _updateProfileInProgress = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadLocalPhoto();
  }

  // Load current user data
  void _loadUserData() {
    final user = AuthController.userModel;
    _emailTEController.text = user?.email ?? '';
    _firstNameTEController.text = user?.firstName ?? '';
    _lastNameTEController.text = user?.lastName ?? '';
    _phoneTEController.text = user?.mobile ?? '';
  }

  // Load locally stored photo path
  Future<void> _loadLocalPhoto() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _localPhotoPath = prefs.getString('local_photo_path');
    });
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
          enabled: false,
          decoration: const InputDecoration(labelText: 'Email'),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _firstNameTEController,
          decoration: const InputDecoration(hintText: 'First name'),
          validator: (value) => (value?.trim().isEmpty ?? true) ? 'Enter your first name' : null,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _lastNameTEController,
          decoration: const InputDecoration(hintText: 'Last name'),
          validator: (value) => (value?.trim().isEmpty ?? true) ? 'Enter your last name' : null,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _phoneTEController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(hintText: 'Mobile'),
          validator: (value) => (value?.trim().isEmpty ?? true) ? 'Enter your mobile number' : null,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordTEController,
          obscureText: true,
          decoration: const InputDecoration(hintText: 'Password'),
          validator: (value) {
            if ((value?.length ?? 0) > 0 && (value?.length ?? 0) <= 6) {
              return 'Enter a password longer than 6 characters';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPhotoPicker() {
    final displayText = _selectedImage?.name ??
        (_localPhotoPath != null ? _localPhotoPath!.split('/').last : 'Select image');

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
              child: Text(displayText, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onTapPhotoPicker() async {
    final pickedImage = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = pickedImage;
        _localPhotoPath = pickedImage.path;
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('local_photo_path', pickedImage.path);
    }
  }

  void _onTapSubmitButton() {
    if (_formKey.currentState!.validate()) _updateProfile();
  }

  Future<void> _updateProfile() async {
    setState(() => _updateProfileInProgress = true);

    try {
      final uri = Uri.parse(Urls.updateProfileUrl);
      final request = http.MultipartRequest('POST', uri);

      // Add token
      request.headers['token'] = AuthController.accessToken ?? '';

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
        request.files.add(await http.MultipartFile.fromPath('photo', _selectedImage!.path));
      }

      final streamedResponse = await request.send();
      final responseBody = await streamedResponse.stream.bytesToString();
      setState(() => _updateProfileInProgress = false);

      if (streamedResponse.statusCode == 200) {
        final responseJson = jsonDecode(responseBody);
        final updatedPhotoPath = responseJson['data']?['photo'] ?? '';

        if (updatedPhotoPath.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('local_photo_path');
        }

        final userModel = UserModel(
          id: AuthController.userModel!.id,
          email: _emailTEController.text.trim(),
          firstName: _firstNameTEController.text.trim(),
          lastName: _lastNameTEController.text.trim(),
          mobile: _phoneTEController.text.trim(),
          photo: updatedPhotoPath.isNotEmpty
              ? updatedPhotoPath
              : _localPhotoPath ?? AuthController.userModel!.photo,
        );

        await AuthController.updateUserData(userModel);
        _passwordTEController.clear();
        showSnackBarMessage(context, 'Profile updated successfully!');
      } else {
        String errorMessage = 'Update failed. Try again.';
        try {
          final errorJson = jsonDecode(responseBody);
          if (errorJson['message'] != null) errorMessage = errorJson['message'];
        } catch (_) {}
        showSnackBarMessage(context, errorMessage);
      }
    } catch (e) {
      setState(() => _updateProfileInProgress = false);
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
