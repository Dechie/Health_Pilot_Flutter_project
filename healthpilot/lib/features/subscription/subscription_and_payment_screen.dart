/// SubscriptionAndPaymentScreen
///
/// A screen that presents subscription and payment options to the user.
///
/// This screen allows the user to choose a premium subscription plan to
/// unlock additional features of the application. It provides information
/// about the benefits of the premium plan, along with visual representations
/// of both premium and free features.
///
/// Features:
/// - Title: Displays a title introducing the benefits of the premium plan.
/// - Account Message: Displays a message encouraging the user to subscribe
///   for accessing more features.
/// - Premium Feature Container: A container showcasing the premium features
///   available with the subscription.
/// - Free Feature Container: A container displaying the features available
///   for free.
/// - Next Button: A button that allows the user to proceed to the next screen,
///   likely for completing their subscription or registration.
///
/// Usage:
/// The screen can be accessed from various parts of the application's navigation
/// flow, such as from an onboarding process or user account settings.

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:healthpilot/features/profile/personal_information_screen.dart';

import 'package:healthpilot/features/onboarding/signup_and_login_screen.dart';
import 'package:healthpilot/features/profile/personal_doctor_personal_information.dart'
    as doctor;

class SubscriptionAndPaymentScreen extends StatelessWidget {
  const SubscriptionAndPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: LayoutBuilder(
        builder: ((context, constraints) {
          final size = constraints.biggest;
          final screenWidth = size.width;
          final screenHeight = size.height;
          return SingleChildScrollView(
            child: Column(
              children: [
                PageTitles(
                  title: "Unleash the full potential of HealthPilot",
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                  padding: EdgeInsets.only(
                    top: screenHeight * 0.05,
                    left: screenWidth * 0.04,
                  ),
                  letterHeight: 1.5,
                ),
                AccountMessageText(
                  text:
                      "Get access to more features by subscribing to our premium plan.",
                  screenHeight: screenHeight,
                  screenWidth: screenWidth,
                  color: const Color.fromRGBO(42, 42, 42, 1),
                  letterHeight: 1.3,
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05,
                      vertical: screenHeight * 0.02),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                  child: PremiumFeatureContainer(
                    screenHeight: screenHeight,
                    screenWidth: screenWidth,
                    color: const Color.fromRGBO(110, 182, 255, 1),
                  ),
                ),
                FreeFeatureContainer(
                    screenHeight: screenHeight, screenWidth: screenWidth),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.03),
                  child: Button(
                      screenWidth: screenWidth * 1.3,
                      screenHeight: screenHeight * 1.1,
                      buttonText: "Next",
                      buttoncolor: const Color.fromRGBO(110, 182, 255, 1),
                      textColor: Colors.white,
                      fontsize: 18),
                )
              ],
            ),
          );
        }),
      )),
    );
  }
}

/// PremiumFeatureContainer
///
/// A visually appealing container showcasing premium features and subscription details.
///
/// This container presents premium features of the application's subscription plan.
/// It displays a title, a list of featured items, and a subscription button.
///
/// Properties:
/// - `color`: The background color of the container.
/// - `screenHeight`: The height of the screen, used for responsive design.
/// - `screenWidth`: The width of the screen, used for responsive design.
///
/// Usage:
/// This widget can be used within various parts of the application, such as the
/// `SubscriptionAndPaymentScreen`, to visually highlight the features of the premium plan.

class PremiumFeatureContainer extends StatelessWidget {
  final Color color;
  final double screenHeight;
  final double screenWidth;

  const PremiumFeatureContainer(
      {super.key,
      required this.color,
      required this.screenHeight,
      required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: screenHeight * 0.27,
          width: screenWidth * 0.85,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(10)),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.027,
                ),
                child: const Text(
                  "Premium Version",
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    color: Colors.white,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    height: 1.25, // line height of 20px with 16px font size
                    letterSpacing: -0.165,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              FeaturesText(
                  screenHeight: screenHeight,
                  screenWidth: screenWidth,
                  icons: Icons.star,
                  text: "Personalized treatment & recommendation ",
                  textColor: Colors.white),
              FeaturesText(
                  screenHeight: screenHeight,
                  screenWidth: screenWidth,
                  icons: Icons.star,
                  text: "Fitness trackers Integration ",
                  textColor: Colors.white),
              FeaturesText(
                  screenHeight: screenHeight,
                  screenWidth: screenWidth,
                  icons: Icons.star,
                  text: "Health coaching ",
                  textColor: Colors.white),
              Padding(
                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                child: Button(
                  screenWidth: screenWidth * 0.87,
                  screenHeight: screenHeight * 0.8,
                  buttonText: "25.99\$/month",
                  buttoncolor: Colors.yellow,
                  textColor: Colors.black,
                  fontsize: 12,
                  buttonAction: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: ((context) => const PaymentMethodScreen())));
                  },
                ),
              )
            ],
          ),
        ),
        Positioned(
          top: 0,
          child: DiagonalContainer(
            color: Colors.yellow,
            screenHeight: screenHeight,
            screenWidth: screenWidth,
          ),
        ),
      ],
    );
  }
}

