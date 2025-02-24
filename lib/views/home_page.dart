import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:riseup/controllers/auth_controller.dart';
import 'package:riseup/models/habit_model.dart';
import 'package:riseup/routes/app_routes.dart';
import 'package:riseup/services/habit_service.dart';
import 'package:riseup/utils/utils.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final User? user = FirebaseAuth.instance.currentUser;
  final String? email = FirebaseAuth.instance.currentUser!.email;

  late ScrollController _scrollController;
  final AuthController authController = AuthController();
  List<DateTime> dates = []; // List to store dates
  DateTime currentDate = DateTime.now(); // Current date
  DateTime _selectedDate = DateTime.now();
  final HabitService _habitService = HabitService();
  bool isCompleted = false;

  final CollectionReference habitsRef =
      FirebaseFirestore.instance.collection('habits');

  List<bool> isCheckedList = [];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    for (int i = -30; i <= 30; i++) {
      dates.add(currentDate.add(Duration(days: i)));
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentDate();
    });
  }

  void _scrollToCurrentDate() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      int currentDateIndex = dates.indexWhere((date) =>
          DateFormat('yyyy-MM-dd').format(date) ==
          DateFormat('yyyy-MM-dd').format(currentDate));

      if (currentDateIndex != -1) {
        double itemWidth = 65;
        double viewportWidth = _scrollController.position.viewportDimension;
        double offset = (currentDateIndex * itemWidth) -
            (viewportWidth / 2) +
            (itemWidth / 2);
        offset = offset.clamp(0.0, _scrollController.position.maxScrollExtent);
        _scrollController.jumpTo(offset);
      }
    });
  }

  //select dates
  bool isSelected(DateTime date) {
    return (_selectedDate.year == date.year &&
        _selectedDate.month == date.month &&
        _selectedDate.day == date.day);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: const Text(
          'Home Page',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Utils.primaryGreen,
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.all(0),
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xff009B22),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'RiseUp',
                        style: TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontFamily: 'assets/fonts/Inter-Bold.ttf',
                            fontWeight: FontWeight.w700),
                      ),
                      Text(
                        DateFormat('MMMM').format(currentDate),
                        style: const TextStyle(
                            fontSize: 18,
                            color: Color.fromARGB(255, 192, 230, 198),
                            fontFamily: 'assets/fonts/Inter-Regular.ttf',
                            fontWeight: FontWeight.w500),
                      ),
                      Text(
                        DateFormat('yyyy EEEE dd').format(currentDate),
                        style: const TextStyle(
                            fontSize: 15,
                            color: Color.fromARGB(255, 192, 230, 198),
                            fontFamily: 'assets/fonts/Inter-Regular.ttf',
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  Text(
                    '$email',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      fontFamily: 'assets/fonts/Inter-Regular.ttf',
                    ),
                  ),
                ],
              ),
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
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //date list horizontal
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: _scrollController,
              child: Row(
                children: dates.map((date) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDate = date;
                      });
                    },
                    child: Container(
                      width: 50,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected(date)
                            ? Utils.primaryGreen
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            DateFormat('EEE').format(date),
                            style: TextStyle(
                              color: isSelected(date)
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            DateFormat('d').format(date),
                            style: TextStyle(
                                color: isSelected(date)
                                    ? Colors.white
                                    : Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            const Text(
              'Habits',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 20,
            ),
            StreamBuilder<List<HabitModel>>(
              stream:
                  _habitService.getSelectedDayHabits(_selectedDate, user!.uid),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }
                var habits = snapshot.data!;
                return Expanded(
                  child: ListView.builder(
                    itemCount: habits.length,
                    itemBuilder: (context, index) {
                      var habit = habits[index];
                      // ✅ Check if the selected date is in the future
                      bool isFutureDate = _selectedDate.isAfter(DateTime.now());
                      return Column(
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                habit.name.isNotEmpty
                                    ? habit.name[0].toUpperCase() +
                                        habit.name.substring(1)
                                    : "Unnamed Habit",
                                style: const TextStyle(fontSize: 18),
                              ),
                              // 🔹 Listen to Firestore updates for this habit
                              StreamBuilder<DocumentSnapshot>(
                                stream: _habitService.getHabitCompletionStream(
                                  user!.uid,
                                  habit.id,
                                  DateFormat('yyyy-MM-dd')
                                      .format(_selectedDate),
                                ),
                                builder: (context, completionSnapshot) {
                                  if (completionSnapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const SizedBox();
                                  }

                                  // Get the completion status (default to false if no data)
                                  bool isCompleted =
                                      completionSnapshot.data?.exists == true
                                          ? (completionSnapshot
                                                  .data!['completed'] ??
                                              false)
                                          : false;

                                  return GestureDetector(
                                    onTap: isFutureDate
                                        ? null
                                        : () {
                                            _habitService.toggleHabitCompletion(
                                              user!.uid,
                                              habit.id,
                                              DateFormat('yyyy-MM-dd')
                                                  .format(_selectedDate),
                                              !isCompleted, // Toggle value
                                            );
                                          },
                                    child: AnimatedSwitcher(
                                      duration: const Duration(
                                          milliseconds:
                                              300), // Smooth animation
                                      transitionBuilder: (child, animation) {
                                        return ScaleTransition(
                                            scale: animation, child: child);
                                      },
                                      child: Icon(
                                        isFutureDate
                                            ? Icons
                                                .lock // 🔒 Show lock icon for future dates
                                            : isCompleted
                                                ? Icons.check_circle
                                                : Icons.radio_button_unchecked,
                                        key: ValueKey(
                                            isCompleted), // Helps prevent flickering
                                        color: isCompleted
                                            ? Colors.green
                                            : Colors.grey,
                                        size: 28,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Divider(),
                        ],
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
      //floating action button
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
