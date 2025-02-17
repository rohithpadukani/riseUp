// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// //import 'package:riseup/controllers/habit_controller.dart';

// class AddHabitPage extends StatelessWidget {
//   AddHabitPage({super.key});

//   //final HabitController habitController = Get.put(HabitController());

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Add New Habit'),
//         backgroundColor: const Color(0xff009B22),
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             //habit name input
//             TextField(
//                 onChanged: (value) {
//                   //habitController.habitName.value = value;
//                 },
//                 decoration: InputDecoration(
//                   labelText: 'Enter Habit Name',
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//             SizedBox(
//               height: 20,
//             ),
//             //repeat days section
//             Text('Repeat'),
//             SizedBox(
//               height: 20,
//             ),
//             Obx(() {
//               return Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: List.generate(7, (index) {
//                   return GestureDetector(
//                     onTap: () {
//                       habitController.selectedDays[index] = !habitController
//                           .selectedDays[index]; // Toggle day selection
//                     },
//                     child: Container(
//                       width: 40,
//                       height: 40,
//                       alignment: Alignment.center,
//                       decoration: BoxDecoration(
//                         color: habitController.selectedDays[index]
//                             ? Colors.green
//                             : Colors.grey,
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Text(
//                         [
//                           'Mon',
//                           'Tue',
//                           'Wed',
//                           'Thu',
//                           'Fri',
//                           'Sat',
//                           'Sun'
//                         ][index],
//                         style: TextStyle(color: Colors.white),
//                       ),
//                     ),
//                   );
//                 }),
//               );
//             }),
//             SizedBox(
//               height: 20,
//             ),
//             //save button
//             ElevatedButton(
//               onPressed: habitController.saveHabit,
//               child: Text('Save'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