class FreeFeatureContainer extends StatelessWidget {
  final double screenHeight;
  final double screenWidth;
  const FreeFeatureContainer(
      {super.key, required this.screenHeight, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.007),
      child: SizedBox(
        height: screenHeight * 0.3,
        width: screenWidth * 0.85,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: screenHeight * 0.023,
              ),
              child: const Text(
                "Free Version",
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  color: Colors.black,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                  height: 1.25, // line height of 20px with 16px font size
                  letterSpacing: -0.165,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            FeaturesText(
                screenHeight: screenHeight,
                screenWidth: screenWidth,
                icons: Icons.star_border,
                text: "Access to chatbot",
                textColor: Colors.black),
            FeaturesText(
                screenHeight: screenHeight,
                screenWidth: screenWidth,
                icons: Icons.star_border,
                text: "Track Health and activity",
                textColor: Colors.black),
            FeaturesText(
                screenHeight: screenHeight,
                screenWidth: screenWidth,
                icons: Icons.star_border,
                text: "Symptom Tracker",
                textColor: Colors.black),
            FeaturesText(
                screenHeight: screenHeight,
                screenWidth: screenWidth,
                icons: Icons.star_border,
                text: "Personalized recommendation",
                textColor: Colors.black),
            Padding(
              padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
              child: Button(
                screenWidth: screenWidth * 0.87,
                screenHeight: screenHeight * 0.8,
                buttonText: "Free",
                buttoncolor: const Color.fromRGBO(110, 182, 255, 1),
                textColor: Colors.white,
                fontsize: 12,
              ),
            )
          ],
        ),
      ),
    );
  }
}

/// FreeFeatureContainer
///
/// A container displaying features available in the free version of the application.
///
/// This container presents the features available in the free version of the
/// application. It displays a title, a list of featured items, and a "Free" button.
///
/// Properties:
/// - `screenHeight`: The height of the screen, used for responsive design.
/// - `screenWidth`: The width of the screen, used for responsive design.
///
/// Usage:
/// This widget can be used within the `SubscriptionAndPaymentScreen` or other
/// relevant screens to highlight the features of the free version.

class FeaturesText extends StatelessWidget {
  final double screenHeight;
  final String text;
  final Color textColor;
  final double screenWidth;
  final IconData icons;
  const FeaturesText(
      {super.key,
      required this.screenHeight,
      required this.screenWidth,
      required this.icons,
      required this.text,
      required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: screenHeight * 0.004, horizontal: screenWidth * 0.05),
      child: Row(
        children: [
          Icon(
            icons,
            color: Colors.yellow,
            size: 18,
          ),
          Padding(
            padding: EdgeInsets.only(left: screenWidth * 0.03),
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                color: textColor,
                fontSize: 12.0,
                fontWeight: FontWeight.w500,
                height: 1.25, // line height of 20px with 16px font size
                letterSpacing: -0.165,
              ),
            ),
          )
        ],
      ),
    );
  }
}

/// DiagonalContainer
///
/// A container with a diagonal design element used for highlighting or decoration.
///
/// This container adds a diagonal design element to the layout, often used for
/// highlighting or adding visual interest to a section of the screen.
///
/// Properties:
/// - `color`: The background color of the diagonal container.
/// - `screenWidth`: The width of the screen, used for responsive design.
/// - `screenHeight`: The height of the screen, used for responsive design.
///
/// Usage:
/// This widget is often used in conjunction with other containers or UI elements
/// to provide a visual separation or emphasis on specific content.

