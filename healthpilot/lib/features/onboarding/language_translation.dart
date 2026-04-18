import 'package:flutter/material.dart';

class LanguageTranslation extends StatefulWidget {
  const LanguageTranslation({super.key});

  @override
  State<LanguageTranslation> createState() => _LanguageTranslationState();
}

class _LanguageTranslationState extends State<LanguageTranslation> {
  List<String> languages = [
    "English",
    "Amharic",
    "Spanish",
    "French",
    "Urudu",
    "Arabic"
  ];
  int selectedButtonIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: ((context, constraints) {
            final size = constraints.biggest;
            final screenWidth = size.width;
            final screenHeight = size.height;

            return SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          screenWidth * 0.04,
                          screenHeight * 0.02,
                          0,
                          0,
                        ),
                        child: Container(
                          width: screenWidth * 0.1,
                          height: screenWidth * 0.1,
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(110, 182, 255, 0.25),
                            borderRadius:
                                BorderRadius.circular(screenWidth * 0.05),
                          ),
                          child: IconButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(Icons.arrow_back),
                            color: const Color.fromRGBO(110, 182, 255, 1),
                            iconSize: screenWidth * 0.055,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          screenWidth * 0.05,
                          screenHeight * 0.03,
                          0,
                          0,
                        ),
                        child: Text(
                          "Language",
                          style: TextStyle(
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.w600,
                            fontFamily: "PlusJakartaSans",
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.04,
                        horizontal: screenWidth * 0.05),
                    child: Column(
                      children: languages.asMap().entries.map((entry) {
                        final index = entry.key;
                        final language = entry.value;
                        return LangButton(
                          index: index,
                          screenWidth: screenWidth,
                          screenHeight: screenHeight,
                          language: language,
                          isSelected: selectedButtonIndex == index,
                          onPressed: () {
                            setState(() {
                              selectedButtonIndex = index;
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

class LangButton extends StatelessWidget {
  final int index;
  final double screenWidth;
  final double screenHeight;
  final String language;
  final bool isSelected;
  final VoidCallback onPressed;

  const LangButton({
    super.key,
    required this.index,
    required this.screenWidth,
    required this.screenHeight,
    required this.language,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: screenWidth * 0.9,
        height: screenWidth * 0.13,
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [
                    Color.fromRGBO(110, 182, 255, 0.3),
                    Color.fromRGBO(110, 182, 255, 0.26),
                    Color.fromRGBO(110, 182, 255, 0.08),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05, vertical: screenHeight * 0.02),
          child: Text(
            language,
            textAlign: TextAlign.left,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
              height: 1.25,
              letterSpacing: -0.165,
            ),
          ),
        ),
      ),
    );
  }
}
