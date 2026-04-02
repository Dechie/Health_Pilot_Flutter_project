import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:healthpilot/data/constants.dart';

import 'package:healthpilot/theme/app_theme.dart';
import 'package:intl_mobile_field/intl_mobile_field.dart';

class SetupPersonalDoctor extends StatefulWidget {
  final Function() add;
  const SetupPersonalDoctor({super.key, required this.add});

  @override
  State<SetupPersonalDoctor> createState() => _SetupPersonalDoctorState();
}

class _SetupPersonalDoctorState extends State<SetupPersonalDoctor> {
  int radioBtnStatus = 1;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding:
              EdgeInsets.symmetric(horizontal: 20, vertical: size.width * 0.08),
          child: Form(
            child: Column(
              children: [
                Row(
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
                            "Setup Personal Doctor",
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
                SizedBox(
                  height: size.height * 0.05,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'First Name',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 14,
                      ),
                    ),
                    TextFormField(
                      maxLines: 1,
                      decoration: InputDecoration(
                        // labelText: 'First Name',
                        // labelStyle: const TextStyle(color: Colors.black),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: size.height * 0.015,
                            horizontal: size.width * 0.03),
                        border: const OutlineInputBorder(),
                        isDense: true,
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromARGB(255, 214, 210, 210)),
                        ),
                      ),
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                    ),
                  ],
                ),
                SizedBox(
                  height: size.height * 0.03,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Last Name',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 14,
                      ),
                    ),
                    TextFormField(
                      maxLines: 1,
                      decoration: InputDecoration(
                        // labelText: 'Last Name',
                        // labelStyle: const TextStyle(color: Colors.black),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: size.height * 0.015,
                            horizontal: size.width * 0.03),
                        // label: Text('First Name'),
                        border: const OutlineInputBorder(),
                        isDense: true,
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                      ),
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                    ),
                  ],
                ),
                SizedBox(
                  height: size.height * 0.03,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Personal Doctor Type',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 14,
                      ),
                    ),
                    CustomDropDownTextFild(
                      customDropDownModels: [
                        CustomDropDownModel(
                          name: 'Psychiatrists',
                          value: 'Psychiatrists',
                        ),
                        CustomDropDownModel(
                          name: 'Internists',
                          value: 'Internists',
                        ),
                        CustomDropDownModel(
                          name: 'Nephrologists',
                          value: 'Nephrologists',
                        ),
                        CustomDropDownModel(
                          name: 'Neurologists',
                          value: 'Neurologists',
                        ),
                        CustomDropDownModel(
                          name: 'Hematologists',
                          value: 'Hematologists',
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: size.height * 0.03,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Email',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 14,
                      ),
                    ),
                    TextFormField(
                      maxLines: 1,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            vertical: size.height * 0.015,
                            horizontal: size.width * 0.03),
                        border: const OutlineInputBorder(),
                        isDense: true,
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                    ),
                  ],
                ),
                SizedBox(
                  height: size.height * 0.03,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Phone Number',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 14,
                      ),
                    ),
                    IntlMobileField(
                      disableLengthCheck: true,
                      dropdownIconPosition: Position.trailing,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            vertical: size.height * 0.015,
                            horizontal: size.width * 0.03),
                        border: const OutlineInputBorder(),
                        isDense: true,
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.done,
                    ),
                    SizedBox(
                      height: size.height * 0.03,
                    ),
                    const Text(
                      'How frequently do you want your report to be sent',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                    ),
                    SizedBox(
                      height: size.height * 0.02,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: size.width * 0.3,
                            height: size.height * 0.08,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    CustomRadioBtn(
                                      value: 1,
                                      groupValue: radioBtnStatus,
                                      onChanged: (value) {
                                        setState(() {
                                          radioBtnStatus = value;
                                        });
                                      },
                                    ),
                                    SizedBox(
                                      width: size.width * 0.02,
                                    ),
                                    const Text(
                                      'Daily',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    CustomRadioBtn(
                                      value: 2,
                                      groupValue: radioBtnStatus,
                                      onChanged: (value) {
                                        setState(() {
                                          radioBtnStatus = value;
                                        });
                                      },
                                    ),
                                    SizedBox(
                                      width: size.width * 0.02,
                                    ),
                                    const Text(
                                      'Weekly',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            // width: size.width * 0.3,
                            height: size.height * 0.08,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    CustomRadioBtn(
                                      value: 3,
                                      groupValue: radioBtnStatus,
                                      onChanged: (value) {
                                        setState(() {
                                          radioBtnStatus = value;
                                        });
                                      },
                                    ),
                                    SizedBox(
                                      width: size.width * 0.02,
                                    ),
                                    const Text(
                                      'Bi-Week',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    CustomRadioBtn(
                                      value: 4,
                                      groupValue: radioBtnStatus,
                                      onChanged: (value) {
                                        setState(() {
                                          radioBtnStatus = value;
                                        });
                                      },
                                    ),
                                    SizedBox(
                                      width: size.width * 0.02,
                                    ),
                                    const Text(
                                      'Monthly',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: size.height * 0.1,
                ),
                ElevatedButton(
                  onPressed: () {
                    widget.add();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(110, 182, 255, 1),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.25,
                        vertical: size.height * 0.02),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomRadioBtn extends StatefulWidget {
  final int value;
  final int groupValue;
  final Function(int value) onChanged;
  const CustomRadioBtn(
      {super.key,
      required this.value,
      required this.groupValue,
      required this.onChanged});

  @override
  State<CustomRadioBtn> createState() => _CustomRadioBtnState();
}

class _CustomRadioBtnState extends State<CustomRadioBtn> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => widget.onChanged(widget.value),
      child: Container(
        padding: EdgeInsets.all(size.width * 0.004),
        height: size.height * 0.025,
        width: size.height * 0.025,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size.height * 0.125),
          // color: Colors.blue,
          border:
              Border.all(color: const Color.fromARGB(23, 0, 0, 0), width: 2),
        ),
        child: widget.groupValue == widget.value
            ? Container(
                height: size.height * 0.015,
                width: size.height * 0.015,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(size.height * 0.075),
                  color: const Color.fromRGBO(110, 182, 255, 1),
                  // border:
                  //     Border.all(color: const Color.fromARGB(23, 0, 0, 0), width: 2),
                ),
              )
            : null,
      ),
    );
  }
}

