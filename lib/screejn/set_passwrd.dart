import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:task_manager/design/widgets/screen_background.dart';
import 'package:task_manager/utills/Urls.dart';
import 'package:task_manager/screejn/sign_In.dart';

import '../data/service/Network_caller.dart';

class SetPassword extends StatefulWidget {
  const SetPassword({super.key});
  static const String name = '/set-password';

  @override
  State<SetPassword> createState() => _SetPasswordState();
}

class _SetPasswordState extends State<SetPassword> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late String _email;
  late String _otp;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, String>;
    _email = args['email']!;
    _otp = args['otp']!;
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await NetworkCaller.postRequest(
        url: Urls.recoverResetPasswordUrl,
        body: {
          "email": _email,
          "OTP": _otp,
          "password": password,
        },
        isFromLogin: true, // ensures no token is sent
      );

      setState(() => _isLoading = false);

      if (response.isSuccess && response.body != null) {
        final status = response.body!['status'];
        if (status == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password reset successfully')),
          );
          Navigator.pushNamedAndRemoveUntil(context, SignIn.name, (route) => false);
        } else {
          // handle failure message from server
          final message = response.body!['data'] ?? 'Password reset failed';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        }
      } else {
        // If the server returned invalid JSON or no body
        final message = response.errorMessage ?? 'Password reset failed';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }


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
                  Text('Set New Password', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(hintText: 'New Password', prefixIcon: Icon(Icons.lock_outline)),
                    validator: (value) => value == null || value.isEmpty ? 'Enter a valid password' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(hintText: 'Confirm Password', prefixIcon: Icon(Icons.lock_outline)),
                    validator: (value) => value == null || value.isEmpty ? 'Confirm your password' : null,
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton.icon(
                      onPressed: _resetPassword,
                      icon: const Icon(Icons.arrow_circle_right_outlined),
                      label: const Text('Set Password'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  RichText(
                    text: TextSpan(
                      text: "Already have an account? ",
                      style: const TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                          text: 'Sign In',
                          style: const TextStyle(color: Colors.green),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pushReplacementNamed(context, SignIn.name);
                            },


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
}
