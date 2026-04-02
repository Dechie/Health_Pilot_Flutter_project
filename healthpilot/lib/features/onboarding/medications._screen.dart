import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:line_icons/line_icons.dart';

/// Medication Class
///
/// A data model class in a Flutter health application representing medication information.
/// Instances of this class store details about a specific medication, including its name,
/// dosage frequency, and milligram dosage.
///
/// Properties:
/// - `medicationName`: A string representing the name of the medication.
/// - `noTimesPerDay`: An integer indicating how many times the medication should be taken per day.
/// - `miligrams`: An integer specifying the milligram dosage of the medication.
///
/// Usage:
/// The `Medication` class is used to create instances that encapsulate medication data.
/// It is commonly used to represent individual medication records within the application.
///
/// Example:
///
/// ```dart
/// final aspirin = Medication("Aspirin", 2, 100);
/// ```

class Medication {
  final String medicationName;
  final int noTimesPerDay;
  final int miligrams;

  Medication(this.medicationName, this.noTimesPerDay, this.miligrams);
}

/// MedicationListProvider Class
///
/// A utility class in a Flutter health application for managing a list of medications.
/// This class provides methods to access and manipulate the list of medications,
/// including adding new medications to the list.
///
/// Properties:
/// - `medication`: A static list containing instances of the `Medication` class.
///
/// Usage:
/// The `MedicationListProvider` class serves as a centralized data management tool
/// for medications within a Flutter health application. It allows easy access to the
/// list of medications and provides a method for adding new medications to the list.
///
/// Example:
///
/// ```dart
/// MedicationListProvider.addMedication("Aspirin", 2, 100);
/// ```

class MedicationListProvider {
  static List<Medication> medication = [Medication("medicationName", 1, 2)];

  static void addMedication(
      String medicationName, int noTimesperday, int miligrms) {
    final newMedication = Medication(medicationName, noTimesperday, miligrms);
    medication.add(newMedication);
  }
}

/// MedicationScreen Widget
///
/// A Flutter screen widget for managing and displaying a list of medications.
/// This screen allows users to view, add, edit, and delete medications from their
/// medication list. It includes a search input field for filtering medications.
///
/// Properties:
/// None
///
/// Usage:
/// The `MedicationScreen` widget is a key part of medication management within a
/// Flutter health application. It provides a user interface for interacting with
/// medications, such as adding new medications, editing existing ones, and searching
/// for medications by name. It adapts to different screen sizes and allows users
/// to maintain their medication records.
///
/// Example:
///
/// ```dart
/// Navigator.of(context).push(MaterialPageRoute(
///   builder: (context) => MedicationScreen(),
/// ));
/// ```

class MedicationScreen extends StatefulWidget {
  const MedicationScreen({super.key});

  @override
  State<MedicationScreen> createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
  final TextEditingController _searchText = TextEditingController();
  List<Medication> filteredMedications = [];

