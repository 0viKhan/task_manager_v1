import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:task_manager/data/service/Network_caller.dart';
import 'package:task_manager/design/widgets/centered_circular_progress_indicator.dart';
import 'package:task_manager/design/widgets/screen_background.dart';
import 'package:task_manager/design/widgets/snack_bar_message.dart';
import 'package:task_manager/screejn/Emal_Screen.dart';
import 'package:task_manager/screejn/SignUp_screen.dart';
import 'package:task_manager/screejn/main_nav_screen.dart';
import 'package:task_manager/utills/Urls.dart';
import '../data/Ui/controller/auth_controller.dart';
import '../data/models/user_models.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});
  static const String name = 'SignIn';

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passRController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _signInProgress = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: ScreenBackground(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 80),
                  Text(
                    'Get Started With',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  // Email field
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      hintText: "Enter Email",
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Email is required';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value.trim())) {
                        return 'Enter a valid email address';
                      }
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 8),
                  // Password field
                  TextFormField(
                    controller: _passRController,
                    obscureText: true,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: const InputDecoration(
                      hintText: 'Password',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Password is required';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters long';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // SignIn button with progress
                  Visibility(
                    visible: !_signInProgress,
                    replacement: const CenteredCircularProgressIndicator(),
                    child: ElevatedButton(
                      onPressed: _signIn,
                      child: const Icon(Icons.arrow_circle_right_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Forgot password
                  TextButton(
                    onPressed: _onTapForgot,
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  // SignUp link
                  RichText(
                    text: TextSpan(
                      text: "Don't have any account? ",
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                      children: [
                        TextSpan(
                          text: 'SignUp',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = _onTapSignUp,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onTapSignUp() {
    Navigator.pushNamedAndRemoveUntil(
        context, SignUp.name, (predicate) => false);
  }

  void _onTapForgot() {
    Navigator.pushNamed(context, EmailPage.name);
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _signInProgress = true);

    try {
      // Prepare login request
      Map<String, String> requestBody = {
        "email": _emailController.text.trim(),
        "password": _passRController.text,
      };

      // Call API
      final response = await NetworkCaller.postRequest(
        url: Urls.loginUrl,
        body: requestBody,
        isFromLogin: true,
      );

      setState(() => _signInProgress = false);

      if (response.isSuccess && response.body != null) {
        final data = response.body!;

        // Extract token
        final token = data['token'];
        if (token == null) {
          showSnackBarMessage(context, 'Token not found.');
          return;
        }

        // Parse user data
        final userJson = data['data'];
        if (userJson == null) {
          showSnackBarMessage(context, 'User data not found.');
          return;
        }

        final user = UserModel.fromJson(userJson);
        await AuthController.saveUserData(user, token);

        // Navigate to main screen
        Navigator.pushNamedAndRemoveUntil(
          context,
          MainNavScreen.name,
              (predicate) => false,
        );
      } else {
        final error = response.body?['message'] ??
            response.errorMessage ??
            'Login failed. Please check your credentials.';
        showSnackBarMessage(context, error);
      }
    } catch (e) {
      setState(() => _signInProgress = false);
      showSnackBarMessage(context, 'Something went wrong: $e');
    }}}
