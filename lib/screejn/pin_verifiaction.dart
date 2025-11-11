import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:task_manager/design/widgets/screen_background.dart';
import 'package:task_manager/data/service/network_caller.dart';
import 'package:task_manager/screejn/set_passwrd.dart';
// 'package:task_manager/screejn/set_password.dart';
import 'package:task_manager/utills/Urls.dart';

import '../data/service/Network_caller.dart' hide NetworkCaller;

class PinVerification extends StatefulWidget {
  const PinVerification({super.key});
  static const String name = '/pin-verification';

  @override
  State<PinVerification> createState() => _PinVerificationState();
}

class _PinVerificationState extends State<PinVerification> {
  final List<TextEditingController> _otpControllers =
  List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;
  String? _email;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String) {
      _email = args;
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid email')));
        Navigator.pop(context);
      });
    }
  }

  @override
  void dispose() {
    for (var c in _otpControllers) c.dispose();
    for (var f in _focusNodes) f.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    if (_email == null) return;

    final otp = _otpControllers.map((c) => c.text).join();

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter full 6-digit OTP')));
      return;
    }

    setState(() => _isLoading = true);

    final response = await NetworkCaller.getRequest(
      url: Urls.recoverVerifyOtp(_email!, otp),
    );

    setState(() => _isLoading = false);

    if (response.isSuccess) {
      Navigator.pushReplacementNamed(
        context,
        SetPassword.name,
        arguments: {"email": _email!, "otp": otp},
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.errorMessage ?? 'Invalid OTP')));
    }
  }

  Widget _buildOtpField(int index) {
    return SizedBox(
      width: 50,
      height: 50,
      child: TextField(
        focusNode: _focusNodes[index],
        controller: _otpControllers[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: (value) {
          if (value.isNotEmpty && index < 5)
            FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
          if (value.isEmpty && index > 0)
            FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
        },
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: ScreenBackground(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 80),
                Text("Enter Verification Code",
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, _buildOtpField),
                ),
                const SizedBox(height: 40),
                Center(
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton.icon(
                    onPressed: _verifyOtp,
                    icon: const Icon(Icons.verified_outlined),
                    label: const Text("Verify"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