  void _editMedication(int index) {
    final medicationToEdit = MedicationListProvider.medication[index];
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MedicationAddScreen(
          existingMedication: medicationToEdit,
        ),
      ),
    );
  }

  void _filterMedications(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredMedications = MedicationListProvider.medication;
      } else {
        filteredMedications = MedicationListProvider.medication
            .where((medication) => medication.medicationName
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  void initState() {
    filteredMedications = MedicationListProvider.medication;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest;
          final screenWidth = size.width;
          final screenHeight = size.height;
          return SingleChildScrollView(
              reverse: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          screenWidth * 0.05,
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
                          "Medications",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.w700,
                            fontFamily: "PlusJakartaSans",
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                      padding: EdgeInsets.fromLTRB(
                        screenWidth * 0.05,
                        screenHeight * 0.035,
                        screenWidth * 0.05,
                        screenHeight * 0.02,
                      ),
                      child: const Texts(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        text: "Add your Medication",
                        align: TextAlign.left,
                      )),
                  SizedBox(
                    height: screenHeight * 0.017,
                  ),
                  SearchInputField(
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                    icon: LineIcons.search,
                    controller: _searchText,
                    inputAction: TextInputAction.search,
                    canONChangedUsed: true,
                    hintText: 'Search Medications',
                    onChanged: (query) {
                      _filterMedications(
                          query); // Call _filterMedications when the text changes
                    },
                  ),
                  SizedBox(
                    height: screenHeight * 0.03,
                  ),
                  filteredMedications.isEmpty
                      ? Column(
                          children: [
                            Align(
                              alignment: Alignment.topCenter,
                              child: SvgPicture.asset(
                                "assets/images/Medications.svg",
                              ),
                            ),
                            SizedBox(
                              height: screenHeight * 0.03,
                            ),
                            const Align(
                              alignment: Alignment.topCenter,
                              child: Texts(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                                text: "No Medications Found",
                                align: TextAlign.center,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.12,
                                vertical: screenHeight * 0.02,
                              ),
                              child: const Align(
                                alignment: Alignment.topCenter,
                                child: Texts(
                                  fontSize: 14,
                                  color: Color.fromRGBO(42, 42, 42, 0.85),
                                  fontWeight: FontWeight.w400,
                                  text:
                                      "Search for your medications from our database and add them to track your health better",
                                  align: TextAlign.center,
                                ),
                              ),
                            )
                          ],
                        )
                      : Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.05),
                          child: Container(
                            height: screenHeight * 0.55,
                            color: Colors.transparent,
                            child: ListView.separated(
                              itemBuilder: (context, index) {
                                return MedicationListTile(
                                  onpressed: null,
                                  medicationName:
                                      filteredMedications[index].medicationName,
                                  screenHeight: screenHeight,
                                  screenWidth: screenWidth,
                                  onTap: () {
                                    setState(() {
                                      MedicationListProvider.medication
                                          .removeWhere(
                                        (element) =>
                                            element.medicationName ==
                                            filteredMedications[index]
                                                .medicationName,
                                      );
                                    });
                                  },
                                  edit: () {
                                    return _editMedication(index);
                                  },
                                );
                              },
                              itemCount: filteredMedications.length,
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return const Divider(
                                  height: 1,
                                  color: Color.fromRGBO(42, 42, 42, 0.15),
                                );
                              },
                            ),
                          ),
                        ),
                  Padding(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom))
                ],
              ));
        },
      )),
      resizeToAvoidBottomInset: false,
    );
  }
}

/// MedicationListTile Widget
///
/// A customizable Flutter widget for displaying medication information in a list tile.
/// This widget is commonly used to represent individual medication items within a list,
/// allowing users to view details and perform actions like editing or deleting medications.
///
/// Properties:
/// - `onpressed`: A callback triggered when the list tile is pressed.
/// - `medicationName`: The name of the medication to be displayed.
/// - `screenHeight`: The height of the screen, used for responsive design.
/// - `screenWidth`: The width of the screen, used for responsive design.
/// - `onTap`: A callback function invoked when a specific action is taken (e.g., tapping the delete icon).
/// - `edit`: An optional callback for editing medication details (e.g., tapping the edit icon).
///
/// Usage:
/// The `MedicationListTile` widget is a versatile Components for rendering medication
/// information within lists or similar layouts. It provides the ability to display
/// medication names, perform actions, and adapt to different screen sizes.
///
/// Example:
///
/// ```dart
/// MedicationListTile(
///   onpressed: () {
///     // Handle tap on the medication list tile.
///   },
///   medicationName: "Medication Name",
///   screenHeight: MediaQuery.of(context).size.height,
///   screenWidth: MediaQuery.of(context).size.width,
///   onTap: () {
///     // Handle a specific action (e.g., delete medication) when tapped.
///   },
///   edit: () {
///     // Handle editing medication details when the edit icon is tapped.
///   },
/// )
/// ```

// ignore: must_be_immutable
class MedicationListTile extends StatelessWidget {
  final VoidCallback? onpressed;

  final String medicationName;
  final double screenHeight;
  final double screenWidth;
  final VoidCallback onTap;
  final VoidCallback? edit;
  // ignore: non_constant_identifier_names
  const MedicationListTile({
    super.key,
    required this.onpressed,
    required this.medicationName,
    required this.screenHeight,
    required this.screenWidth,
    required this.onTap,
    required this.edit,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        medicationName,
        style: const TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.2,
        ),
      ),
      horizontalTitleGap: 5,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: edit,
            child: const Icon(
              LineIcons.edit,
              color: Color.fromRGBO(110, 182, 255, 1),
            ),
          ),
          SizedBox(
            width: screenWidth * 0.03,
          ),
          GestureDetector(
              onTap: onTap, child: SvgPicture.asset('assets/Icons/xmark.svg')),
        ],
      ),
      onTap: onpressed,
    );
  }
}

