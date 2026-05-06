import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:healthpilot/data/constants.dart';
import 'package:healthpilot/features/profile/personal_info_contact_models.dart';
import 'package:intl_mobile_field/intl_mobile_field.dart';
import 'package:intl_mobile_field/mobile_number.dart';
import 'package:healthpilot/features/profile/language_translation.dart';

/// Add or edit a personal doctor. Pops [DoctorSetupResult] on save or remove.
class SetupPersonalDoctor extends StatefulWidget {
  const SetupPersonalDoctor({super.key, this.initial});

  final PersonalDoctorEntry? initial;

  @override
  State<SetupPersonalDoctor> createState() => _SetupPersonalDoctorState();
}

class _SetupPersonalDoctorState extends State<SetupPersonalDoctor> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  late final TextEditingController _phoneController;
  int _reportFrequency = 1;
  late String _selectedProfession;

  static const _professions = [
    CustomDropDownModel(name: 'Psychiatrists', value: 'Psychiatrists'),
    CustomDropDownModel(name: 'Internists', value: 'Internists'),
    CustomDropDownModel(name: 'Nephrologists', value: 'Nephrologists'),
    CustomDropDownModel(name: 'Neurologists', value: 'Neurologists'),
    CustomDropDownModel(name: 'Hematologists', value: 'Hematologists'),
    CustomDropDownModel(name: 'Cardiologists', value: 'Cardiologists'),
    CustomDropDownModel(name: 'General practitioner', value: 'General practitioner'),
  ];

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    _phoneController = TextEditingController(text: i?.phoneComplete ?? '');
    _selectedProfession = i?.profession ?? '';
    if (i != null) {
      _firstName.text = i.firstName;
      _lastName.text = i.lastName;
      _email.text = i.email;
      _reportFrequency = i.reportFrequency.clamp(1, 4);
    }
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _confirmRemove() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Remove this doctor?',
          style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 16),
        ),
        content: const Text(
          'They will be removed from your personal information list.',
          style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      Navigator.of(context).pop(DoctorSetupResult.removed());
    }
  }

  Future<void> _onSave() async {
    final profession = _selectedProfession;
    if (profession.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a profession')),
      );
      return;
    }
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
          'Save doctor profile?',
          style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 16),
        ),
        content: const Text(
          'You can edit or remove this doctor later from Personal Information.',
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

    final entry = PersonalDoctorEntry(
      id: widget.initial?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      firstName: _firstName.text.trim(),
      lastName: _lastName.text.trim(),
      profession: profession,
      email: _email.text.trim(),
      phoneComplete: phone.completeNumber,
      reportFrequency: _reportFrequency,
    );
    Navigator.of(context).pop(DoctorSetupResult.saved(entry));
  }

  void _onProfessionChanged(String value) {
    setState(() => _selectedProfession = value);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final initial = widget.initial;
    final cs = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: size.width * 0.08),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                          child: Text(
                            initial == null ? 'Setup Personal Doctor' : 'Edit Personal Doctor',
                            style: TextStyle(
                              fontSize: size.width * 0.05,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'PlusJakartaSans',
                              color: cs.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => openLanguageScreen(context),
                      child: SvgPicture.asset(
                        translateIcon,
                        width: size.width * 0.045,
                        height: size.width * 0.045,
                        fit: BoxFit.contain,
                        colorFilter: ColorFilter.mode(
                          cs.onSurface,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ],
                ),
                if (initial != null) ...[
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: _confirmRemove,
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      label: Text(
                        'Remove doctor',
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  ),
                ],
                SizedBox(height: size.height * 0.03),
                _fieldLabel(context, 'First Name'),
                TextFormField(
                  controller: _firstName,
                  decoration: _decoration(context, size),
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  validator: (v) => validateRequiredName(v, 'First name'),
                ),
                SizedBox(height: size.height * 0.03),
                _fieldLabel(context, 'Last Name'),
                TextFormField(
                  controller: _lastName,
                  decoration: _decoration(context, size),
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  validator: (v) => validateRequiredName(v, 'Last name'),
                ),
                SizedBox(height: size.height * 0.03),
                _fieldLabel(context, 'Personal Doctor Type'),
                CustomDropDownTextFild(
                  customDropDownModels: _professions,
                  initialProfession: initial?.profession,
                  onProfessionSelected: _onProfessionChanged,
                ),
                SizedBox(height: size.height * 0.03),
                _fieldLabel(context, 'Email'),
                TextFormField(
                  controller: _email,
                  decoration: _decoration(context, size),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: validateEmail,
                ),
                SizedBox(height: size.height * 0.03),
                _fieldLabel(context, 'Phone Number'),
                IntlMobileField(
                  controller: _phoneController,
                  initialCountryCode: 'ET',
                  disableLengthCheck: false,
                  disableLengthCounter: true,
                  dropdownIconPosition: Position.trailing,
                  decoration: _decoration(context, size),
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  validator: validateMobileNumber,
                ),
                SizedBox(height: size.height * 0.03),
                Text(
                  'How frequently do you want your report to be sent',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: cs.onSurface,
                  ),
                ),
                SizedBox(height: size.height * 0.02),
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
                            _radioRow(context, 1, 'Daily', size),
                            _radioRow(context, 2, 'Weekly', size),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: size.height * 0.08,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _radioRow(context, 3, 'Bi-Week', size),
                            _radioRow(context, 4, 'Monthly', size),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: size.height * 0.028),
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
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                SizedBox(height: 20 + bottomInset),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _radioRow(BuildContext context, int value, String label, Size size) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        CustomRadioBtn(
          value: value,
          groupValue: _reportFrequency,
          onChanged: (v) => setState(() => _reportFrequency = v),
        ),
        SizedBox(width: size.width * 0.02),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: cs.onSurface,
          ),
        ),
      ],
    );
  }

  static Widget _fieldLabel(BuildContext context, String text) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          color: cs.onSurfaceVariant,
          fontWeight: FontWeight.w400,
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 14,
        ),
      ),
    );
  }

  static InputDecoration _decoration(BuildContext context, Size size) {
    final cs = Theme.of(context).colorScheme;
    final border = OutlineInputBorder(
      borderSide: BorderSide(color: cs.outline),
    );
    return InputDecoration(
      contentPadding: EdgeInsets.symmetric(
        vertical: size.height * 0.015,
        horizontal: size.width * 0.03,
      ),
      border: border,
      enabledBorder: border,
      isDense: true,
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: cs.primary, width: 2),
      ),
    );
  }
}

