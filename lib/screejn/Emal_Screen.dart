import 'package:flutter/material.dart';
import 'package:task_manager/design/widgets/screen_background.dart';
import 'package:task_manager/data/service/network_caller.dart' hide NetworkCaller;
import 'package:task_manager/screejn/pin_verifiaction.dart';
//import 'package:task_manager/screejn/pin_verification.dart';
import 'package:task_manager/utills/Urls.dart';

import '../data/service/Network_caller.dart';

class EmailPage extends StatefulWidget {
  const EmailPage({super.key});
  static const String name = '/email';

  @override
  State<EmailPage> createState() => _EmailPageState();
}

class _EmailPageState extends State<EmailPage> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final response = await NetworkCaller.getRequest(
      url: Urls.recoverVerifyEmail(_emailController.text.trim()),
    );

    setState(() => _isLoading = false);

    if (response.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP sent to your email')),
      );
      Navigator.pushNamed(
        context,
        PinVerification.name,
        arguments: _emailController.text.trim(),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.errorMessage ?? 'Failed to send OTP')),
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
                  Text("Your Email Address",
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  const Text(
                    "A 6-digit verification code will be sent to your email.",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _emailController,
                    validator: (value) => value == null || !value.contains('@')
                        ? 'Enter valid email'
                        : null,
                    decoration: const InputDecoration(
                      hintText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton.icon(
                      onPressed: _sendOtp,
                      icon: const Icon(Icons.arrow_circle_right_outlined),
                      label: const Text("Send OTP"),
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
