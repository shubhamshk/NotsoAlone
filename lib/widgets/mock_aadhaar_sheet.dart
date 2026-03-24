import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockAadhaarSheet extends StatefulWidget {
  const MockAadhaarSheet({super.key});

  @override
  State<MockAadhaarSheet> createState() => _MockAadhaarSheetState();
}

class _MockAadhaarSheetState extends State<MockAadhaarSheet> {
  int currentStep = 1;
  bool isLoading = false;
  final TextEditingController aadhaarController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  @override
  void dispose() {
    aadhaarController.dispose();
    otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (aadhaarController.text.length != 12) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter exactly 12 digits')),
      );
      return;
    }

    setState(() => isLoading = true);
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() {
      isLoading = false;
      currentStep = 2;
    });
  }

  Future<void> _verifyOtp() async {
    if (otpController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter exactly 6 digits')),
      );
      return;
    }

    setState(() => isLoading = true);
    await Future.delayed(const Duration(seconds: 2));

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await Supabase.instance.client.from('profiles').upsert({
          'id': user.id,
          'aadhaar_verified': true,
        });
      }
    } catch (e) {
      debugPrint('Supabase Error: $e');
    }

    if (!mounted) return;
    setState(() {
      isLoading = false;
      currentStep = 3;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (currentStep == 1) ...[
                const Text("Verify Identity (KYC)",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text(
                    "Enter your 12-digit Aadhaar number to get the verified badge.",
                    textAlign: TextAlign.center),
                const SizedBox(height: 16),
                TextField(
                  controller: aadhaarController,
                  keyboardType: TextInputType.number,
                  maxLength: 12,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Aadhaar Number'),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _sendOtp,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0052D0)),
                    child: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child:
                                CircularProgressIndicator(color: Colors.white))
                        : const Text("Send OTP",
                            style: TextStyle(color: Colors.white)),
                  ),
                ),
              ] else if (currentStep == 2) ...[
                const Text("Enter OTP",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text(
                    "A mock OTP has been sent to your registered mobile number.",
                    textAlign: TextAlign.center),
                const SizedBox(height: 16),
                TextField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: '6-digit OTP'),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _verifyOtp,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0052D0)),
                    child: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child:
                                CircularProgressIndicator(color: Colors.white))
                        : const Text("Verify",
                            style: TextStyle(color: Colors.white)),
                  ),
                ),
              ] else if (currentStep == 3) ...[
                const Icon(Icons.verified, color: Colors.blue, size: 80),
                const SizedBox(height: 16),
                const Text("Profile Verified!",
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.green)),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context, true);
                      }
                    },
                    child: const Text("Done"),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