/// Texts Widget
///
/// A versatile Flutter widget for displaying text with customizable attributes
/// such as font size, color, font weight, text content, and text alignment.
/// This widget is suitable for rendering text in various styles and contexts.
///
/// Properties:
/// - `fontSize`: The size of the font for the displayed text.
/// - `color`: The color of the text.
/// - `fontWeight`: The font weight (e.g., normal, bold) of the text.
/// - `text`: The content of the text to be displayed.
/// - `align`: The text alignment within its container (e.g., left, center, right).
///
/// Usage:
/// The `Texts` widget provides flexibility in customizing the appearance of text
/// within your Flutter application. It is commonly used to create styled text,
/// such as headings, paragraphs, or labels, with the ability to adjust font size,
/// color, and alignment to match your design and content needs.
///
/// Example:
///
/// ```dart
/// Texts(
///   fontSize: 16,
///   color: Colors.black,
///   fontWeight: FontWeight.bold,
///   text: "Welcome to Flutter!",
///   align: TextAlign.center,
/// )
/// ```

class Texts extends StatelessWidget {
  final double fontSize;
  final Color color;
  final FontWeight fontWeight;
  final String text;
  final TextAlign align;
  const Texts(
      {super.key,
      required this.fontSize,
      required this.color,
      required this.fontWeight,
      required this.text,
      required this.align});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: align,
      style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontFamily: 'PlusJakartaSans',
          fontWeight: fontWeight,
          letterSpacing: -0.17,
          height: 1.2),
    );
  }
}

/// InputLabels Widget
///
/// A Flutter widget for displaying labels associated with input fields or sections.
/// This widget is commonly used to provide context or titles for various form fields
/// or content sections within a user interface.
///
/// Properties:
/// - `label`: The text label to be displayed.
///
/// Usage:
/// The `InputLabels` widget is a simple and reusable Components that enhances the
/// readability and user-friendliness of forms and content sections. It allows you to
/// provide descriptive labels for input fields, helping users understand the purpose
/// of the associated elements.
///
/// Example:
///
/// ```dart
/// InputLabels(label: "Medication Name")
/// ```

class InputLabels extends StatelessWidget {
  final String label;
  const InputLabels({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
          color: Color.fromRGBO(42, 42, 42, 0.5),
          fontSize: 14,
          fontFamily: 'PlusJakartaSans',
          fontWeight: FontWeight.w500,
          letterSpacing: -0.17,
          height: 1),
    );
  }
}

/// SearchInputField Widget
///
/// A reusable Flutter widget for displaying a search input field with optional icon.
/// This widget is designed to capture user search queries, typically used for filtering
/// and searching within a list or database of items.
///
/// Properties:
/// - `screenWidth`: The width of the screen, used for responsive design.
/// - `screenHeight`: The height of the screen, used for responsive design.
/// - `icon`: An optional IconData for displaying an icon within the input field.
/// - `controller`: A [TextEditingController] for managing and accessing the input text.
/// - `inputAction`: Specifies the [TextInputAction] to define keyboard actions.
/// - `onChanged`: A callback function triggered when the input text changes.
///
/// Usage:
/// The `SearchInputField` widget is versatile and can be easily integrated into
/// various Flutter applications. It is commonly used to enable users to perform
/// searches, filter lists, and refine content. The optional `icon` property allows
/// you to include a search icon within the input field for a visual cue.
///
/// Example:
///
/// ```dart
/// SearchInputField(
///   screenWidth: MediaQuery.of(context).size.width,
///   screenHeight: MediaQuery.of(context).size.height,
///   icon: Icons.search,
///   controller: _searchTextController,
///   inputAction: TextInputAction.search,
///   onChanged: (value) {
///     // Handle search query changes here.
///     // Implement filtering or searching logic.
///   },
/// )
/// ```

class SearchInputField extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;
  final IconData? icon;
  final TextEditingController controller;
  final TextInputAction inputAction;
  final bool canONChangedUsed;
  final String hintText;
  final Function(String)? onChanged;
  const SearchInputField(
      {super.key,
      required this.screenWidth,
      required this.screenHeight,
      required this.icon,
      required this.controller,
      required this.inputAction,
      required this.canONChangedUsed,
      required this.hintText,
      required this.onChanged});

  @override
  State<SearchInputField> createState() => _SearchInputFieldState();
}

