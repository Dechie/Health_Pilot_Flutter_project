/// PersonalInformationScreen
///
/// A screen for capturing and displaying personal information.
///
/// This screen allows users to enter and view their personal information
/// including profile photo, first name, last name, email, and phone number.
/// It also provides options for setting up emergency contacts, personal doctor,
/// and food and nutrition tracking.
///
/// Properties:
/// None
///
/// Usage:
/// This screen is typically used as part of user onboarding or profile setup
/// process. It collects various personal details and allows users to set up
/// additional premium features.
library;

import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:healthpilot/core/network/api_error.dart';
import 'package:healthpilot/core/widgets/setup_promo_card.dart';
import 'package:healthpilot/data/constants.dart';
import 'package:healthpilot/features/food_nutrition/food_nutrition_history_screen.dart';
import 'package:healthpilot/features/food_nutrition/food_nutrition_tracking_screen.dart';
import 'package:healthpilot/features/personal_doctor/setup_personal_doctor.dart';
import 'package:healthpilot/features/profile/profile_provider.dart';
import 'package:healthpilot/features/subscription/subscription_and_payment_screen.dart';
import 'package:healthpilot/features/profile/emergency_contact_personal_information.dart'
    as contact;
import 'package:image_picker/image_picker.dart';
import 'package:intl_mobile_field/intl_mobile_field.dart';
import 'package:line_icons/line_icons.dart';
import 'package:healthpilot/features/profile/language_translation.dart';
import 'package:provider/provider.dart';
// import 'package:healthpilot/features/personal_doctor/personal_information.dart' as doctor;
// import 'package:healthpilot/features/emergency_contact/personal_information.dart' as emergency;

class PersonalInformationScreen extends StatefulWidget {
  const PersonalInformationScreen({super.key});

  @override
  State<PersonalInformationScreen> createState() =>
      _PersonalInformationScreenState();
}

