import 'package:flutter/material.dart';
import 'package:phone_auth_firebase/controllers/auth_service.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with CodeAutoFill {
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _otpController = TextEditingController();

  String? _verificationId;
  final _phoneFormKey = GlobalKey<FormState>();
  final _otpFormKey = GlobalKey<FormState>();

  @override
  void codeUpdated() {
    setState(() {
      _otpController.text = code!;
    });

    if (code!.length == 6) _submitOtp();
  }

  Future<void> _sendOtp() async {
    if (!_phoneFormKey.currentState!.validate()) return;
    // Changed prefix to +254 for Kenya
    String phone = "+254${_phoneController.text}";

    try {
      _verificationId = await AuthService.sendOtp(phone);
      await SmsAutoFill().listenForCode(); // Auto-fill listener
      _showOtpDialog();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> _submitOtp() async {
    if (!_otpFormKey.currentState!.validate()) return;

    try {
      await AuthService.verifyOtp(
        verificationId: _verificationId!,
        smsCode: _otpController.text,
      );
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const HomePage()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid OTP: $e")),
      );
    }
  }

  void _showOtpDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("OTP Verification"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Enter 6-digit OTP"),
            const SizedBox(height: 10),
            Form(
              key: _otpFormKey,
              child: PinFieldAutoFill(
                codeLength: 6,
                controller: _otpController,
                decoration: UnderlineDecoration(
                  textStyle: const TextStyle(fontSize: 20),
                  colorBuilder: FixedColorBuilder(Colors.grey),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: _submitOtp, child: const Text("Submit")),
        ],
      ),
    );
  }

  @override
  void dispose() {
    cancel();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: Image.asset("images/login.png", fit: BoxFit.cover)),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Welcome Back 👋",
                        style:
                        TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    const Text("Enter your phone number to continue."),
                    const SizedBox(height: 20),
                    Form(
                      key: _phoneFormKey,
                      child: TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          // Changed prefix to +254 for Kenya
                          prefixText: "+254 ",
                          labelText: "Phone Number",
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                        (v == null || v.length != 9) // Kenyan numbers are 9 digits after +254
                            ? "Enter 9 digits"
                            : null,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _sendOtp,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.yellow,
                            foregroundColor: Colors.black),
                        child: const Text("Send OTP"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
