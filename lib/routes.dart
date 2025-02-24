import 'package:flutter/material.dart';
import 'pages/login.dart';
import 'pages/dashboard_page.dart';
import 'pages/ExpenseManager/expense_manager_dashboard.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/': (context) => const LoginPage(),
    '/dashboard': (context) => const DashboardPage(),
    '/expense': (context) => const ExpenseDashboard(),
  };
}