class _PersonalInformationScreenState extends State<PersonalInformationScreen> {
  String? _profileImagePath;
  bool _saving = false;

  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _emailCtrl;

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileProvider>().profile;
    _firstNameCtrl = TextEditingController(text: profile.firstName ?? '');
    _lastNameCtrl  = TextEditingController(text: profile.lastName  ?? '');
    _emailCtrl     = TextEditingController(text: profile.email     ?? '');
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickProfilePhoto() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file != null && mounted) {
      setState(() => _profileImagePath = file.path);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final updated = context.read<ProfileProvider>().profile.copyWith(
            firstName: _firstNameCtrl.text.trim(),
            lastName: _lastNameCtrl.text.trim(),
            email: _emailCtrl.text.trim(),
            avatarAssetPath: _profileImagePath,
          );
      await context.read<ProfileProvider>().save(updated);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated.')),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      final msg = switch (e) {
        ServerError(:final message) => message,
        NetworkError() => 'No internet connection.',
        _ => 'Update failed.',
      };
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void showAlertDialogue() {
    showDialog(
      context: context,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(10), // Adjust the radius as needed
            ),
            title: const Text(
              "Premium Feature",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: "Plus Jakarta Sans",
                fontSize: 18,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.165,
              ),
            ),
            content: const Text(
              "This feature is only available to premium users. To access this feature please upgrade to a premium subscription",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: "Plus Jakarta Sans",
                fontSize: 13,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.165,
              ),
            ),
            actions: [
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 13),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                        const Color.fromRGBO(110, 182, 255, 1),
                      ),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                    child: Container(
                      width: 100,
                      height: 28,
                      alignment: Alignment.center,
                      child: const Text(
                        "Subscribe",
                        style: TextStyle(
                          fontFamily: "Plus Jakarta Sans",
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
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
                          "Personal Information",
                          style: TextStyle(
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.w600,
                            fontFamily: "PlusJakartaSans",
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          top: screenHeight * 0.04,
                          left: screenWidth * 0.2,
                        ),
                        child: GestureDetector(
                          onTap: () => openLanguageScreen(context),
                          child: SizedBox(
                            width: screenWidth * 0.04,
                            height: screenWidth * 0.04,
                            child: SvgPicture.asset(
                              translateIcon,
                              fit: BoxFit.contain,
                              colorFilter: ColorFilter.mode(
                                cs.onSurface,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: screenHeight * 0.03,
                  ),
                  GestureDetector(
                    onTap: _pickProfilePhoto,
                    child: Stack(
                      children: [
                        SizedBox(
                          width: screenWidth * 0.3,
                          height: screenWidth * 0.3,
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(screenWidth * 0.15),
                            child: _profileImagePath != null
                                ? Image.file(
                                    File(_profileImagePath!),
                                    fit: BoxFit.cover,
                                  )
                                : const Image(
                                    image: AssetImage(
                                      'assets/images/personel.png',
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                        Positioned(
                          bottom: screenWidth * 0.000,
                          right: screenWidth * 0.03,
                          child: Container(
                            width: screenWidth * 0.05,
                            height: screenWidth * 0.05,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                screenWidth * 0.025,
                              ),
                              color: Colors.white,
                            ),
                            child: Icon(
                              LineIcons.edit,
                              size: screenWidth * 0.03,
                              color: const Color.fromARGB(255, 73, 70, 70),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: screenHeight * 0.02),
                    child: Text(
                      "Tap to upload your profile photo",
                      style: TextStyle(
                        fontFamily: "PlusJakartaSans",
                        fontWeight: FontWeight.w400,
                        fontSize: screenWidth * 0.041,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: screenHeight * 0.05,
                  ),
                  InputFields(
                    label: "First Name",
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                    keyboardType: TextInputType.name,
                    controller: _firstNameCtrl,
                  ),
                  SizedBox(
                    height: screenHeight * 0.02,
                  ),
                  InputFields(
                    label: "Last Name",
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                    keyboardType: TextInputType.name,
                    controller: _lastNameCtrl,
                  ),
                  SizedBox(
                    height: screenHeight * 0.02,
                  ),
                  InputFields(
                    label: "Email",
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailCtrl,
                  ),
                  SizedBox(
                    height: screenHeight * 0.02,
                  ),
                  PhoneInputFields(
                    label: "Phone Number",
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                    keyboardType: TextInputType.phone,
                  ),
                  SetupPromoCard(
                    screenWidth: screenWidth,
                    title: "Set up your Emergency Contacts",
                    description:
                        "Add trusted contacts so HealthPilot can reach them in an emergency.",
                    icon: null,
                    buttonText: "Start setup",
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              const contact.PersonalInformation()));
                    },
                  ),
                  SetupPromoCard(
                    screenWidth: screenWidth,
                    title: "Set up your  personal doctor",
                    description:
                        "Add your doctor’s details so HealthPilot can include them in reports and care coordination.",
                    icon: null,
                    buttonText: "Start setup",
                    onPressed: () {
                      Navigator.of(context).push<void>(
                        MaterialPageRoute<void>(
                          builder: (context) => const SetupPersonalDoctor(),
                        ),
                      );
                    },
                  ),
                  SetupPromoCard(
                    screenWidth: screenWidth,
                    title: SetupPromoCardCopy.foodNutritionTitle,
                    description: SetupPromoCardCopy.foodNutritionDescription,
                    icon: null,
                    buttonText: "Start setup",
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (context) =>
                              const FoodNutritionTrackingScreen(),
                        ),
                      );
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (context) =>
                                const FoodNutritionHistoryScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'View nutrition history',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: Color.fromRGBO(110, 182, 255, 1),
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: _saving ? null : _save,
                    child: Container(
                      width: 231,
                      height: 47,
                      margin: const EdgeInsets.only(
                          top: 35, left: 23, bottom: 25, right: 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color.fromRGBO(110, 182, 255, 1),
                      ),
                      child: Center(
                        child: _saving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Save',
                                style: TextStyle(
                                  fontFamily: "PlusJakartaSans",
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// InputFields
///
/// A widget for capturing general text input with a label.
///
/// This widget provides an input field for capturing text input, such as names,
/// addresses, or other general information. It includes a label displayed above
/// the input field to provide context to the user.
///
/// Properties:
/// - `label` (required): The label displayed above the input field.
/// - `screenWidth` (required): The screen width to calculate layout adjustments.
/// - `screenHeight` (required): The screen height to calculate layout adjustments.
/// - `keyboardType` (required): The type of keyboard to be shown for input.
///
/// Usage:
/// This widget is used to collect various types of textual information from users.
/// It can be used in forms, registration screens, or any other context where text
/// input is needed. The label above the input field helps users understand what
/// information is expected.

class InputFields extends StatelessWidget {
  final String label;
  final double screenWidth;
  final double screenHeight;
  final TextInputType keyboardType;
  final TextEditingController? controller;

  const InputFields(
      {super.key,
      required this.label,
      required this.screenWidth,
      required this.screenHeight,
      required this.keyboardType,
      this.controller});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: "PlusJakartaSans",
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {},
            child: SizedBox(
              height: 45,
              child: TextFormField(
                controller: controller,
                keyboardType: keyboardType,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: const BorderSide()),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: screenWidth * 0.04,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// PhoneInputFields
///
/// A widget for capturing phone number input with label.
///
/// This widget provides an input field for capturing phone numbers along with a label.
/// It utilizes the `IntlMobileField` package to display a dropdown selector for country
/// codes and validates the phone number input.
///
/// Properties:
/// - `label` (required): The label displayed above the input field.
/// - `screenWidth` (required): The screen width to calculate layout adjustments.
/// - `screenHeight` (required): The screen height to calculate layout adjustments.
/// - `keyboardType` (required): The type of keyboard to be shown for input.
///
/// Usage:
/// This widget is used whenever phone number input is required, such as during user
/// registration or verification. It ensures that users enter valid phone numbers and
/// provides a user-friendly way to select country codes.
class PhoneInputFields extends StatelessWidget {
  final String label;
  final double screenWidth;
  final double screenHeight;
  final TextInputType keyboardType;

  const PhoneInputFields({
    super.key,
    required this.label,
    required this.screenWidth,
    required this.screenHeight,
    required this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: "PlusJakartaSans",
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 67, // Set a fixed height for the SizedBox
            child: IntlMobileField(
              dropdownIconPosition: Position.trailing,
              disableLengthCheck: true,
              disableLengthCounter: true,
              initialCountryCode: 'ET',
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: const BorderSide()),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//Payment Screen starts Here

/// PaymentMethodScreen
///
/// A screen for selecting payment methods and entering payment information.
///
/// This screen provides a user interface for users to select payment methods,
/// enter their card information, and proceed to the payment review screen.
///
/// Properties:
/// - None
///
/// Usage:
/// This screen can be navigated to from other parts of the app when users need
/// to make a payment. It allows users to choose from different payment methods
/// and enter their card details for processing the payment.

class PaymentMethodScreen extends StatefulWidget {
  static const routeName = '/PaymentScreen';

  const PaymentMethodScreen({super.key});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isChecked = false;
  bool isPaypalChecked = false;
  bool isChappaChecked = false;
  bool isPaymentChecked = false;
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardHolderNameController =
      TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvcController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: LayoutBuilder(
            // ignore: non_constant_identifier_names
            builder: (context, Constraints) {
          final size = Constraints.biggest;
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
                        screenWidth * 0.04,
                        screenHeight * 0.02,
                        0,
                        0,
                      ),
                      child: Container(
                        width: screenWidth * 0.1,
                        height: screenWidth * 0.1,
                        decoration: BoxDecoration(
                          color: cs.primary.withValues(alpha: 0.25),
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.05),
                        ),
                        child: IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(Icons.arrow_back),
                          color: cs.primary,
                          iconSize: screenWidth * 0.055,
                        ),
                      ),
                    ),
                    Flexible(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          screenWidth * 0.05,
                          screenHeight * 0.03,
                          0,
                          0,
                        ),
                        child: Text(
                          "Checkout",
                          style: TextStyle(
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.w700,
                            fontFamily: "PlusJakartaSans",
                            color: cs.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: screenHeight * 0.04,
                        left: screenWidth * 0.37,
                      ),
                      child: GestureDetector(
                        onTap: () => openLanguageScreen(context),
                        child: SizedBox(
                          width: screenWidth * 0.045,
                          height: screenWidth * 0.045,
                          child: SvgPicture.asset(
                            translateIcon,
                            fit: BoxFit.contain,
                            colorFilter: ColorFilter.mode(
                              cs.onSurface,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                PageTitlesInPayment(
                  title: "Select your payment method",
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                ),
                Row(
                  children: [
                    PaymentMethodButtons(
                        screenWidth: screenWidth,
                        screenHeight: screenHeight,
                        isChecked: isPaymentChecked,
                        icons: Icons.payment_outlined,
                        pngAssetPath: null,
                        checker: () {
                          setState(() {
                            isPaymentChecked = true;
                            isPaypalChecked = false;
                            isChappaChecked = false;
                          });
                        }),
                    PaymentMethodButtons(
                        screenWidth: screenWidth,
                        screenHeight: screenHeight,
                        isChecked: isPaypalChecked,
                        icons: Icons.paypal_outlined,
                        pngAssetPath: null,
                        checker: () {
                          setState(() {
                            isPaymentChecked = false;
                            isPaypalChecked = true;
                            isChappaChecked = false;
                          });
                        }),
                    PaymentMethodButtons(
                        screenWidth: screenWidth,
                        screenHeight: screenHeight,
                        isChecked: isChappaChecked,
                        icons: null,
                        pngAssetPath: "assets/Icons/chapa.svg",
                        checker: () {
                          setState(() {
                            isPaymentChecked = false;
                            isPaypalChecked = false;
                            isChappaChecked = true;
                          });
                        }),
                  ],
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PageTitlesInPayment(
                        title: "Enter your card information",
                        screenWidth: screenWidth,
                        screenHeight: screenHeight,
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                        child: PaymentInputFields(
                          screenWidth: screenWidth * 0.5,
                          screenHeight: screenHeight,
                          keyboardType: TextInputType.emailAddress,
                          hintText: "Card number",
                          suffixIcon: null,
                          prefixIcon: null,
                          inputActiom: TextInputAction.next,
                          isobscured: false,
                          controller: _cardNumberController,
                          iconPressed: null,
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                        child: PaymentInputFields(
                          screenWidth: screenWidth * 0.5,
                          screenHeight: screenHeight,
                          keyboardType: TextInputType.emailAddress,
                          hintText: "Card holder’s name",
                          suffixIcon: null,
                          prefixIcon: null,
                          inputActiom: TextInputAction.next,
                          isobscured: false,
                          controller: _cardHolderNameController,
                          iconPressed: null,
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                        child: PaymentInputFields(
                          screenWidth: screenWidth * 0.5,
                          screenHeight: screenHeight,
                          keyboardType: TextInputType.emailAddress,
                          hintText: "Expiry date",
                          suffixIcon: null,
                          prefixIcon: null,
                          inputActiom: TextInputAction.next,
                          isobscured: false,
                          controller: _expiryDateController,
                          iconPressed: null,
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                        child: PaymentInputFields(
                          screenWidth: screenWidth * 0.5,
                          screenHeight: screenHeight,
                          keyboardType: TextInputType.emailAddress,
                          hintText: "CVC",
                          suffixIcon: null,
                          prefixIcon: null,
                          inputActiom: TextInputAction.next,
                          isobscured: false,
                          controller: _cvcController,
                          iconPressed: null,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.05,
                            vertical: screenHeight * 0.013),
                        child: Row(
                          children: [
                            CustomCheckBox(
                              onChange: (value) {
                                isChecked = value;
                              },
                              isChecked: isChecked,
                              screenWidth: screenWidth,
                            ),
                            Padding(
                              padding:
                                  EdgeInsets.only(left: screenWidth * 0.02),
                              child: Text(
                                'Remember payment information',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  height:
                                      1.25, // Calculated based on line height: 20 / 16
                                  letterSpacing: -0.165,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: screenHeight * 0.06),
                    child: PaymentButton(
                      screenWidth: screenWidth,
                      screenHeight: screenHeight,
                      buttonText: "Next",
                      buttonAction: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => PaymentReviewScreen(
                                  paymentInfo: PersonalPaymentInformations(
                                      cardNumber: _cardNumberController.text,
                                      cardholdersName:
                                          _cardHolderNameController.text,
                                      expirydate: _expiryDateController.text,
                                      cvc: _cvcController.text,
                                      isChappaChecked: isChappaChecked,
                                      isPaymentChecked: isPaymentChecked,
                                      isPaypalChecked: isPaypalChecked),
                                )));
                      },
                    ),
                  ),
                ),
                Padding(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom))
              ],
            ),
          );
        }),
      ),
      resizeToAvoidBottomInset: false,
    );
  }
}

//payment screen ends here

/// PaymentInputFields
///
/// A custom input field widget for entering payment-related information.
///
/// This widget provides a styled input field for users to enter payment-related
/// information, such as card numbers, names, CVV, etc. It supports customization
/// of keyboard type, hint text, icons, and other properties.
///
/// Properties:
/// - `screenWidth`: The screen width used for sizing.
/// - `screenHeight`: The screen height used for sizing.
/// - `keyboardType`: The type of keyboard to be used for input.
/// - `hintText`: The hint text displayed inside the input field.
/// - `suffixIcon`: An icon displayed at the end of the input field.
/// - `prefixIcon`: An icon displayed at the start of the input field.
/// - `inputAction`: The type of action triggered when pressing the keyboard's action key.
/// - `isobscured`: Indicates whether the input should be obscured (e.g., for passwords).
/// - `controller`: A TextEditingController for managing the input's value.
/// - `iconPressed`: A callback function to be executed when the icon is pressed.
///
/// Usage:
/// This widget can be used in various forms where payment-related information needs
/// to be collected from users. It offers customization for different input scenarios.

class PaymentInputFields extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;
  final TextInputType keyboardType;
  final String hintText;
  final IconData? suffixIcon;
  final IconData? prefixIcon;
  final TextInputAction inputActiom;
  final bool isobscured;
  final TextEditingController? controller;
  final VoidCallback? iconPressed;

  const PaymentInputFields(
      {super.key,
      required this.screenWidth,
      required this.screenHeight,
      required this.keyboardType,
      required this.hintText,
      this.suffixIcon,
      this.prefixIcon,
      required this.inputActiom,
      required this.isobscured,
      required this.controller,
      this.iconPressed});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(5),
      borderSide: BorderSide(color: cs.outline),
    );
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
      child: Column(
        children: [
          SizedBox(
            height: 53,
            child: TextFormField(
              controller: controller,
              obscureText: isobscured,
              textInputAction: inputActiom,
              keyboardType: keyboardType,
              style: TextStyle(color: cs.onSurface),
              textAlignVertical: TextAlignVertical.bottom,
              decoration: InputDecoration(
                filled: true,
                fillColor: cs.surface,
                hintText: hintText,
                hintStyle: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  letterSpacing: -0.165,
                  height: 18 / 14, // line-height / font-size
                ),
                suffixIcon: suffixIcon != null
                    ? IconButton(
                        icon: Icon(suffixIcon, color: cs.onSurfaceVariant),
                        onPressed: iconPressed,
                      )
                    : null,
                prefixIcon: prefixIcon != null
                    ? Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.03),
                        child: Icon(prefixIcon, color: cs.onSurfaceVariant),
                      )
                    : null,
                border: border,
                enabledBorder: border,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(color: cs.primary, width: 2),
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 53, // No vertical padding
                  horizontal: prefixIcon == null
                      ? screenWidth * 0.05
                      : screenWidth * 0.07,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// PaymentButton
///
/// A customizable button for payment-related actions.
///
/// This button is designed for triggering payment actions and displays
/// the provided button text.
///
/// Properties:
/// - `buttonText`: The text displayed on the button.
/// - `screenWidth`: The width of the screen, used for responsive design.
/// - `screenHeight`: The height of the screen, used for responsive design.
/// - `buttonAction`: A callback function triggered when the button is pressed.
///
/// Usage:
/// This widget can be used in various payment-related screens to provide a
/// consistent button style for payment actions.

class PaymentButton extends StatelessWidget {
  final String buttonText;
  final double screenWidth;
  final double screenHeight;
  final VoidCallback? buttonAction;
  const PaymentButton(
      {super.key,
      required this.screenWidth,
      required this.screenHeight,
      // ignore: non_constant_identifier_names
      required this.buttonText,
      this.buttonAction});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: buttonAction,
      child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: screenWidth * 0.48, // 23.1% of screen width
            height: screenHeight * 0.063, // 5% of screen height
            decoration: BoxDecoration(
              color: cs.primary,
            ), // Adjust the width as needed
            child: Center(
              child: Text(
                buttonText,
                style: TextStyle(
                  color: cs.onPrimary,
                  fontFamily: "PlusJakartaSans",
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.16,
                ),
              ),
            ),
          )),
    );
  }
}

/// PageTitlesInPayment
///
/// A title Components used in payment-related screens.
///
/// This Components displays the provided title text with specified styling.
///
/// Properties:
/// - `title`: The title text to be displayed.
/// - `screenWidth`: The width of the screen, used for responsive design.
/// - `screenHeight`: The height of the screen, used for responsive design.
///
/// Usage:
/// This widget is often used to display section titles in payment-related screens.

class PageTitlesInPayment extends StatelessWidget {
  final String title;
  final double screenWidth;
  final double screenHeight;

  const PageTitlesInPayment(
      {super.key,
      required this.title,
      required this.screenWidth,
      required this.screenHeight});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
        padding: EdgeInsets.symmetric(
            vertical: screenHeight * 0.02, horizontal: screenWidth * 0.047),
        child: Text(title,
            textAlign: TextAlign.left,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              color: cs.onSurface,
              fontSize: 17,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.17,
              height: 2,
            )));
  }
}

/// PaymentMethodButtons
///
/// A group of buttons for selecting payment methods.
///
/// This widget displays payment method icons or images as buttons and indicates
/// the selected method with styling.
///
/// Properties:
/// - `screenWidth`: The width of the screen, used for responsive design.
/// - `screenHeight`: The height of the screen, used for responsive design.
/// - `isChecked`: Indicates whether the payment method is selected.
/// - `checker`: A callback function triggered when the button is pressed.
/// - `icons`: An optional icon for the payment method.
/// - `pngAssetPath`: An optional PNG image asset path for the payment method.
///
/// Usage:
/// This widget is used to display and select payment methods, such as credit cards,
/// PayPal, or other methods.

class PaymentMethodButtons extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;
  final bool isChecked;
  final VoidCallback checker;
  final IconData? icons;
  final String? pngAssetPath;
  const PaymentMethodButtons(
      {super.key,
      required this.screenWidth,
      required this.screenHeight,
      required this.isChecked,
      required this.checker,
      this.icons,
      this.pngAssetPath});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: checker,
      child: Padding(
        padding: EdgeInsets.symmetric(
            vertical: screenHeight * 0.005, horizontal: screenWidth * 0.047),
        child: Container(
          width: screenWidth * 0.235,
          height: screenHeight * 0.07,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
                color: isChecked ? cs.primary : cs.outline.withValues(alpha: 0.5),
                width: 1),
            color: isChecked
                ? cs.primary
                : (Theme.of(context).brightness == Brightness.light
                    ? cs.surface
                    : cs.surfaceContainerHighest),
            boxShadow: Theme.of(context).brightness == Brightness.light && !isChecked
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: pngAssetPath != null
                ? (pngAssetPath!.toLowerCase().endsWith('.svg')
                    ? SvgPicture.asset(
                        pngAssetPath!,
                        width: screenWidth * 0.09,
                        height: screenWidth * 0.09,
                        colorFilter: ColorFilter.mode(
                          isChecked ? cs.onPrimary : cs.primary,
                          BlendMode.srcIn,
                        ),
                      )
                    : ColorFiltered(
                        colorFilter: isChecked
                            ? ColorFilter.mode(cs.onPrimary, BlendMode.srcIn)
                            : ColorFilter.mode(cs.primary, BlendMode.srcIn),
                        child: Image.asset(
                          pngAssetPath!,
                        ),
                      ))
                : Icon(
                    icons,
                    color: isChecked ? cs.onPrimary : cs.primary,
                  ),
          ),
        ),
      ),
    );
  }
}

/// CustomCheckBox
///
/// A custom checkbox widget that allows users to toggle between checked and unchecked states.
///
/// This widget provides a customizable checkbox that users can interact with to toggle
/// its state. It supports customization of colors, sizes, icons, and more.
///
/// Properties:
/// - `size`: The size of the checkbox.
/// - `iconSize`: The size of the checkbox icon.
/// - `onChange`: A function that will be called when the checkbox state changes.
/// - `backgroundColor`: The background color of the checkbox when checked.
/// - `iconColor`: The color of the checkbox icon when checked.
/// - `borderColor`: The border color of the checkbox when unchecked.
/// - `icon`: The icon to be displayed when the checkbox is checked.
/// - `isChecked`: Indicates whether the checkbox is currently checked.
/// - `screenWidth`: The screen width used for sizing.
///
/// Usage:
/// This widget can be used in various UI scenarios where the user's choice needs
/// to be indicated using a checkbox. The `onChange` function is called whenever
/// the checkbox is toggled.

// ignore: must_be_immutable
class CustomCheckBox extends StatefulWidget {
  double? size;
  double? iconSize;
  Function onChange;
  Color? backgroundColor;
  Color? iconColor;
  Color? borderColor;
  IconData? icon;
  bool isChecked;
  double screenWidth;

  CustomCheckBox({
    super.key,
    this.size,
    this.iconSize,
    required this.onChange,
    this.backgroundColor,
    this.iconColor,
    this.icon,
    this.borderColor,
    required this.isChecked,
    required this.screenWidth,
  });

  @override
  State<CustomCheckBox> createState() => _CustomCheckBoxState();
}

class _CustomCheckBoxState extends State<CustomCheckBox> {
  @override
  void initState() {
    super.initState();
    widget.isChecked = widget.isChecked;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          widget.isChecked = !widget.isChecked;
          widget.onChange(widget.isChecked);
        });
      },
      child: AnimatedContainer(
          height: widget.screenWidth * 0.04,
          width: widget.screenWidth * 0.04,
          duration: const Duration(milliseconds: 500),
          curve: Curves.fastLinearToSlowEaseIn,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2.0),
              color: widget.isChecked
                  ? widget.backgroundColor ??
                      const Color.fromRGBO(110, 182, 255, 1)
                  : Colors.transparent,
              border: Border.all(
                  color: widget.isChecked
                      ? const Color.fromRGBO(110, 182, 255, 1)
                      : widget.borderColor ??
                          const Color.fromARGB(255, 78, 77, 77))),
          child: widget.isChecked
              ? Icon(
                  widget.icon ?? Icons.check,
                  color: widget.iconColor ?? Colors.white,
                  size: widget.iconSize ?? 10,
                )
              : null),
    );
  }
}

