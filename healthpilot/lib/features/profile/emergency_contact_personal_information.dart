import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:healthpilot/data/constants.dart';
import 'package:healthpilot/features/food_nutrition/food_nutrition_history_screen.dart';
import 'package:healthpilot/features/food_nutrition/food_nutrition_tracking_screen.dart';
import 'package:healthpilot/features/food_nutrition/nutrition_provider.dart';
import 'package:healthpilot/core/navigation/app_navigation.dart';
import 'package:healthpilot/core/widgets/setup_promo_card.dart';
import 'package:healthpilot/features/emergency_contact/setup_emergency_contact.dart';
import 'package:healthpilot/features/personal_doctor/setup_personal_doctor.dart';
import 'package:healthpilot/features/profile/contacts_provider.dart';
import 'package:healthpilot/features/profile/personal_info_contact_models.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:intl_mobile_field/intl_mobile_field.dart';
import 'package:line_icons/line_icons.dart';

import 'package:healthpilot/theme/app_theme.dart';
import 'package:healthpilot/features/profile/language_translation.dart';

class PersonalInformation extends StatefulWidget {
  const PersonalInformation({super.key});

  @override
  State<PersonalInformation> createState() => _PersonalInformationState();
}

class _PersonalInformationState extends State<PersonalInformation> {
  String? _profileImagePath;

