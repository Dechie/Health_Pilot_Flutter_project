import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:healthpilot/features/home/home_page_screen.dart';
import 'package:healthpilot/features/onboarding/terms_dialogBox.dart';
import 'package:healthpilot/features/get_started/get_started_screen.dart';

import 'package:healthpilot/features/forgot_password/forgot_password_flow.dart';

class SignupAndLoginScreen extends StatefulWidget {
  static const routeName = '/SignupandLogin';
  const SignupAndLoginScreen({super.key});

  @override
  State<SignupAndLoginScreen> createState() => _SignupAndLoginScreenState();
}

class _SignupAndLoginScreenState extends State<SignupAndLoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool? _isChecked = false;
  bool _isLogin = false;
  bool _isObscured = true;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void initState() {
    _isObscured = true;
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //Signup and login sceen starts here

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          final size = constraints.biggest;
          final screenWidth = size.width;
          final screenHeight = size.height;
          return SingleChildScrollView(
            reverse: true,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          top: screenHeight * 0.05, left: screenWidth * 0.14),
                      child: Image.asset(
                        'assets/images/image_4.png',
                        width: screenWidth * 0.6,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: screenHeight * 0.013, left: screenWidth * 0.025),
                      child: SvgPicture.asset('assets/images/Vector.svg'),
                    ),
                  ],
                ),
                SizedBox(
                  height: screenHeight * 0.03,
                ),
                PageTitles(
                  title: _isLogin
                      ? "Glad to have you back"
                      : "Let’s get you all checked up",
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                  letterHeight: 2,
                ),
                AccountMessageText(
                  text: _isLogin
                      ? "We’ve missed you, login to continue tracking your health"
                      : "By creating an account, unlock complete features and access Personal data",
                  screenHeight: screenHeight,
                  screenWidth: screenWidth,
                  color: const Color.fromRGBO(42, 42, 42, 0.5),
                  letterHeight: 1.3,
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.1,
                      vertical: screenHeight * 0.02),
                ),
                SizedBox(
                  height: screenHeight * 0.055,
                ),
                Form(
                  // You can provide a GlobalKey<FormState> to handle form validation and submission
                  key: _formKey,
                  child: Column(
                    children: [
                      InputFields(
                        screenWidth: screenWidth,
                        screenHeight: screenHeight,
                        keyboardType: TextInputType.emailAddress,
                        hintText: "Email",
                        suffixIcon: null,
                        prefixIcon: Icons.email_outlined,
                        inputActiom: TextInputAction.next,
                        isobscured: !_isObscured,
                        controller: emailController,
                        iconPressed: null,
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      InputFields(
                        screenWidth: screenWidth,
                        screenHeight: screenHeight,
                        keyboardType: TextInputType.visiblePassword,
                        hintText: "Password",
                        suffixIcon: _isObscured
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        iconPressed: () => setState(() {
                          _isObscured = !_isObscured;
                        }),
                        prefixIcon: Icons.key,
                        inputActiom: TextInputAction.next,
                        isobscured: _isObscured,
                        controller: passwordController,
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      if (!_isLogin)
                        InputFields(
                          screenWidth: screenWidth,
                          screenHeight: screenHeight,
                          keyboardType: TextInputType.visiblePassword,
                          hintText: "Confirm Password",
                          suffixIcon: _isObscured
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          prefixIcon: Icons.key,
                          inputActiom: TextInputAction.done,
                          isobscured: _isObscured,
                          controller: confirmPasswordController,
                          iconPressed: () => setState(() {
                            _isObscured = !_isObscured;
                          }),
                        ),
                      SizedBox(height: screenHeight * 0.03),
                      _isLogin
                          ? BottomActionTexts(
                              normalTexts: "Forgot your password? ",
                              commandTexts: "Reset now",
                              login: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => const ForgotPasswordScreen(),
                                ));
                              },
                              fontSize: 17,
                            )
                          : Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.107),
                              child: Row(
                                children: [
                                  CustomCheckBox(
                                    onChange: (value) {
                                      _isChecked = value;
                                    },
                                    isChecked: _isChecked!,
                                    screenWidth: screenWidth,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: screenWidth * 0.01),
                                    child: const TermsPolicyText(),
                                  ),
                                ],
                              ),
                            ),
                      SizedBox(
                        height: screenHeight * 0.03,
                      ),
                      Button(
                        fontsize: 18,
                        textColor: Colors.white,
                        screenWidth: screenWidth,
                        screenHeight: screenHeight,
                        buttonText: _isLogin ? "Login" : "Sign Up",
                        buttonAction: _isLogin
                            ? () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const GetStartedScreen(),
                                  ),
                                );
                              }
                            : () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      const ConfirmEmailScreen(),
                                ));
                              },
                        buttoncolor: const Color.fromRGBO(110, 182, 255, 1),
                      ),
                      SizedBox(
                        height: screenHeight * 0.03,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.09),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DividerLine(screenWidth: screenWidth),
                        SizedBox(
                          width: screenWidth * 0.01,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.01),
                          child: const Text(
                            "Or",
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              color: Color.fromRGBO(42, 42, 42, 0.5),
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              letterSpacing: -0.17,
                              height: 1.3,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: screenWidth * 0.01,
                        ),
                        DividerLine(screenWidth: screenWidth),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.025,
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: screenWidth * 0.004),
                  child: IconContainor(
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.025,
                ),
                _isLogin
                    ? BottomActionTexts(
                        normalTexts: "Don't have an account? ",
                        commandTexts: "Sign up",
                        login: () => setState(() {
                          _isLogin = !_isLogin;
                        }),
                        fontSize: 15,
                      )
                    : BottomActionTexts(
                        normalTexts: "Already have an account? ",
                        commandTexts: "Login",
                        login: () => setState(() {
                          _isLogin = !_isLogin;
                        }),
                        fontSize: 15,
                      ),
                SizedBox(
                  height: screenHeight * 0.012,
                ),
                BottomActionTexts(
                  normalTexts: "Wanna give it a try? ",
                  commandTexts: "Skip",
                  login: () {
                    Navigator.of(context, rootNavigator: true).pushReplacement(
                      MaterialPageRoute<void>(
                        builder: (context) =>
                            const HomePageScreen(isHelpPressed: false),
                      ),
                    );
                  },
                  fontSize: 15,
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

// sign up and log in screen ends here

/* Confirm email page starts here*/

class ConfirmEmailScreen extends StatelessWidget {
  static const routeName = "Confirmemailscreen";
  const ConfirmEmailScreen({
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
                SvgPicture.asset('assets/images/confirmemail.svg'),
                const Text(
                  'Check your email',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    height: 1.25, // Equivalent to line height of 25px
                    letterSpacing:
                        -0.165, // You might need to adjust this value
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.15,
                      vertical: screenHeight * 0.02),
                  child: const Text(
                    'Please confirm your email to finish setting up your account. ',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      height: 1.25, // Equivalent to line height of 20px
                      letterSpacing: -0.165,
                      color: Color.fromRGBO(
                          42, 42, 42, 0.5), // Set your desired text color
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.1),
                  child: Column(
                    children: [
                      const Text(
                        'Didn’t receive an email?',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          height: 1.25,
                          letterSpacing: -0.165,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: screenHeight * 0.03),
                        child: Button(
                          fontsize: 18,
                          textColor: Colors.white,
                          screenWidth: screenWidth,
                          screenHeight: screenHeight,
                          buttonText: "Return to login",
                          buttonAction: () {
                            Navigator.of(context).pop();
                          },
                          buttoncolor: const Color.fromRGBO(110, 182, 255, 1),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      )),
      resizeToAvoidBottomInset: false,
    );
  }
}

/*confirm email screen ends here;*/

// Multiple widgets uses in signin/uppscreen and confirm email screen starts here

class PageTitles extends StatelessWidget {
  final String title;
  final double screenWidth;
  final double screenHeight;
  final EdgeInsetsGeometry padding;
  final double letterHeight;

  const PageTitles(
      {super.key,
      required this.title,
      required this.screenWidth,
      required this.screenHeight,
      required this.padding,
      required this.letterHeight});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: padding,
        child: Text(title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              color: const Color.fromRGBO(42, 42, 42, 1),
              fontSize: 22,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.17,
              height: letterHeight,
            )));
  }
}

