import 'package:get/get.dart';
import 'package:riseup/views/habit/add_habit_page.dart';
import 'package:riseup/views/journal/add_journal_entry.dart';
import 'package:riseup/views/habit/habit_page.dart';
import 'package:riseup/views/home_page.dart';
import 'package:riseup/views/journal/journal_page.dart';
import 'package:riseup/views/main_screen.dart';
import 'package:riseup/views/authentication/login_page.dart';
import 'package:riseup/views/quotes/quote_page.dart';
import 'package:riseup/views/authentication/signup_page.dart';
import 'package:riseup/views/authentication/splash_screen.dart';

class AppRoutes {
  static const login = '/login';
  static const signup = '/signup';
  static const splash = '/splash';
  static const main = '/main';
  static const home = '/home';
  static const habits = '/habits';
  static const journal = '/journal';
  static const quotes = '/quotes';
  static const addHabit = '/addHabit';
  static const addJournal = '/addJournal';
  static const editJournal = '/editJournal';
  static const editHabit = '/editHabit';

  static List<GetPage> pages = [
    GetPage(name: login, page: () => LoginPage()),
    GetPage(name: signup, page: () => SignupPage()),
    GetPage(name: splash, page: () => const SplashScreen()),
    GetPage(name: main, page: () => MainScreen()),
    GetPage(name: home, page: () => HomePage()),
    GetPage(name: habits, page: () => HabitPage()),
    GetPage(name: journal, page: () => JournalPage()),
    GetPage(name: quotes, page: () => QuotesPage()),
    GetPage(name: addJournal, page: () => const AddJournalPage()),
    GetPage(name: addHabit, page: () => const AddHabitPage()),
  ];
}
