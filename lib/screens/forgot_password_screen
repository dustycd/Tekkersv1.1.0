import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tekkers/components/my_button.dart';
import 'package:tekkers/components/my_textfield.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final emailController = TextEditingController();
  final codeController = TextEditingController();
  final newPasswordController = TextEditingController();

  bool codeSent = false;
  String verificationCode = ''; // Generated verification code

  int attempts = 0;
  Timer? cooldownTimer;
  int cooldownSeconds = 0;
  bool isCooldown = false;
  Timer? blockTimer;
  int blockSeconds = 0;
  bool isBlocked = false;

  @override
  void dispose() {
    cooldownTimer?.cancel();
    blockTimer?.cancel();
    super.dispose();
  }

  void sendVerificationCode() {
    if (isBlocked) {
      // User is blocked from sending code
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Too Many Attempts'),
          content: const Text(
              'You have exceeded the maximum number of attempts. Please try again later.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    if (isCooldown) {
      // Show message that user needs to wait
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Please Wait'),
          content:
              Text('You can request a new code in $cooldownSeconds seconds.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // Generate a random 4-digit code
    Random random = Random();
    verificationCode = (1000 + random.nextInt(9000)).toString();

    // Simulate sending verification code to email
    setState(() {
      codeSent = true;
      attempts += 1;
    });

    // For testing purposes, print the code
    print('Verification code sent: $verificationCode');

    // Show a dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verification Code Sent'),
        content:
            const Text('A verification code has been sent to your email.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    if (attempts >= 3) {
      // Start 5-minute block
      isBlocked = true;
      blockSeconds = 300; // 5 minutes = 300 seconds
      blockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (blockSeconds > 0) {
            blockSeconds -= 1;
          } else {
            isBlocked = false;
            attempts = 0;
            blockTimer?.cancel();
          }
        });
      });
    } else {
      // Start 15-second cooldown
      isCooldown = true;
      cooldownSeconds = 15;
      cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (cooldownSeconds > 0) {
            cooldownSeconds -= 1;
          } else {
            isCooldown = false;
            cooldownTimer?.cancel();
          }
        });
      });
    }
  }

  void resetPassword() async {
    if (codeController.text == verificationCode) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // Save the new password
      await prefs.setString('password', newPasswordController.text);

      // Show success message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Success'),
          content: const Text('Your password has been reset.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to login page
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      // Show error message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Invalid verification code.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes}m ${remainingSeconds}s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
      ),
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Email textfield
                MyTextField(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false,
                ),
                const SizedBox(height: 20),
                if (!codeSent) ...[
                  // Get Verification Code button
                  MyButton(
                    onTap: (isCooldown || isBlocked) ? null : sendVerificationCode,
                    text: isBlocked
                        ? 'Blocked (${formatTime(blockSeconds)})'
                        : isCooldown
                            ? 'Wait (${cooldownSeconds}s)'
                            : 'Get Verification Code',
                  ),
                ],
                if (codeSent) ...[
                  const SizedBox(height: 20),
                  // Verification code textfield
                  MyTextField(
                    controller: codeController,
                    hintText: 'Verification Code',
                    obscureText: false,
                  ),
                  const SizedBox(height: 10),
                  // New password textfield
                  MyTextField(
                    controller: newPasswordController,
                    hintText: 'New Password',
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  // Change Password button
                  MyButton(
                    onTap: resetPassword,
                    text: 'Change Password',
                  ),
                  const SizedBox(height: 10),
                  // Send Verification Code text
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: (isCooldown || isBlocked) ? null : sendVerificationCode,
                        child: Text(
                          isBlocked
                              ? 'Blocked (${formatTime(blockSeconds)})'
                              : isCooldown
                                  ? 'Wait (${cooldownSeconds}s)'
                                  : 'Send new verification code',
                          style: TextStyle(
                            color: (isCooldown || isBlocked)
                                ? Colors.grey
                                : Colors.blue,
                          ),
                        ),
                      ),
                      const SizedBox(width: 25),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}