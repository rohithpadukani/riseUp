import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:riseup/controllers/auth_controller.dart';
import 'package:riseup/controllers/home_controller.dart';
import 'package:riseup/views/habit_page.dart';
import 'package:riseup/views/home_page.dart';
import 'package:riseup/views/journal_page.dart';
import 'package:riseup/views/quote_page.dart';

class MainScreen extends StatelessWidget {
  MainScreen({super.key});

  final AuthController authController = Get.find();
  final HomeController homeController = Get.put(HomeController());

  final List<Widget> pages = [
    HomePage(),
    HabitPage(),
    JournalPage(),
    QuotesPage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home',
          style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 24,
              color: Colors.white,
              fontFamily: 'assets/fonts/Inter-Medium.ttf'),
        ),
        backgroundColor: const Color(0xff009B22),
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.white
        ),
      ),
      drawer: Drawer(

        child: ListView(
          padding: const EdgeInsets.all(0),
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xff009B22),
              ),
              child: Text(
                'RiseUp',
                style: TextStyle(fontSize: 24, color: Colors.white, fontFamily: 'assets/fonts/Inter-Bold.ttf', fontWeight: FontWeight.w700),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Get.offAll(HomePage());
              },
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Habits'),
              onTap: () {
                Get.to(HabitPage());
              },
            ),
            ListTile(
              leading: const Icon(Icons.book),
              title: const Text('Journal'),
              onTap: () {
                Get.to(JournalPage());
              },
            ),
            ListTile(
              leading: const Icon(Icons.format_quote),
              title: const Text('Quotes'),
              onTap: () {
                Get.to(QuotesPage());
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                authController.logout();
              },
            ),
          ],
        ),
      ),
      body: Obx(() => pages[homeController.selectedIndex.value]),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: homeController.selectedIndex.value,
          onTap: homeController.changeTab,
          selectedItemColor: const Color(0xff009B22),
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          items: const[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.check_circle), label: "Habits"),
            BottomNavigationBarItem(icon: Icon(Icons.book), label: "Journal"),
            BottomNavigationBarItem(icon: Icon(Icons.format_quote), label: "Quotes"),
          ],
        )
      ),
    );
  }
}
