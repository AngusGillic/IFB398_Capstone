import 'package:flutter/material.dart';

class PhoneNotch extends StatelessWidget {
  const PhoneNotch({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 82,
        height: 26,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Align(
          alignment: Alignment.centerRight,
          child: Container(
            margin: const EdgeInsets.only(right: 11),
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF0E1F45),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