class AccountMessageText extends StatelessWidget {
  final String text;
  final double screenWidth;
  final double screenHeight;
  final EdgeInsetsGeometry padding;
  final double letterHeight;
  final Color color;

  const AccountMessageText(
      {super.key,
      required this.text,
      required this.screenWidth,
      required this.screenHeight,
      required this.padding,
      required this.letterHeight,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            color: color,
            fontSize: 16.5,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.17,
            height: letterHeight,
          )),
    );
  }
}

class InputFields extends StatelessWidget {
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

  const InputFields(
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
              textAlignVertical: TextAlignVertical.bottom,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(
                  color: Color.fromRGBO(42, 42, 42, 0.5),

                  fontFamily: 'PlusJakartaSans',
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  letterSpacing: -0.165,
                  height: 18 / 14, // line-height / font-size
                ),
                suffixIcon: IconButton(
                  icon: Icon(suffixIcon),
                  onPressed: iconPressed,
                ),
                prefixIcon: prefixIcon != null
                    ? Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.03),
                        child: Icon(prefixIcon),
                      )
                    : null,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: const BorderSide()),
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

class TermsPolicyText extends StatelessWidget {
  const TermsPolicyText({super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
          text: "I have read and agree to the",
          style: const TextStyle(
            color: Color.fromRGBO(42, 42, 42, 0.5),
            fontFamily: 'PlusJakartasSans',
            fontSize: 11,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.165,
            height: 15 / 12,
          ),
          children: [
            TextSpan(
                text: ' terms ',
                style: const TextStyle(
                  color: Color.fromRGBO(110, 182, 255, 1),
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.165,
                  height: 15 / 12,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return Policy(
                            mdFile: 'termsAndConditions.md',
                            radius: 8,
                          );
                        });
                  }),
            const TextSpan(
                text: ' and ',
                style: TextStyle(
                  color: Color.fromRGBO(42, 42, 42, 0.5),
                  fontFamily: 'PlusJakartasSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.165,
                  height: 15 / 12,
                )),
            TextSpan(
                text: ' conditions .',
                style: const TextStyle(
                  color: Color.fromRGBO(110, 182, 255, 1),
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.165,
                  height: 15 / 12,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return Policy(
                            mdFile: 'termsAndConditions.md',
                            radius: 8,
                          );
                        });
                  })
          ]),
    );
  }
}

