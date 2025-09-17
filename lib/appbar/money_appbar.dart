import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../pages/dashboard.dart';

class MoneyAppbar extends StatefulWidget {
  final String monthYear;
  final Function prevMonth;
  final Function nextMonth;
  const MoneyAppbar({
    super.key,
    required this.prevMonth,
    required this.nextMonth,
    required this.monthYear,
  });

  @override
  State<MoneyAppbar> createState() => _MoneyAppbarState();
  // taller AppBar
}

class _MoneyAppbarState extends State<MoneyAppbar> {
  // DateTime selectedDate = DateTime.now();
  //
  // void _prevMonth() {
  //   setState(() {
  //     selectedDate = DateTime(selectedDate.year, selectedDate.month - 1);
  //   });
  // }
  //
  // void _nextMonth() {
  //   setState(() {
  //     selectedDate = DateTime(selectedDate.year, selectedDate.month + 1);
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    // String monthYear = DateFormat("MMM yyyy").format(selectedDate);

    return Container(
      padding: const EdgeInsets.only(top: 35, left: 5, right: 5, bottom: 15),
      decoration: BoxDecoration(
        color: Colors.teal.shade500,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          // Calendar navigation
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.white, size: 26),
            onPressed: () => widget.prevMonth(), // ✅ call when pressed
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          Text(
            widget.monthYear,
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
          IconButton(
            icon: const Icon(
              Icons.chevron_right,
              color: Colors.white,
              size: 26,
            ),
            onPressed: () => widget.nextMonth(), // ✅
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),

          const Spacer(),

          // // Actions
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // Handle search
            },
          ),
          // IconButton(
          //   icon: const Icon(Icons.star_border, color: Colors.white),
          //   onPressed: () {
          //     // Handle notifications
          //   },
          // ),
          IconButton(
            icon: const Icon(Icons.tune, color: Colors.white),
            onPressed: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => const AppbarFilter()),
              // );
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              // Handle search
            },
          ),
        ],
      ),
    );
  }
}