class _SearchInputFieldState extends State<SearchInputField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widget.screenWidth * 0.04),
      child: Column(
        children: [
          SizedBox(
            height: widget.screenHeight * 0.07,
            child: TextFormField(
              onChanged: widget.onChanged,
              controller: widget.controller,
              textInputAction: widget.inputAction,
              keyboardType: TextInputType.text,
              textAlignVertical: TextAlignVertical.bottom,
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: const TextStyle(
                  color: Color.fromRGBO(193, 193, 193, 1),

                  fontFamily: 'PlusJakartaSans',
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  letterSpacing: -0.165,
                  height: 18 / 14, // line-height / font-size
                ),
                prefixIcon: widget.icon != null
                    ? Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: widget.screenWidth * 0.03),
                        child: const Icon(
                          Icons.search,
                          color: Color.fromRGBO(193, 193, 193, 1),
                        ),
                      )
                    : null,
                border: OutlineInputBorder(
                    gapPadding: 12,
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                        width: 1, color: Color.fromRGBO(193, 193, 193, 1))),
                contentPadding: EdgeInsets.symmetric(
                  vertical: widget.screenHeight * 0.07, // No vertical padding
                  horizontal: widget.screenWidth * 0.07,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// MedicationAddScreen Widget
///
/// A Flutter screen widget used for adding or editing medication information.
/// It includes input fields for medication name, daily dosage, and milligrams.
///
/// Properties:
/// - `existingMedication`: An optional Medication object for editing existing data.
///
/// Usage:
/// The `MedicationAddScreen` widget is used within a navigation stack to add
/// or edit medication information. It provides an interface for users to input
/// or modify details about their medications, including name, dosage frequency,
/// and milligrams per dose.
///
/// When used to edit an existing medication, `existingMedication` should be
/// provided to pre-fill the input fields with the medication's current values.
///
/// Example:
///
/// ```dart
/// Navigator.of(context).push(MaterialPageRoute(
///   builder: (context) => MedicationAddScreen(existingMedication: medication),
/// ));
/// ```

class MedicationAddScreen extends StatefulWidget {
  final Medication? existingMedication;
  const MedicationAddScreen({super.key, this.existingMedication});

  @override
  State<MedicationAddScreen> createState() => _MedicationAddScreenState();
}

class _MedicationAddScreenState extends State<MedicationAddScreen> {
  final TextEditingController _noTimesPerDay = TextEditingController();
  final TextEditingController _miligrams = TextEditingController();
  final TextEditingController _medicationName = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    if (widget.existingMedication != null) {
      // Populate the controllers with existing data for editing
      _medicationName.text = widget.existingMedication!.medicationName;
      _noTimesPerDay.text = widget.existingMedication!.noTimesPerDay.toString();
      _miligrams.text = widget.existingMedication!.miligrams.toString();
    }
    super.initState();
  }

  void _saveMedication() {
    if (widget.existingMedication != null) {
      final editedMedication = Medication(
        _medicationName.text,
        int.parse(_noTimesPerDay.text),
        int.parse(_miligrams.text),
      );

      final index =
          MedicationListProvider.medication.indexOf(widget.existingMedication!);
      if (index != -1) {
        MedicationListProvider.medication[index] = editedMedication;
      }
    } else {
      MedicationListProvider.addMedication(
        _medicationName.text,
        int.parse(_noTimesPerDay.text),
        int.parse(_miligrams.text),
      );
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest;
          final screenWidth = size.width;
          final screenHeight = size.height;
          return SingleChildScrollView(
            reverse: true,
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
                        "Medications",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.w700,
                          fontFamily: "PlusJakartaSans",
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: screenHeight * 0.06,
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.04),
                        child: const InputLabels(label: "Medication"),
                      ),
                      SizedBox(
                        height: screenHeight * 0.02,
                      ),
                      SearchInputField(
                        canONChangedUsed: false,
                        screenWidth: screenWidth,
                        screenHeight: screenHeight,
                        icon: null,
                        controller: _medicationName,
                        inputAction: TextInputAction.next,
                        hintText: 'Mediction Name',
                        onChanged: null,
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.03,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                      child: const InputLabels(
                          label: "How often do you take it per day"),
                    ),
                    SizedBox(
                      height: screenHeight * 0.02,
                    ),
                    IcreamentDecreamentInputField(
                      screenWidth: screenWidth,
                      screenHeight: screenHeight,
                      controller: _noTimesPerDay,
                      inputAction: TextInputAction.next,
                    )
                  ],
                ),
                SizedBox(
                  height: screenHeight * 0.03,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                      child: const InputLabels(
                          label: "How many milligrams do you take"),
                    ),
                    SizedBox(
                      height: screenHeight * 0.02,
                    ),
                    IcreamentDecreamentInputField(
                      screenWidth: screenWidth,
                      screenHeight: screenHeight,
                      controller: _miligrams,
                      inputAction: TextInputAction.done,
                    )
                  ],
                ),
                SizedBox(
                  height: screenHeight * 0.35,
                ),
                Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                        width: screenWidth * 0.5,
                        height: screenHeight * 0.07,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                shape: const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                elevation: 0,
                                backgroundColor:
                                    const Color.fromRGBO(110, 182, 255, 1),
                                foregroundColor: Colors.white),
                            onPressed: widget.existingMedication == null
                                ? () {
                                    MedicationListProvider.addMedication(
                                        _medicationName.text,
                                        int.parse(_noTimesPerDay.text),
                                        int.parse(_miligrams.text));

                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      builder: (context) =>
                                          const MedicationScreen(),
                                    ));
                                  }
                                : () {
                                    setState(() {
                                      _saveMedication();
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const MedicationScreen()));
                                    });
                                  },
                            child: Text(
                              widget.existingMedication == null
                                  ? "Add Medication"
                                  : "Save Changes",
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'PlusJakartaSans',
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: -0.17,
                                  height: 1),
                            )))),
                Padding(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom))
              ],
            ),
          );
        },
      )),
      resizeToAvoidBottomInset: false,
    );
  }
}

