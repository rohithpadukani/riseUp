import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:riseup/controllers/auth_controller.dart'; // Assuming you're using AuthController
import 'package:riseup/routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // This will be used to simulate checking if the user is logged in
  // You can replace this with real authentication check logic
  @override
  void initState() {
    super.initState();
    _checkUserStatus();
  }

  // Check if the user is logged in
  void _checkUserStatus() async {
    await Future.delayed(const Duration(seconds: 1));
    AuthController authController = Get.find();

    // Check if user is logged in
    bool isLoggedIn = await authController.isUserLoggedIn();

    // Navigate accordingly
    if (isLoggedIn) {
      Get.offAllNamed(AppRoutes.main); // Navigate to home if logged in
    } else {
      Get.offAllNamed(AppRoutes.login); // Navigate to login if not logged in
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xff009B22),
        ),
        child: const Center(
          child: Text(
            'RiseUp',
            style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 24,
                color: Colors.white,
                fontFamily: 'assets/fonts/Inter-Black.ttf'),
          ),
        ),
      ),
    );
  }
}