/// PersonalPaymentInformations
///
/// A class that holds payment-related information for the user.
///
/// This class encapsulates the payment information provided by the user during
/// the subscription process. It includes card details, payment method choices,
/// and associated properties.
///
/// Properties:
/// - `cardNumber`: The card number entered by the user.
/// - `cardholdersName`: The name of the cardholder.
/// - `expirydate`: The expiration date of the card.
/// - `cvc`: The card's security code (CVC).
/// - `isPaypalChecked`: Indicates whether PayPal payment method is selected.
/// - `isChappaChecked`: Indicates whether Chappa payment method is selected.
/// - `isPaymentChecked`: Indicates whether a general payment method is selected.
///
/// Usage:
/// This class is used to create an instance that holds the user's payment
/// information. It is typically passed between screens during the subscription
/// process and used to display and verify the user's payment choices.

class PersonalPaymentInformations {
  final String cardNumber;
  String cardholdersName;
  String expirydate;
  String cvc;
  bool isPaypalChecked;
  bool isChappaChecked;
  bool isPaymentChecked;

  PersonalPaymentInformations(
      {required this.cardNumber,
      required this.cardholdersName,
      required this.expirydate,
      required this.cvc,
      required this.isChappaChecked,
      required this.isPaymentChecked,
      required this.isPaypalChecked});
}
