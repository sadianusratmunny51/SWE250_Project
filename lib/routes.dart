import 'package:flutter/material.dart';
import 'pages/login.dart';
import 'pages/dashboard_page.dart';
import 'pages/ExpenseManager/expense_manager_dashboard.dart';
import 'pages/TaskManager/task_list_page.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/': (context) => const LoginPage(),
    '/dashboard': (context) => const DashboardPage(),
    '/expense': (context) => const ExpenseDashboard(),
    '/tasks': (context) => const TaskListPage(),
  };
}
