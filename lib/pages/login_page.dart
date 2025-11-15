import 'dart:async';
import 'package:flutter/material.dart';
import 'package:telephony/telephony.dart';
import '../controllers/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _phoneFormKey = GlobalKey<FormState>();
  final _otpFormKey = GlobalKey<FormState>();

  String? verificationId;

  final Telephony telephony = Telephony.instance;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> sendOtp() async {
    if (!_phoneFormKey.currentState!.validate()) return;

    String phone = "+91${_phoneController.text}";
    try {
      verificationId = await AuthService.sendOtp(phone);
      _listenSms();
      _showOtpDialog();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> verifyOtp() async {
    if (!_otpFormKey.currentState!.validate()) return;

    try {
      await AuthService.verifyOtp(
        verificationId: verificationId!,
        smsCode: _otpController.text,
      );
      Navigator.of(context).pop(); // close dialog
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid OTP: $e")),
      );
    }
  }

  void _listenSms() {
    telephony.listenIncomingSms(
      listenInBackground: false,
      onNewMessage: (SmsMessage message) {
        final body = message.body ?? "";
        final otp = RegExp(r'\d{6}').stringMatch(body);
        if (otp != null) {
          setState(() => _otpController.text = otp);
          Future.delayed(const Duration(milliseconds: 600), verifyOtp);
        }
      },
    );
  }

  void _showOtpDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Verify OTP"),
        content: Form(
          key: _otpFormKey,
          child: TextFormField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "6-digit OTP"),
            validator: (v) =>
            (v == null || v.length != 6) ? "Enter 6-digit OTP" : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: verifyOtp,
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Image.asset("images/login.png", height: 300),
              Form(
                key: _phoneFormKey,
                child: TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    prefixText: "+91 ",
                    labelText: "Phone Number",
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                  (v == null || v.length != 10) ? "Enter valid number" : null,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: sendOtp,
                child: const Text("Send OTP"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
