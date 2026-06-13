import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:healthpilot/data/constants.dart';
import 'package:healthpilot/features/health/health_models.dart';
import 'package:healthpilot/features/health/health_provider.dart';
import 'package:provider/provider.dart';

import '../../theme/app_theme.dart';
import 'health_profile_screen.dart';

class SymptomTrackingScreen extends StatefulWidget {
  const SymptomTrackingScreen({super.key});

  @override
  State<SymptomTrackingScreen> createState() => _SymptomTrackingScreenState();
}

class _SymptomTrackingScreenState extends State<SymptomTrackingScreen> {
  bool _isAddingSymptom = false;
  bool _symptomFilled = false;
  final _symptomController = TextEditingController();
  int _severity = 0;

  @override
  void dispose() {
    _symptomController.dispose();
    super.dispose();
  }

  void _severityOfSymptom(int selectedBar) {
    _severity = selectedBar * 2;
  }

  Future<void> _submitSymptom() async {
    final name = _symptomController.text.trim();
    if (name.isEmpty) return;
    final now = DateTime.now();
    final loggedAt = '${_fmtTime(now)}, ${_fmtDate(now)}';
    await context.read<HealthProvider>().addSymptom(
          HealthSymptom(name: name, severity: _severity, loggedAt: loggedAt),
        );
    if (!mounted) return;
    setState(() {
      _isAddingSymptom = false;
      _symptomFilled = false;
      _severity = 0;
      _symptomController.clear();
    });
  }

