import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:riseup/routes/app_routes.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed(AppRoutes.addJournal);
        },
        backgroundColor: const Color(0xff009B22),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