class CustomRadioBtn extends StatefulWidget {
  const CustomRadioBtn({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  final int value;
  final int groupValue;
  final void Function(int value) onChanged;

  @override
  State<CustomRadioBtn> createState() => _CustomRadioBtnState();
}

class _CustomRadioBtnState extends State<CustomRadioBtn> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final outline = Theme.of(context).colorScheme.outline;
    return GestureDetector(
      onTap: () => widget.onChanged(widget.value),
      child: Container(
        padding: EdgeInsets.all(size.width * 0.004),
        height: size.height * 0.025,
        width: size.height * 0.025,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size.height * 0.125),
          border: Border.all(
            color: outline.withValues(alpha: 0.55),
            width: 2,
          ),
        ),
        child: widget.groupValue == widget.value
            ? Container(
                height: size.height * 0.015,
                width: size.height * 0.015,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(size.height * 0.075),
                  color: const Color.fromRGBO(110, 182, 255, 1),
                ),
              )
            : null,
      ),
    );
  }
}

class CustomDropDownModel {
  const CustomDropDownModel({required this.name, required this.value});

  final String name;
  final String value;
}

class CustomDropDownTextFild extends StatefulWidget {
  const CustomDropDownTextFild({
    super.key,
    required this.customDropDownModels,
    this.initialProfession,
    required this.onProfessionSelected,
  });

  final List<CustomDropDownModel> customDropDownModels;
  final String? initialProfession;
  final ValueChanged<String> onProfessionSelected;

  @override
  State<CustomDropDownTextFild> createState() => _CustomDropDownTextFildState();
}

class _CustomDropDownTextFildState extends State<CustomDropDownTextFild> {
  String selectedValue = '';
  final _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final initial = widget.initialProfession;
    if (initial != null && initial.isNotEmpty) {
      selectedValue = initial;
      _textEditingController.text = initial;
    }
  }

  void _onTap(String value) {
    setState(() {
      selectedValue = value;
      _textEditingController.text = value;
    });
    widget.onProfessionSelected(value);
  }

  void _showDialog() {
    final size = MediaQuery.sizeOf(context);
    final searchController = TextEditingController();

    showDialog<void>(
      context: context,
      barrierColor: const Color.fromARGB(120, 0, 0, 0),
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final cs = Theme.of(context).colorScheme;
            final q = searchController.text.toLowerCase();
            final filtered = widget.customDropDownModels
                .where((e) => e.name.toLowerCase().contains(q))
                .toList();

            return Dialog(
              child: Padding(
                padding: EdgeInsets.all(size.width * 0.04),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: searchController,
                      style: TextStyle(color: cs.onSurface),
                      decoration: InputDecoration(
                        hintText: 'Search profession',
                        hintStyle: TextStyle(color: cs.onSurfaceVariant),
                        prefixIcon: Icon(Icons.search, size: 20, color: cs.onSurfaceVariant),
                        border: const OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: cs.outline),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: cs.primary, width: 2),
                        ),
                        isDense: true,
                      ),
                      onChanged: (_) => setDialogState(() {}),
                    ),
                    SizedBox(height: size.height * 0.02),
                    SizedBox(
                      height: size.height * 0.32,
                      child: ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          final isSel = selectedValue == item.value;
                          return ListTile(
                            title: Text(
                              item.name,
                              style: TextStyle(
                                color: isSel ? cs.primary : cs.onSurface,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 14,
                              ),
                            ),
                            trailing: isSel
                                ? Icon(Icons.check, color: cs.primary)
                                : null,
                            onTap: () {
                              _onTap(item.value);
                              Navigator.of(dialogContext).pop();
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((_) => searchController.dispose());
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final cs = Theme.of(context).colorScheme;
    final border = OutlineInputBorder(
      borderSide: BorderSide(color: cs.outline),
    );
    return TextFormField(
      controller: _textEditingController,
      readOnly: true,
      style: TextStyle(color: cs.onSurface),
      decoration: InputDecoration(
        suffixIcon: GestureDetector(
          onTap: _showDialog,
          child: Icon(Icons.expand_more, size: 24, color: cs.onSurface),
        ),
        hintText: 'Select doctor profession',
        hintStyle: TextStyle(
          color: cs.onSurfaceVariant,
          fontWeight: FontWeight.w400,
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 14,
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: size.height * 0.015,
          horizontal: size.width * 0.03,
        ),
        border: border,
        enabledBorder: border,
        isDense: true,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: cs.primary, width: 2),
        ),
      ),
    );
  }
}