class Button extends StatelessWidget {
  final String buttonText;
  final double screenWidth;
  final double screenHeight;
  final VoidCallback? buttonAction;
  final Color buttoncolor;
  final Color textColor;
  final double fontsize;
  const Button(
      {Key? key,
      required this.screenWidth,
      required this.screenHeight,
      // ignore: non_constant_identifier_names
      required this.buttonText,
      this.buttonAction,
      required this.buttoncolor,
      required this.textColor,
      required this.fontsize})
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
            decoration: BoxDecoration(
              color: buttoncolor,
            ), // Adjust the width as needed
            child: Center(
              child: Text(
                buttonText,
                style: TextStyle(
                  color: textColor,
                  fontFamily: "PlusJakartaSans",
                  fontSize: fontsize,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.16,
                ),
              ),
            ),
          )),
    );
  }
}

class DividerLine extends StatelessWidget {
  final double screenWidth;

  const DividerLine({super.key, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: screenWidth * 0.33,
        child: const Divider(
          thickness: 1,
          color: Colors.grey,
        ));
  }
}

class IconContainor extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;
  const IconContainor(
      {super.key, required this.screenWidth, required this.screenHeight});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: screenWidth * 0.1,
      height: screenHeight * 0.05,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color.fromRGBO(221, 218, 218, 1))),
      child: Image.asset(
          'assets/Icons/google.png'), //D:\Coding\healthApp\Flutter_project\healthpilot\assets\Icons\Google1.png
    );
  }
}

class BottomActionTexts extends StatelessWidget {
  final double fontSize;
  final String normalTexts;
  final String commandTexts;
  final VoidCallback? login;
  const BottomActionTexts(
      {super.key,
      required this.normalTexts,
      required this.commandTexts,
      required this.login,
      required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
          text: normalTexts,
          style: TextStyle(
            color: const Color.fromRGBO(42, 42, 42, 1),
            fontFamily: 'PlusJakartasSans',
            fontSize: fontSize,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.165,
            height: 15 / 12,
          ),
          children: [
            TextSpan(
              text: commandTexts,
              style: TextStyle(
                color: const Color.fromRGBO(110, 182, 255, 1),
                fontFamily: 'PlusJakartaSans',
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.165,
                height: 15 / 12,
              ),
              recognizer: TapGestureRecognizer()..onTap = login,
            ),
          ]),
    );
  }
}

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
    Key? key,
    this.size,
    this.iconSize,
    required this.onChange,
    this.backgroundColor,
    this.iconColor,
    this.icon,
    this.borderColor,
    required this.isChecked,
    required this.screenWidth,
  }) : super(key: key);

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
