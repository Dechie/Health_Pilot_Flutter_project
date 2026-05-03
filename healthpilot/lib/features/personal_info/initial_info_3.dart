import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:healthpilot/data/constants.dart';
import 'package:healthpilot/features/personal_info/initial_info_4.dart';


class InitialInfoThird extends StatefulWidget {
  const InitialInfoThird({super.key});

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
    final cs = Theme.of(context).colorScheme;
    final iconMuted = cs.onSurface.withValues(alpha: 0.75);
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
      backgroundColor: cs.surface,
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
                            color: cs.primary.withValues(alpha: 0.25),
                            borderRadius:
                                BorderRadius.circular(size.width * 0.05),
                          ),
                          child: IconButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(Icons.arrow_back),
                            color: cs.primary,
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
                              color: cs.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SvgPicture.asset(
                      translateIcon,
                      width: size.width * 0.045,
                      height: size.width * 0.045,
                      fit: BoxFit.contain,
                      colorFilter: ColorFilter.mode(
                        cs.onSurface,
                        BlendMode.srcIn,
                      ),
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
                  child: Text(
                    "Do you have any allergies?",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: cs.onSurface,
                    ),
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
                  style: TextStyle(color: cs.onSurface),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: cs.surface,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 10),
                    hintText: 'Search Allergies',
                    hintStyle: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w300,
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: iconMuted,
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
                        child: Icon(
                          Icons.highlight_remove_rounded,
                          color: iconMuted,
                        ),
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: cs.outline),
                      borderRadius: BorderRadius.circular(13.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: cs.outline),
                      borderRadius: BorderRadius.circular(13.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: cs.primary, width: 2),
                      borderRadius: BorderRadius.circular(13.0),
                    ),
                  ),
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
                            Text(
                              'Choose all that apply:',
                              style: TextStyle(
                                fontFamily: ' PlusJakartaSans',
                                fontSize: 16.0,
                                fontWeight: FontWeight.w600,
                                color: cs.onSurface,
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
                                          Text(
                                            'No match found',
                                            style: TextStyle(
                                              fontFamily: ' PlusJakartaSans',
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.w400,
                                              color: cs.onSurface,
                                            ),
                                          ),
                                          SizedBox(height: size.height * 0.005),
                                          SizedBox(
                                            width: size.width * 0.5,
                                            child: Text(
                                              'Make sure you spell your allergy correctly',
                                              style: TextStyle(
                                                fontFamily: ' PlusJakartaSans',
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.w300,
                                                color: cs.onSurfaceVariant,
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
                                              title: Text(
                                                allergy,
                                                style: TextStyle(
                                                  color: cs.onSurface,
                                                ),
                                              ),
                                              trailing: selectedAllergies
                                                      .contains(allergy)
                                                  ? Icon(
                                                      Icons.add_circle,
                                                      color: cs.primary,
                                                    )
                                                  : Icon(
                                                      Icons.add_circle_outline,
                                                      color: cs.primary,
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
                                                height: size.width * 0.02,
                                                color: cs.outline
                                                    .withValues(alpha: 0.35),
                                              ),
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
                            Text(
                              'Selected Allergies:',
                              style: TextStyle(
                                fontFamily: ' PlusJakartaSans',
                                fontSize: 16.0,
                                fontWeight: FontWeight.w600,
                                color: cs.onSurface,
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
                                          title: Text(
                                            allergy,
                                            style: TextStyle(
                                              color: cs.onSurface,
                                            ),
                                          ),
                                          trailing: IconButton(
                                            icon: Icon(
                                              Icons.highlight_remove_rounded,
                                              color: cs.error,
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
                                            height: size.width * 0.02,
                                            color: cs.outline
                                                .withValues(alpha: 0.35),
                                          ),
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
                          Text(
                            'No allergies added',
                            style: TextStyle(
                              fontFamily: ' PlusJakartaSans',
                              fontSize: 20.0,
                              fontWeight: FontWeight.w400,
                              color: cs.onSurface,
                            ),
                          ),
                          SizedBox(height: size.height * 0.005),
                          SizedBox(
                            width: size.width * 0.5,
                            child: Text(
                              'Search the allergies you have and press the + button to add them',
                              style: TextStyle(
                                fontFamily: ' PlusJakartaSans',
                                fontSize: 14.0,
                                fontWeight: FontWeight.w300,
                                color: cs.onSurfaceVariant,
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
                      backgroundColor: cs.primary,
                      foregroundColor: cs.onPrimary,
                      padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.25,
                          vertical: MediaQuery.of(context).size.height * 0.015),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  child: Text(
                    'Finish',
                    style: TextStyle(color: cs.onPrimary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