class DiagonalContainer extends StatelessWidget {
  final Color color;
  final double screenWidth;
  final double screenHeight;
  const DiagonalContainer({
    super.key,
    required this.color,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.53, vertical: screenHeight * 0.02),
      child: Transform.rotate(
        angle: 30 * (3.14159265358979323846 / 180),
        child: Container(
          width: screenWidth * 0.4,
          height: screenHeight * 0.027,
          decoration: BoxDecoration(
            color: color,
          ),
          child: const Center(
            child: Text(
              "Recommended",
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                height:
                    10 / 8, // Line height calculation: line height / font size
                letterSpacing: -0.16500000655651093,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// PaymentReviewScreen
///
/// A screen for reviewing payment information and confirming payment details.
///
/// This screen displays a summary of payment details for confirmation before
/// proceeding with the payment process.
///
/// Properties:
/// - `paymentInfo`: An object containing the payment information to be reviewed.
///
/// Usage:
/// The screen is typically shown after the user submits their payment information
/// and serves as a final review step before proceeding with payment.

// ignore: must_be_immutable
class PaymentReviewScreen extends StatelessWidget {
  PaymentReviewScreen({super.key, required this.paymentInfo});

  bool isChecked = false;
  bool isPaypalChecked = false;
  bool isChappaChecked = false;
  bool isPaymentChecked = false;

  final PersonalPaymentInformations paymentInfo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        "Confirm Email",
                        style: TextStyle(
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.w700,
                          fontFamily: "PlusJakartaSans",
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: screenHeight * 0.04,
                        left: screenWidth * 0.32,
                      ),
                      child: SizedBox(
                        width: screenWidth * 0.04,
                        height: screenWidth * 0.04,
                        child: SvgPicture.asset(
                          'assets/images/Vector.svg',
                          fit: BoxFit.cover,
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
                      isChecked: paymentInfo.isPaymentChecked,
                      icons: Icons.payment_outlined,
                      pngAssetPath: null,
                      checker: null,
                    ),
                    PaymentMethodButtons(
                      screenWidth: screenWidth,
                      screenHeight: screenHeight,
                      isChecked: paymentInfo.isPaypalChecked,
                      icons: Icons.paypal_outlined,
                      pngAssetPath: null,
                      checker: null,
                    ),
                    PaymentMethodButtons(
                      screenWidth: screenWidth,
                      screenHeight: screenHeight,
                      isChecked: paymentInfo.isChappaChecked,
                      icons: null,
                      pngAssetPath: "assets/Icons/chapa.png",
                      checker: null,
                    )
                  ],
                ),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PaymentInformations(
                          screenHeight: screenHeight,
                          screenWidth: screenWidth,
                          title: "CardNumber:",
                        ),
                        PaymentInformations(
                          screenHeight: screenHeight,
                          screenWidth: screenWidth,
                          title: "Card holder's name:",
                        ),
                        PaymentInformations(
                          screenHeight: screenHeight,
                          screenWidth: screenWidth,
                          title: "Expiry date:",
                        ),
                        PaymentInformations(
                          screenHeight: screenHeight,
                          screenWidth: screenWidth,
                          title: "CVC:",
                        ),
                        PaymentInformations(
                          screenHeight: screenHeight,
                          screenWidth: screenWidth,
                          title: "Subtotal:",
                        ),
                        PaymentInformations(
                          screenHeight: screenHeight,
                          screenWidth: screenWidth,
                          title: "TAX:",
                        ),
                        PaymentInformations(
                          screenHeight: screenHeight,
                          screenWidth: screenWidth,
                          title: "Total",
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: screenWidth * 0.12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          PersonalpayInfo(
                            personalPaymentInfo: paymentInfo.cardNumber,
                            screenHeight: screenHeight,
                            screenWidth: screenWidth,
                          ),
                          PersonalpayInfo(
                            personalPaymentInfo: paymentInfo.cardholdersName,
                            screenHeight: screenHeight,
                            screenWidth: screenWidth,
                          ),
                          PersonalpayInfo(
                            personalPaymentInfo: paymentInfo.expirydate,
                            screenHeight: screenHeight,
                            screenWidth: screenWidth,
                          ),
                          PersonalpayInfo(
                            personalPaymentInfo: paymentInfo.cvc,
                            screenHeight: screenHeight,
                            screenWidth: screenWidth,
                          ),
                          PersonalpayInfo(
                            personalPaymentInfo: "24.42\$",
                            screenHeight: screenHeight,
                            screenWidth: screenWidth,
                          ),
                          PersonalpayInfo(
                            personalPaymentInfo: "1.57\$",
                            screenHeight: screenHeight,
                            screenWidth: screenWidth,
                          ),
                          PersonalpayInfo(
                            personalPaymentInfo: "25.99\$",
                            screenHeight: screenHeight,
                            screenWidth: screenWidth,
                          )
                        ],
                      ),
                    )
                  ],
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
                            builder: (context) =>
                                const SubscriptionFinishScreen()));
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
      {Key? key,
      required this.screenWidth,
      required this.screenHeight,
      // ignore: non_constant_identifier_names
      required this.buttonText,
      this.buttonAction})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: buttonAction,
      child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: screenWidth * 0.48, // 23.1% of screen width
            height: screenHeight * 0.063, // 5% of screen height
            decoration: const BoxDecoration(
              color: Color.fromRGBO(110, 182, 255, 1),
            ), // Adjust the width as needed
            child: Center(
              child: Text(
                buttonText,
                style: const TextStyle(
                  color: Colors.white,
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
    return Padding(
        padding: EdgeInsets.symmetric(
            vertical: screenHeight * 0.02, horizontal: screenWidth * 0.047),
        child: Text(title,
            textAlign: TextAlign.left,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              color: Color.fromRGBO(42, 42, 42, 1),
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
  final VoidCallback? checker;
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
                color: isChecked
                    ? const Color.fromRGBO(110, 182, 255, 1)
                    : const Color.fromRGBO(42, 42, 42, 0.25),
                width: 1),
            color: isChecked
                ? const Color.fromRGBO(110, 182, 255, 1)
                : Colors.white,
            boxShadow: const [
              BoxShadow(
                color: Colors.white,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Center(
            child: pngAssetPath != null
                ? ColorFiltered(
                    colorFilter: isChecked
                        ? const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          )
                        : const ColorFilter.mode(
                            Color.fromRGBO(110, 182, 255, 1),
                            BlendMode.srcIn,
                          ),
                    child: Image.asset(
                      pngAssetPath!,
                      // fit: BoxFit.cover,
                    ), // Replace with your image asset
                  )
                : Icon(
                    icons,
                    color: isChecked
                        ? Colors.white
                        : const Color.fromRGBO(110, 182, 255, 1),
                  ),
          ),
        ),
      ),
    );
  }
}

