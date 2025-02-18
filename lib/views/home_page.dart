import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:riseup/controllers/auth_controller.dart';
import 'package:riseup/routes/app_routes.dart';
import 'package:riseup/utils/utils.dart';
import 'package:riseup/views/habit/habit_page.dart';
import 'package:riseup/views/journal/journal_page.dart';
import 'package:riseup/views/quotes/quote_page.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late ScrollController _scrollController;
  List<DateTime> dates = []; // List to store dates
  DateTime currentDate = DateTime.now(); // Current date

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // Generate the list of dates (previous 30 days to next 30 days)
    for (int i = -30; i <= 30; i++) {
      dates.add(currentDate.add(Duration(days: i)));
    }

    // Scroll to the current date after the layout is built
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


        // Width of each date widget
        double viewportWidth = _scrollController.position.viewportDimension;

        // Calculate the offset to center the current date
        double offset = (currentDateIndex * itemWidth) -
            (viewportWidth / 2) +
            (itemWidth / 2);

        // Ensure the offset is within valid bounds
        offset = offset.clamp(0.0, _scrollController.position.maxScrollExtent);

        // Scroll to the calculated offset
        _scrollController.jumpTo(offset);
      }
    });
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
        title: const Text(
          'Habit Page',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Utils.primaryGreen,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          controller: _scrollController,
          child: Row(
            children: dates.map((date) {
              bool isToday = DateFormat('yyyy-MM-dd').format(date) ==
                  DateFormat('yyyy-MM-dd').format(currentDate);
              return GestureDetector(
                onTap: () {
                  print(
                      'Selected Date: ${DateFormat('dd MMM yyyy').format(date)}');
                },
                child: Container(
                  width: 50,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isToday ? Colors.blueAccent : Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat('EEE').format(date),
                        style: TextStyle(
                          color: isToday ? Colors.white : Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        DateFormat('d').format(date),
                        style: TextStyle(
                            color: isToday ? Colors.white : Colors.black,
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
