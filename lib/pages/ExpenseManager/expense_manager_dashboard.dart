import 'package:flutter/material.dart';

class ExpenseDashboard extends StatelessWidget {
  const ExpenseDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Background color matching your design

      body: Column(
        children: const [
          SizedBox(height: 100), // Adjust space for better alignment
          Center(
            child: Text(
              "Expenses",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
          ),
          Spacer(),
        ],
      ),

      // BottomAppBar with 3 items + FloatingActionButton as the 4th item
      bottomNavigationBar: BottomAppBar(
        color: Colors.black, // Matching background
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.receipt, "Records", false),
              _buildNavItem(Icons.pie_chart, "Charts", false),
              _buildNavItem(Icons.description, "Reports", false),

              // FloatingActionButton positioned at the last place
              Padding(
                padding: const EdgeInsets.only(left: 20), // Adjust spacing
                child: FloatingActionButton(
                  onPressed: () {
                    print("Add Expense Clicked");
                  },
                  backgroundColor: const Color.fromARGB(255, 80, 72, 226),
                  shape: const CircleBorder(),
                  child: const Icon(Icons.add,
                      color: Color.fromARGB(255, 15, 15, 15), size: 30),
                ),
              ),
            ],
          ),
        ),
      ),

      // No need for centerDocked anymore
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: isActive ? Colors.yellow : Colors.grey),
        Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.yellow : Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