/// PaymentInformations
///
/// A Components for displaying payment information titles.
///
/// This Components displays the provided payment information title with specified styling.
///
/// Properties:
/// - `screenHeight`: The height of the screen, used for responsive design.
/// - `screenWidth`: The width of the screen, used for responsive design.
/// - `title`: The title of the payment information to be displayed.
///
/// Usage:
/// This widget is used to display labels for payment information fields.

class PaymentInformations extends StatelessWidget {
  final double screenHeight;
  final double screenWidth;
  final String title;

  const PaymentInformations({
    super.key,
    required this.screenHeight,
    required this.screenWidth,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: screenHeight * 0.03, horizontal: screenWidth * 0.047),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              color: Color.fromRGBO(42, 42, 42, 0.5),
              fontSize: 14,
              fontWeight: FontWeight.w300,
              height: 1.22,
              letterSpacing: -0.165,
            ),
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }
}

/// PersonalpayInfo
///
/// A Components for displaying personalized payment information.
///
/// This Components displays the provided payment information with specified styling.
///
/// Properties:
/// - `screenWidth`: The width of the screen, used for responsive design.
/// - `screenHeight`: The height of the screen, used for responsive design.
/// - `personalPaymentInfo`: The personalized payment information to be displayed.
///
/// Usage:
/// This widget is used to display various personalized payment information details.

class PersonalpayInfo extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;
  final String personalPaymentInfo;
  const PersonalpayInfo(
      {super.key,
      required this.personalPaymentInfo,
      required this.screenWidth,
      required this.screenHeight});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: screenHeight * 0.03,
      ),
      child: Text(
        personalPaymentInfo,
        style: const TextStyle(
          fontFamily: 'PlusJakartaSans',
          color: Color.fromRGBO(42, 42, 42, 1),
          fontSize: 14,
          fontWeight: FontWeight.w300,
          height: 1.22,
          letterSpacing: -0.165,
        ),
      ),
    );
  }
}

/// SubscriptionFinishScreen
///
/// A screen displayed after successful subscription completion.
///
/// This screen is shown to the user after they have successfully signed up
/// for a premium plan. It includes a success message, an image, and a "Finish" button.
///
/// Properties:
/// - `routeName`: The route name used for navigation. (Static property)
///
/// Usage:
/// This screen is typically navigated to after the user completes the subscription
/// process. It provides a confirmation message and allows users to finish the process.

class SubscriptionFinishScreen extends StatelessWidget {
  static const routeName = "/ForgotPasswordEmailCheck";
  const SubscriptionFinishScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(child: LayoutBuilder(
          // ignore: non_constant_identifier_names
          builder: (context, Constraints) {
            final size = Constraints.biggest;
            final screenWidth = size.width;
            final screenHeight = size.height;
            return SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: screenHeight * 0.05),
                    child: SvgPicture.asset('assets/images/credit.svg'),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: screenHeight * 0.03),
                    child: const Text(
                      'Purchase Successful',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                        letterSpacing: -0.165,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.16,
                        vertical: screenHeight * 0.015),
                    child: const Text(
                      'You have successfully signed up for a premium plan. We\'ve sent you an email verifying receipt.',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        height: 1.25, // Equivalent to line height of 20px
                        letterSpacing: -0.165,
                        color: Color.fromRGBO(
                            42, 42, 42, 1), // Set your desired text color
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: screenHeight * 0.1),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.03),
                          child: Button(
                            fontsize: 18,
                            textColor: Colors.white,
                            screenWidth: screenWidth,
                            screenHeight: screenHeight,
                            buttonText: "Finish",
                            buttonAction: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      const doctor.PersonalInformation()));
                            },
                            buttoncolor: const Color.fromRGBO(110, 182, 255, 1),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        )),
        resizeToAvoidBottomInset: false);
  }
}
