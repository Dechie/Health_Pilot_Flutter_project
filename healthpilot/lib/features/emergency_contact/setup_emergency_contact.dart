import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:healthpilot/features/profile/personal_info_contact_models.dart';
import 'package:intl_mobile_field/intl_mobile_field.dart';
import 'package:intl_mobile_field/mobile_number.dart';

/// Add or edit one emergency contact. Pops [EmergencyContactEntry] on successful save.
class SetupEmergencyContact extends StatefulWidget {
  const SetupEmergencyContact({super.key, this.initial});

  final EmergencyContactEntry? initial;

  @override
  State<SetupEmergencyContact> createState() => _SetupEmergencyContactState();
}

class _SetupEmergencyContactState extends State<SetupEmergencyContact> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _relationship = TextEditingController();
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    _phoneController = TextEditingController(text: i?.phoneComplete ?? '');
    if (i != null) {
      _firstName.text = i.firstName;
      _lastName.text = i.lastName;
      _email.text = i.email;
      _relationship.text = i.relationship ?? '';
    }
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _relationship.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final rawPhone = _phoneController.text.replaceAll(RegExp(r'\s+'), '');
    final MobileNumber phone;
    try {
      phone = MobileNumber.fromCompleteNumber(completeNumber: rawPhone);
    } on Exception {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid phone number')),
      );
      return;
    }
    final phoneErr = validateMobileNumber(phone);
    if (phoneErr != null) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(phoneErr)),
      );
      return;
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Save emergency contact?',
          style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 16),
        ),
        content: const Text(
          'This contact will appear in your personal information list.',
          style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) {
      return;
    }

    final rel = _relationship.text.trim();
    final entry = EmergencyContactEntry(
      id: widget.initial?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      firstName: _firstName.text.trim(),
      lastName: _lastName.text.trim(),
      email: _email.text.trim(),
      phoneComplete: phone.completeNumber,
      relationship: rel.isEmpty ? null : rel,
    );
    Navigator.of(context).pop(entry);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final initial = widget.initial;

    return Scaffold(
      appBar: PreferredSize(
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
                      borderRadius: BorderRadius.circular(size.width * 0.05),
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back),
                      color: const Color.fromRGBO(110, 182, 255, 1),
                      iconSize: size.width * 0.055,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(size.width * 0.05, 0, 0, 0),
                    child: SizedBox(
                      width: size.width * 0.6,
                      child: Text(
                        initial == null
                            ? 'Setup Emergency Contact'
                            : 'Edit Emergency Contact',
                        style: TextStyle(
                          fontSize: size.width * 0.05,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'PlusJakartaSans',
                        ),
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
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.08,
            vertical: size.width * 0.08,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _labeledField(
                  label: 'First Name',
                  child: TextFormField(
                    controller: _firstName,
                    decoration: _inputDecoration(size),
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    validator: (v) => validateRequiredName(v, 'First name'),
                  ),
                ),
                SizedBox(height: size.height * 0.03),
                _labeledField(
                  label: 'Last Name',
                  child: TextFormField(
                    controller: _lastName,
                    decoration: _inputDecoration(size),
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    validator: (v) => validateRequiredName(v, 'Last name'),
                  ),
                ),
                SizedBox(height: size.height * 0.03),
                _labeledField(
                  label: 'Relationship (optional)',
                  child: TextFormField(
                    controller: _relationship,
                    decoration: _inputDecoration(size).copyWith(
                      hintText: 'e.g. Spouse, Parent, Friend',
                    ),
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                  ),
                ),
                SizedBox(height: size.height * 0.03),
                _labeledField(
                  label: 'Email',
                  child: TextFormField(
                    controller: _email,
                    decoration: _inputDecoration(size),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: validateEmail,
                  ),
                ),
                SizedBox(height: size.height * 0.03),
                const Text(
                  'Phone Number',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: size.height * 0.008),
                IntlMobileField(
                  controller: _phoneController,
                  initialCountryCode: 'ET',
                  disableLengthCheck: false,
                  dropdownIconPosition: Position.trailing,
                  decoration: _inputDecoration(size),
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  validator: validateMobileNumber,
                ),
                SizedBox(height: size.height * 0.08),
                ElevatedButton(
                  onPressed: _onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(110, 182, 255, 1),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.25,
                      vertical: size.height * 0.02,
                    ),
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

  static InputDecoration _inputDecoration(Size size) {
    return InputDecoration(
      contentPadding: EdgeInsets.symmetric(
        vertical: size.height * 0.015,
        horizontal: size.width * 0.03,
      ),
      border: const OutlineInputBorder(),
      isDense: true,
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color.fromARGB(255, 214, 210, 210)),
      ),
    );
  }

  Widget _labeledField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w400,
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 14,
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.008),
        child,
      ],
    );
  }
}