  static String _fmtTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static String _fmtDate(DateTime dt) =>
      '${_months[dt.month - 1]} ${dt.day}, ${dt.year}';

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final symptoms = context.watch<HealthProvider>().symptoms;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          style: AppTheme.circleBackButtonStyle(context),
        ),
        title: const Text(
          'Symptom Tracking',
          style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontWeight: FontWeight.w600,
              fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.05, vertical: size.height * 0.02),
          child: _isAddingSymptom
              ? _symptomFilled
                  ? _buildSeverityPicker(size)
                  : _buildNameInput(size)
              : _buildSymptomList(size, symptoms),
        ),
      ),
    );
  }

  Widget _buildSeverityPicker(Size size) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: size.width,
          child: Text(
            'How severe is ${_symptomController.text}?',
            style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.w500,
                fontSize: 18),
            textAlign: TextAlign.left,
          ),
        ),
        Column(
          children: [
            CustomizedBarIndicator(barSize: 6, fun: _severityOfSymptom),
            SizedBox(height: size.height * 0.1),
            const Text(
              'Press + to increase severity and − to reduce.',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.w400,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        ElevatedButton(
          onPressed: _submitSymptom,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromRGBO(110, 182, 255, 1),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.2, vertical: size.height * 0.015),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Add Tracking',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        ),
      ],
    );
  }

  Widget _buildNameInput(Size size) {
    return Column(
      children: [
        SizedBox(
          width: size.width,
          child: const Text(
            'Add your symptoms',
            style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.w500,
                fontSize: 18),
            textAlign: TextAlign.left,
          ),
        ),
        SizedBox(height: size.height * 0.02),
        TextFormField(
          controller: _symptomController,
          maxLines: 1,
          decoration: InputDecoration(
            hintText: 'Search Symptoms',
            hintStyle: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),
            prefixIcon: Icon(Icons.search,
                size: size.width * 0.08,
                color: const Color.fromRGBO(41, 41, 41, 0.5)),
            contentPadding: EdgeInsets.symmetric(
                vertical: size.height * 0.015, horizontal: size.width * 0.03),
            border: OutlineInputBorder(
              borderSide:
                  const BorderSide(color: Color.fromRGBO(41, 41, 41, 0.25)),
              borderRadius:
                  BorderRadius.all(Radius.circular(size.width * 0.03)),
            ),
            isDense: true,
          ),
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              setState(() => _symptomFilled = true);
            }
          },
        ),
      ],
    );
  }

  Widget _buildSymptomList(Size size, List<HealthSymptom> symptoms) {
    return Column(
      children: [
        SizedBox(height: size.height * 0.02),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: size.height * 0.035,
              width: size.width * 0.2,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: const Color.fromRGBO(110, 182, 255, 0.25),
                  padding: EdgeInsets.symmetric(vertical: size.height * 0.001),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(size.width * 0.015),
                  ),
                ),
                onPressed: () => setState(() => _isAddingSymptom = true),
                child: const Text(
                  'Add Tracking',
                  style: TextStyle(
                    color: Color.fromRGBO(110, 182, 255, 1),
                    fontSize: 10,
                    fontFamily: 'PlusJakartaSans',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            SizedBox(width: size.width * 0.04),
            SizedBox(
              height: size.height * 0.035,
              width: size.width * 0.2,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: const Color.fromRGBO(252, 34, 34, 0.25),
                  padding: EdgeInsets.symmetric(vertical: size.height * 0.001),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(size.width * 0.015),
                  ),
                ),
                onPressed: () => context.read<HealthProvider>().clearSymptoms(),
                child: const Text(
                  'Clear History',
                  style: TextStyle(
                    color: Color.fromRGBO(252, 34, 34, 1),
                    fontSize: 10,
                    fontFamily: 'PlusJakartaSans',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: size.height * 0.05),
        SizedBox(
          width: double.infinity,
          height: size.height * 0.7,
          child: symptoms.isEmpty
              ? const Center(
                  child: Text(
                    'No symptom tracking added',
                    style: TextStyle(
                      color: Color.fromRGBO(110, 182, 255, 1),
                      fontSize: 20,
                      fontFamily: 'PlusJakartaSans',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: symptoms.length,
                  itemBuilder: (context, index) {
                    return SymptomTracking(
                      disorder: symptoms[index].name,
                      onTap: () {},
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class CustomizedBarIndicator extends StatefulWidget {
  final int barSize;
  final Function(int) fun;
  const CustomizedBarIndicator(
      {super.key, required this.barSize, required this.fun});

  @override
  State<CustomizedBarIndicator> createState() => _CustomizedBarIndicatorState();
}

class _CustomizedBarIndicatorState extends State<CustomizedBarIndicator> {
  int selectedBar = 0;

  List<Widget> addBar(int number) {
    List<Widget> bars = [];
    final size = MediaQuery.of(context).size;
    for (int i = 0; i < number; i++) {
      bars.add(InkWell(
        onTap: () {
          setState(() {
            selectedBar = i;
            widget.fun(selectedBar);
          });
        },
        child: Container(
          height: size.height * 0.01,
          width: size.width * 0.12,
          color: i < 2
              ? const Color.fromRGBO(83, 232, 139, 1)
              : i < 4
                  ? const Color.fromRGBO(255, 232, 21, 1)
                  : const Color.fromRGBO(252, 34, 34, 1),
        ),
      ));
    }
    return bars;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  if (selectedBar > 0) {
                    selectedBar--;
                    widget.fun(selectedBar);
                  }
                });
              },
              icon: const Icon(Icons.remove_circle_outline,
                  color: Color.fromRGBO(83, 232, 139, 1)),
            ),
            Text(
              (selectedBar * 2).toString(),
              style: TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w500,
                  fontSize: 36,
                  color: selectedBar < 2
                      ? const Color.fromRGBO(83, 232, 139, 1)
                      : selectedBar < 4
                          ? const Color.fromRGBO(255, 232, 21, 1)
                          : const Color.fromRGBO(252, 34, 34, 1)),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  if (selectedBar < 5) {
                    selectedBar++;
                    widget.fun(selectedBar);
                  }
                });
              },
              icon: const Icon(
                Icons.add_circle_outline_outlined,
                color: Color.fromRGBO(252, 34, 34, 1),
              ),
            ),
          ],
        ),
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: addBar(widget.barSize),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: size.width * 0.06 + (size.width * 0.15 * selectedBar),
                ),
                SvgPicture.asset(
                  barIndicatorUp,
                  // ignore: deprecated_member_use
                  color: selectedBar < 2
                      ? const Color.fromRGBO(83, 232, 139, 1)
                      : selectedBar < 4
                          ? const Color.fromRGBO(255, 232, 21, 1)
                          : const Color.fromRGBO(252, 34, 34, 1),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
