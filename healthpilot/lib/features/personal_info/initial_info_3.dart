import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:healthpilot/data/constants.dart';
import 'package:healthpilot/features/personal_info/initial_info_4.dart';

import '../../theme/app_theme.dart';

class InitialInfoThird extends StatefulWidget {
  const InitialInfoThird({Key? key}) : super(key: key);

  @override
  State<InitialInfoThird> createState() => _InitialInfoThird();
}

class _InitialInfoThird extends State<InitialInfoThird> {
  List<String> allergies = [];
  List<String> selectedAllergies = [];
  List<String> availableAllergies = [
    "Pollen Allergy (Hay Fever)",
    "Dust Mite Allergy",
    "Pet Allergy (Cats)",
    "Pet Allergy (Dogs)",
    "Food Allergy (Peanuts)",
    "Food Allergy (Tree nuts)",
    "Food Allergy (Milk)",
    "Food Allergy (Eggs)",
    "Food Allergy (Wheat)",
    "Food Allergy (Soy)",
    "Food Allergy (Fish)",
    "Food Allergy (Shellfish)",
    "Insect Sting Allergy (Bee stings)",
    "Insect Sting Allergy (Wasp stings)",
    "Insect Sting Allergy (Hornet stings)",
    "Insect Sting Allergy (Fire ant stings)",
    "Latex Allergy",
    "Medication Allergy (Penicillin)",
    "Medication Allergy (NSAIDs)",
    "Medication Allergy (Aspirin)",
    "Medication Allergy (Chemotherapy drugs)",
    "Mold Allergy",
    "Cosmetic and Skin Allergies (Fragrances)",
    "Cosmetic and Skin Allergies (Skin creams and lotions)",
    "Anaphylaxis Trigger (Severe peanut allergies)",
    "Environmental Allergies (Dust)",
    "Environmental Allergies (Mold)",
    "Environmental Allergies (Pollen)",
    "Environmental Allergies (Animal dander)",
    "Cold Weather Allergy (Cold urticaria)",
    "Sun Allergy (Photosensitivity)",
    // Add other allergies here
  ];

  TextEditingController searchController = TextEditingController();
  List<String> get filteredAllergies {
    final searchText = searchController.text.toLowerCase();
    return availableAllergies
        .where((allergy) => allergy.toLowerCase().contains(searchText))
        .toList();
  }

  final _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  bool textFieldIsOnfocused = false;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    _focusNode.addListener(
      () {
        if (_focusNode.hasFocus) {
          textFieldIsOnfocused = true;
        } else {
          textFieldIsOnfocused = false;
        }
      },
    );