  Future<void> _pickProfilePhoto() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file != null && mounted) {
      setState(() => _profileImagePath = file.path);
    }
  }

  Future<void> _addOrEditEmergency({
    EmergencyContactEntry? existing,
  }) async {
    final created = await Navigator.of(context).push<EmergencyContactEntry>(
      MaterialPageRoute(
        builder: (context) => SetupEmergencyContact(initial: existing),
      ),
    );
    if (!mounted || created == null) return;
    final provider = context.read<ContactsProvider>();
    if (existing != null) {
      await provider.updateContact(created);
    } else {
      await provider.addContact(created);
    }
  }

  Future<void> _confirmRemoveEmergency(String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove emergency contact?'),
        content: const Text('This contact will be removed from your list.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      await context.read<ContactsProvider>().deleteContact(id);
    }
  }

  Future<void> _addOrEditDoctor({PersonalDoctorEntry? existing}) async {
    final result = await Navigator.of(context).push<DoctorSetupResult>(
      MaterialPageRoute(
        builder: (context) => SetupPersonalDoctor(initial: existing),
      ),
    );
    if (!mounted || result == null) return;
    final provider = context.read<ContactsProvider>();
    if (result.deleted && existing != null) {
      await provider.deleteDoctor(existing.id);
      return;
    }
    final entry = result.entry;
    if (entry == null) return;
    if (existing != null) {
      await provider.updateDoctor(entry);
    } else {
      await provider.addDoctor(entry);
    }
  }

  Future<void> _confirmRemoveDoctor(String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove personal doctor?'),
        content: const Text('This doctor will be removed from your list.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      await context.read<ContactsProvider>().deleteDoctor(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final cs = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final contactsProvider = context.watch<ContactsProvider>();
    final emergencyContacts = contactsProvider.contacts;
    final doctors = contactsProvider.doctors;

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
                      "Personal Information",
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
        ),
      ),
      body: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.only(bottom: 24 + bottomInset),
        children: [
          SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: size.height * 0.02,
                ),
                GestureDetector(
                  onTap: _pickProfilePhoto,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: size.width * 0.1,
                        backgroundImage: _profileImagePath != null
                            ? FileImage(File(_profileImagePath!))
                            : null,
                        child: _profileImagePath == null
                            ? ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(size.height * 0.08),
                                child: Image.asset(
                                  height: size.width * 0.25,
                                  personPicForProfile,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : null,
                      ),
                      Positioned(
                        top: size.width * 0.16,
                        left: size.width * 0.13,
                        child: Container(
                          height: size.width * 0.04,
                          width: size.width * 0.04,
                          padding: EdgeInsets.only(left: size.width * 0.01),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              size.width * 0.02,
                            ),
                            color: const Color.fromARGB(255, 255, 255, 255),
                          ),
                          child: Icon(
                            LineIcons.edit,
                            size: size.width * 0.03,
                            color: const Color.fromARGB(255, 73, 70, 70),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: size.height * 0.03,
                ),
                Text(
                  'Tap to upload your profile photo',
                  style: AppTheme.bodyMuted(context),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.08, vertical: size.width * 0.08),
            child: Form(
              child: Column(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'First Name',
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 14,
                        ),
                      ),
                      TextFormField(
                        maxLines: 1,
                        style: TextStyle(color: cs.onSurface),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              vertical: size.height * 0.015,
                              horizontal: size.width * 0.03),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: cs.outline),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: cs.outline),
                          ),
                          isDense: true,
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: cs.primary, width: 2),
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
                      Text(
                        'Last Name',
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 14,
                        ),
                      ),
                      TextFormField(
                        maxLines: 1,
                        style: TextStyle(color: cs.onSurface),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              vertical: size.height * 0.015,
                              horizontal: size.width * 0.03),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: cs.outline),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: cs.outline),
                          ),
                          isDense: true,
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: cs.primary, width: 2),
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
                      Text(
                        'Email',
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 14,
                        ),
                      ),
                      TextFormField(
                        maxLines: 1,
                        style: TextStyle(color: cs.onSurface),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              vertical: size.height * 0.015,
                              horizontal: size.width * 0.03),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: cs.outline),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: cs.outline),
                          ),
                          isDense: true,
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: cs.primary, width: 2),
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
                      Text(
                        'Phone Number',
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 14,
                        ),
                      ),
                      IntlMobileField(
                        disableLengthCheck: true,
                        disableLengthCounter: true,
                        dropdownIconPosition: Position.trailing,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              vertical: size.height * 0.015,
                              horizontal: size.width * 0.03),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: cs.outline),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: cs.outline),
                          ),
                          isDense: true,
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: cs.primary, width: 2),
                          ),
                        ),
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.done,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: size.height * 0.05,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Emergency Contacts',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: cs.onSurface,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          if (emergencyContacts.length >= 3) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'You can add up to 3 emergency contacts.',
                                ),
                              ),
                            );
                            return;
                          }
                          _addOrEditEmergency();
                        },
                        icon: Icon(
                          Icons.add_circle_outline,
                          color: cs.onSurface,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: emergencyContacts.isEmpty
                        ? size.height * 0.08
                        : size.height * 0.11 * emergencyContacts.length,
                    child: emergencyContacts.isEmpty
                        ? const Center(
                            child: Text(
                              'No emergency contact found!',
                              style: TextStyle(
                                color: Color.fromRGBO(110, 182, 255, 1),
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: emergencyContacts.length,
                            itemBuilder: (context, index) {
                              final e = emergencyContacts[index];
                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom: size.height * 0.012,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          width: size.width * 0.003,
                                          height: size.height * 0.09,
                                          color: const Color.fromRGBO(
                                            110,
                                            182,
                                            255,
                                            1,
                                          ),
                                        ),
                                        Container(
                                          width: size.width * 0.03,
                                          height: size.width * 0.03,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              size.width * 0.015,
                                            ),
                                            color: const Color.fromRGBO(
                                              110,
                                              182,
                                              255,
                                              1,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                          left: size.width * 0.02,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              e.displayName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                              ),
                                            ),
                                            if (e.relationship != null &&
                                                e.relationship!.isNotEmpty)
                                              Text(
                                                e.relationship!,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Color.fromRGBO(
                                                    42,
                                                    42,
                                                    42,
                                                    0.65,
                                                  ),
                                                ),
                                              ),
                                            Text(
                                              e.email,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Color.fromRGBO(
                                                  42,
                                                  42,
                                                  42,
                                                  0.5,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: 'Edit',
                                      onPressed: () => _addOrEditEmergency(
                                        existing: e,
                                      ),
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        color: Color.fromRGBO(
                                          110,
                                          182,
                                          255,
                                          1,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: 'Remove',
                                      onPressed: () =>
                                          _confirmRemoveEmergency(e.id),
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Color.fromRGBO(
                                          180,
                                          60,
                                          60,
                                          1,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Personal Doctor',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: cs.onSurface,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          if (doctors.length >= 3) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'You can add up to 3 personal doctors.',
                                ),
                              ),
                            );
                            return;
                          }
                          _addOrEditDoctor();
                        },
                        icon: Icon(
                          Icons.add_circle_outline,
                          color: cs.onSurface,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: doctors.isEmpty
                        ? size.height * 0.08
                        : size.height * 0.11 * doctors.length,
                    child: doctors.isEmpty
                        ? const Center(
                            child: Text(
                              'You don\'t have a personal doctor!',
                              style: TextStyle(
                                color: Color.fromRGBO(110, 182, 255, 1),
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: doctors.length,
                            itemBuilder: (context, index) {
                              final d = doctors[index];
                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom: size.height * 0.012,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          width: size.width * 0.003,
                                          height: size.height * 0.09,
                                          color: const Color.fromRGBO(
                                            110,
                                            182,
                                            255,
                                            1,
                                          ),
                                        ),
                                        Container(
                                          width: size.width * 0.03,
                                          height: size.width * 0.03,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              size.width * 0.015,
                                            ),
                                            color: const Color.fromRGBO(
                                              110,
                                              182,
                                              255,
                                              1,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                          left: size.width * 0.02,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              d.displayName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                              ),
                                            ),
                                            Text(
                                              d.profession,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Color.fromRGBO(
                                                  42,
                                                  42,
                                                  42,
                                                  0.65,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              d.email,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Color.fromRGBO(
                                                  42,
                                                  42,
                                                  42,
                                                  0.5,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: 'Edit',
                                      onPressed: () => _addOrEditDoctor(
                                        existing: d,
                                      ),
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        color: Color.fromRGBO(
                                          110,
                                          182,
                                          255,
                                          1,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: 'Remove',
                                      onPressed: () =>
                                          _confirmRemoveDoctor(d.id),
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Color.fromRGBO(
                                          180,
                                          60,
                                          60,
                                          1,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                  SizedBox(
                    height: size.height * 0.05,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Food and Nutrition Tracking',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: cs.onSurface,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (context) =>
                                  const FoodNutritionHistoryScreen(),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.arrow_forward,
                          color: Color.fromRGBO(110, 182, 255, 1),
                        ),
                      ),
                    ],
                  ),
                  ..._foodHistoryPreviewRows(context, size),
                  SizedBox(
                    height: size.height * 0.03,
                  ),
                  Consumer<NutritionProvider>(
                    builder: (context, nutrition, _) => SetupPromoCard(
                      screenWidth: size.width,
                      width: double.infinity,
                      expandVertically: true,
                      margin: EdgeInsets.zero,
                      title: SetupPromoCardCopy.foodNutritionTitle,
                      description:
                          SetupPromoCardCopy.foodNutritionDescription,
                      icon: null,
                      buttonText: "Set nutrition goals",
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (context) =>
                                const FoodNutritionTrackingScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.07,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      AppNavigation.replaceWithHome(
                        context,
                        useRootNavigator: false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(110, 182, 255, 1),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                            horizontal: size.width * 0.25,
                            vertical: size.height * 0.02),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    child: const Text('Finish'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _foodHistoryPreviewRows(BuildContext context, Size size) {
    void openHistory() {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => const FoodNutritionHistoryScreen(),
        ),
      );
    }

    Widget row(String label) {
      return InkWell(
        onTap: openHistory,
        child: Padding(
          padding: EdgeInsets.only(bottom: size.height * 0.012),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: size.width * 0.003,
                    height: size.height * 0.055,
                    color: const Color.fromRGBO(110, 182, 255, 1),
                  ),
                  Container(
                    width: size.width * 0.03,
                    height: size.width * 0.03,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(size.width * 0.015),
                      color: const Color.fromRGBO(110, 182, 255, 1),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: size.width * 0.02),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward,
                        color: Color.fromRGBO(110, 182, 255, 1),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return [
      row('11:30 AM, May 13, 2023'),
      row('2:15 PM, May 12, 2023'),
    ];
  }
}
