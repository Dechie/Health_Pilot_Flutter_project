import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomUpdateButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String title;
  const CustomUpdateButton(
      {super.key, required this.onPressed, required this.title});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
          minimumSize: const Size(231, 50),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: const Color.fromRGBO(110, 182, 255, 1)),
      child: Text(
        title,
        style: TextStyle(
            color: Colors.white,
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 16.sp,
            fontStyle: FontStyle.normal,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.165),
      ),
    );
  }
}