/// IncrementDecrementInputField Widget
///
/// This Flutter widget represents a customizable input field for numeric values,
/// with built-in increment and decrement controls. It is designed to be used in
/// forms or UIs where users need to input numerical data.
///
/// Properties:
/// - `screenWidth`: The width of the screen, used for responsive design.
/// - `screenHeight`: The height of the screen, used for responsive design.
/// - `controller`: A [TextEditingController] to manage and access the input text.
/// - `inputAction`: Specifies the [TextInputAction] to define keyboard actions.
///
/// Usage:
/// This widget can be employed in various contexts where numeric input is required.
/// It provides visual cues for users to increase or decrease numerical values and
/// handles user interactions for data entry.

class IcreamentDecreamentInputField extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;
  final TextEditingController controller;
  final TextInputAction inputAction;

  const IcreamentDecreamentInputField({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
    required this.controller,
    required this.inputAction,
  });

  @override
  State<IcreamentDecreamentInputField> createState() =>
      _IcreamentDecreamentInputFieldState();
}

class _IcreamentDecreamentInputFieldState
    extends State<IcreamentDecreamentInputField> {
  int _number = 0;

  @override
  void initState() {
    super.initState();
    _number = 0; // Set an initial default value

    // Listen to changes in the text field
    widget.controller.addListener(() {
      setState(() {
        // Parse the input and set _number based on the input value
        _number = int.tryParse(widget.controller.text) ?? 0;
      });
    });
  }

  void _incrementNumber() {
    setState(() {
      _number++;
      widget.controller.text = _number.toString();
    });
  }

  void _decrementNumber() {
    setState(() {
      if (_number > 0) {
        _number--;
        widget.controller.text = _number.toString();
      }
    });
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widget.screenWidth * 0.04),
      child: Column(
        children: [
          SizedBox(
            height: widget.screenHeight * 0.07,
            child: TextFormField(
              controller: widget.controller,
              textInputAction: widget.inputAction,
              keyboardType: TextInputType.number, // Use number input type
              textAlignVertical: TextAlignVertical.bottom,
              decoration: InputDecoration(
                hintText: "Enter a number",
                hintStyle: const TextStyle(
                  color: Color.fromRGBO(193, 193, 193, 1),

                  fontFamily: 'PlusJakartaSans',
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  letterSpacing: -0.165,
                  height: 18 / 14, // line-height / font-size
                ),
                suffixIcon: SizedBox(
                  height: widget.screenHeight * 0.06,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                          onTap: _incrementNumber,
                          child: SvgPicture.asset('assets/Icons/up.svg')

                          // const Icon(
                          //   Icons.arrow_drop_up,
                          //   color: Color.fromRGBO(193, 193, 193, 1),
                          // ),
                          ),
                      SizedBox(
                        height: widget.screenHeight * 0.007,
                      ),
                      GestureDetector(
                          onTap: _decrementNumber,
                          child: SvgPicture.asset('assets/Icons/down.svg')

                          // const Icon(
                          //   Icons.arrow_drop_down,
                          //   color: Color.fromRGBO(193, 193, 193, 1),
                          // ,  )
                          ),
                    ],
                  ),
                ),
                border: OutlineInputBorder(
                    gapPadding: 12,
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                        width: 1, color: Color.fromRGBO(193, 193, 193, 1))),
                contentPadding: EdgeInsets.symmetric(
                  vertical: widget.screenHeight * 0.07, // No vertical padding
                  horizontal: widget.screenWidth * 0.07,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