    return Scaffold(
      appBar: (!textFieldIsOnfocused)
          ? PreferredSize(
              preferredSize: Size(double.infinity, size.height * 0.1),
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 30,
                  bottom: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: size.width * 0.1,
                          height: size.width * 0.1,
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(110, 182, 255, 0.25),
                            borderRadius:
                                BorderRadius.circular(size.width * 0.05),
                          ),
                          child: IconButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(Icons.arrow_back),
                            color: const Color.fromRGBO(110, 182, 255, 1),
                            iconSize: size.width * 0.055,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            size.width * 0.05,
                            0,
                            0,
                            0,
                          ),
                          child: Text(
                            "One Last Step",
                            style: TextStyle(
                              fontSize: size.width * 0.05,
                              fontWeight: FontWeight.w600,
                              fontFamily: "PlusJakartaSans",
                            ),
                          ),
                        ),
                      ],
                    ),
                    SvgPicture.asset(
                      'assets/images/Vector.svg',
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
              ),
            )
          : null,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: size.height * 0.02,
              ),
              if (!textFieldIsOnfocused)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                  child: const Text(
                    "Do you have any allergies?",
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: Colors.black),
                    textAlign: TextAlign.left,
                    maxLines: 2,
                  ),
                ),
              SizedBox(
                height: size.height * 0.03,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: TextField(
                  controller: searchController,
                  onChanged: (value) {
                    setState(() {});
                  },
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      border: OutlineInputBorder(
                        // Use OutlineInputBorder for visible borders
                        borderSide: const BorderSide(
                            color: Color.fromRGBO(41, 41, 41, 0.5)),
                        borderRadius: BorderRadius.circular(
                            13.0), // Adjust the radius as needed
                      ),
                      hintText: 'Search Allergies',
                      hintStyle: const TextStyle(
                          fontWeight: FontWeight.w300, fontSize: 14),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color.fromRGBO(41, 41, 41, 0.5),
                      ),
                      suffix: Container(
                        padding: EdgeInsets.only(
                          right: size.width * 0.02,
                          top: size.width * 0.01,
                        ),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              searchController.text = '';
                            });
                          },
                          child: const Icon(
                            Icons.highlight_remove_rounded,
                            color: Color.fromRGBO(41, 41, 41, 0.5),
                          ),
                        ),
                      )),
                ),
              ),
              SizedBox(height: size.height * 0.03),
              searchController.text.isNotEmpty || selectedAllergies.isNotEmpty
                  ? Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: size.width * 0.05),
                      width: double.infinity,
                      height: size.height * 0.6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (searchController.text.isNotEmpty)
                            const Text(
                              'Choose all that apply:',
                              style: TextStyle(
                                fontFamily: ' PlusJakartaSans',
                                fontSize: 16.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          if (searchController.text.isNotEmpty)
                            SizedBox(
                              height: size.height * 0.5,
                              child: filteredAllergies.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SvgPicture.asset(itemNotFound),
                                          const Text(
                                            'No match found',
                                            style: TextStyle(
                                              fontFamily: ' PlusJakartaSans',
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          SizedBox(height: size.height * 0.005),
                                          SizedBox(
                                            width: size.width * 0.5,
                                            child: const Text(
                                              'Make sure you spell your allergy correctly',
                                              style: TextStyle(
                                                fontFamily: ' PlusJakartaSans',
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.w300,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: filteredAllergies.length,
                                      itemBuilder: (context, index) {
                                        final allergy =
                                            filteredAllergies[index];
                                        return Column(
                                          children: [
                                            ListTile(
                                              title: Text(allergy),
                                              trailing: selectedAllergies
                                                      .contains(allergy)
                                                  ? const Icon(
                                                      Icons.add_circle,
                                                      color: Color.fromRGBO(
                                                          110, 182, 255, 1),
                                                    )
                                                  : const Icon(
                                                      Icons.add_circle_outline,
                                                      color: Color.fromRGBO(
                                                          110, 182, 255, 1),
                                                    ),
                                              onTap: () {
                                                setState(() {
                                                  if (selectedAllergies
                                                      .contains(allergy)) {
                                                    selectedAllergies
                                                        .remove(allergy);
                                                  } else {
                                                    selectedAllergies
                                                        .add(allergy);
                                                  }
                                                });
                                              },
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                right: size.width * 0.07,
                                                left: size.width * 0.04,
                                              ),
                                              child: Divider(
                                                  height: size.width * 0.02),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                            ),
                          // const SizedBox(height: 10.0),
                          if (selectedAllergies.isNotEmpty &&
                              !textFieldIsOnfocused &&
                              searchController.text.isEmpty)
                            const Text(
                              'Selected Allergies:',
                              style: TextStyle(
                                fontFamily: ' PlusJakartaSans',
                                fontSize: 16.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                          const SizedBox(height: 8.0),
                          if (selectedAllergies.isNotEmpty &&
                              !textFieldIsOnfocused &&
                              searchController.text.isEmpty)
                            SingleChildScrollView(
                              child: SizedBox(
                                height: size.height * 0.5,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: selectedAllergies.map((allergy) {
                                    return Column(
                                      children: [
                                        ListTile(
                                          title: Text(allergy),
                                          trailing: IconButton(
                                            icon: const Icon(
                                              Icons.highlight_remove_rounded,
                                              color: Colors.red,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                selectedAllergies
                                                    .remove(allergy);
                                              });
                                            },
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                            right: size.width * 0.07,
                                            left: size.width * 0.04,
                                          ),
                                          child: Divider(
                                              height: size.width * 0.02),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                        ],
                      ),
                    )
                  : SizedBox(
                      width: double.infinity,
                      height: size.height * 0.6,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'No allergies added',
                            style: TextStyle(
                              fontFamily: ' PlusJakartaSans',
                              fontSize: 20.0,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(height: size.height * 0.005),
                          SizedBox(
                            width: size.width * 0.5,
                            child: const Text(
                              'Search the allergies you have and press the + button to add them',
                              style: TextStyle(
                                fontFamily: ' PlusJakartaSans',
                                fontSize: 14.0,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const InitialInfoFinal()), // Navigate to the DestinationPage
                    );
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(110, 182, 255, 1),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.25,
                          vertical: MediaQuery.of(context).size.height * 0.015),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  child: const Text('Finish'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
