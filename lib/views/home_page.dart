import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:riseup/controllers/auth_controller.dart';
import 'package:riseup/routes/app_routes.dart';
import 'package:riseup/views/habit/habit_page.dart';
import 'package:riseup/views/journal/journal_page.dart';
import 'package:riseup/views/quotes/quote_page.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final AuthController authController = Get.find();

  

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
        iconTheme: const IconThemeData(color: Colors.white),
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
                style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontFamily: 'assets/fonts/Inter-Bold.ttf',
                    fontWeight: FontWeight.w700),
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
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    height: MediaQuery.of(context).size.height / 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextButton(
                          onPressed: () {
                            Get.toNamed(AppRoutes.addHabit);
                          },
                          child: const Text(
                            'Habit',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        const Divider(),
                        TextButton(
                          onPressed: () {
                            Get.back();
                            Get.toNamed(AppRoutes.addJournal);

                          },
                          child: const Text(
                            'Journal',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              });
        },
        backgroundColor: const Color(0xff009B22),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