class CustomDropDownTextFild extends StatefulWidget {
  final List<CustomDropDownModel> customDropDownModels;
  const CustomDropDownTextFild({super.key, required this.customDropDownModels});

  @override
  State<CustomDropDownTextFild> createState() => _CustomDropDownTextFildState();
}

class _CustomDropDownTextFildState extends State<CustomDropDownTextFild> {
  String selectedValue = '';
  final _textEditingController = TextEditingController();

  void _onTap(String value) {
    selectedValue = value;

    setState(() {
      _textEditingController.text = value;
    });
  }

  void _showDialog() {
    final size = MediaQuery.of(context).size;

    showDialog(
      barrierColor: const Color.fromARGB(0, 255, 193, 7),
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(size.width * 0.08),

          alignment: const Alignment(0, 0.3),

          // elevation: 0,
          child: Container(
            decoration: BoxDecoration(color: Colors.white, boxShadow: [
              BoxShadow(
                blurRadius: 35,
                spreadRadius: 0,
                color:
                    const Color.fromRGBO(46, 46, 46, 1.000).withOpacity(0.07),
              )
            ]),
            padding: EdgeInsets.all(size.width * 0.06),
            height: size.height * 0.25,
            child: ListView.builder(
              itemCount: widget.customDropDownModels.length,
              itemBuilder: (context, index) {
                // print(_textEditingController.text);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _onTap(widget.customDropDownModels[index].value);
                      Navigator.of(context).pop();
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: size.width * 0.055),
                        child: Text(
                          widget.customDropDownModels[index].name,
                          style: TextStyle(
                            color: selectedValue ==
                                    widget.customDropDownModels[index].value
                                ? const Color.fromRGBO(110, 182, 255, 1)
                                : Colors.black,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (selectedValue ==
                          widget.customDropDownModels[index].value)
                        Padding(
                          padding: EdgeInsets.only(bottom: size.width * 0.055),
                          child: const Icon(
                            Icons.check,
                            size: 20,
                            color: Color.fromRGBO(110, 182, 255, 1),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return TextFormField(
      controller: _textEditingController,
      readOnly: true,
      decoration: InputDecoration(
        suffixIcon: GestureDetector(
          onTap: () => _showDialog(),
          child: const Icon(
            Icons.expand_more,
            size: 24,
          ),
        ),
        hintText: 'Select doctor profession',
        hintStyle: const TextStyle(
          fontWeight: FontWeight.w400,
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 14,
        ),
        contentPadding: EdgeInsets.symmetric(
            vertical: size.height * 0.015, horizontal: size.width * 0.03),
        border: const OutlineInputBorder(),
        isDense: true,
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
      ),
    );
  }
}

class CustomDropDownModel {
  final String name;
  final String value;

  CustomDropDownModel({
    required this.name,
    required this.value,
  });
}
