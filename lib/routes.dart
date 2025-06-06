import 'package:flutter/material.dart';
import 'package:project/pages/Graphical_Insights/GraphicalInsightsPage.dart';
import 'package:project/pages/Location/TrackMePage.dart';
import 'package:project/pages/Notifications/notification_page.dart';
import 'pages/login.dart';
import 'pages/dashboard_page.dart';
import 'pages/ExpenseManager/expense_manager_dashboard.dart';
import 'pages/TaskManager/task_list_page.dart';
import 'pages/Notifications/notification_page.dart';
import 'Screen/splash_screen.dart';
import 'pages/Profile/profile_page.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/': (context) => SplashScreen(),
    '/login': (context) => const LoginPage(),
    '/dashboard': (context) => const DashboardPage(),
    '/expense': (context) => const ExpenseDashboard(),
    '/tasks': (context) => const TaskListPage(),
    //'/reminders': (context) => const NotificationsPage(),
    '/profile': (context) => ProfilePage(),
    //  '/trackme': (context) => TrackMePage(),
    '/insights': (context) => GraphicalInsightsPage(),
  };
}
