import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

/// Policy Widget
///
/// A Flutter widget for displaying policy content in a dialog with a blur effect.
///
/// This widget creates a dialog for presenting policy documents or text-based
/// information. It features a blur effect backdrop and a "Close" button for user
/// interaction.
///
/// Properties:
/// - `radius`: Border radius of the dialog.
/// - `mdFile`: Name of the Markdown file to display.
///
/// Usage:
/// Instantiate the `Policy` widget with the desired `radius` and `mdFile` to
/// display policy content in a dialog format within your Flutter app.
//class Policy extends StatelessWidget {
// Constructor and widget implementation go here.
// ...
//}

// ignore: must_be_immutable
class Policy extends StatelessWidget {
  Policy({super.key, this.radius = 10, required this.mdFile})
      : assert(
            mdFile.contains('.md'), 'The file must contain the .md extension');

  double radius;
  final String mdFile;
  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
        child: Column(
          children: [
            Expanded(
                child: FutureBuilder(
              future: Future.delayed(const Duration(milliseconds: 150))
                  .then((value) {
                return rootBundle.loadString('assets/PrivacyPolicy/$mdFile');
              }),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Markdown(data: snapshot.data!);
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            )),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(110, 182, 255, 1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(radius),
                          bottomRight: Radius.circular(radius)))),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(radius),
                        bottomRight: Radius.circular(radius))),
                alignment: Alignment.center,
                height: 50,
                width: double.infinity,
                child: const Text(
                  'Close',
                  style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontWeight: FontWeight.w500),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
