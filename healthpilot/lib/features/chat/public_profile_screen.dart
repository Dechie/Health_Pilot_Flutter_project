import 'package:flutter/material.dart';
import 'package:healthpilot/data/constants.dart';
import 'package:line_icons/line_icons.dart';

class PublicProfileScreen extends StatelessWidget {
  const PublicProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leadingWidth: double.infinity,
        leading: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Components.customeAppBar(
              Icons.arrow_back, 'Public Profile', context),
        ),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Components.headerText('Add some info you want people to see'),
              SizedBox(
                height: size.height * 0.04,
              ),
              Components.profilePicture(
                  devsImage, LineIcons.edit, context, "Upload Image"),
              Components.aboutMeSection(
                'About me',
                publicProfileAboutMe,
                context,
              ),
              SizedBox(
                height: size.height * 0.1,
              ),
              Components.customButton(
                'Update Public Profile',
                () {
                  // Update Public Profile
                },
                context,
              ),
            ],
          ),
        )),
      ),
    );
  }
}

class Components {
  // costom Appbarr
  static Widget customeAppBar(
      IconData icon, String title, BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SizedBox(
      // margin: EdgeInsets.symmetric(
      //     horizontal: size.width * 0.08, vertical: size.width * 0.05),
      height: size.height * 0.1,
      child: Row(
        children: [
          InkWell(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Container(
              height: size.height * 0.06,
              width: size.height * 0.06,
              decoration: const BoxDecoration(
                color: Color.fromRGBO(219, 237, 255, 1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: const Color.fromRGBO(110, 182, 255, 1),
                ),
              ),
            ),
          ),
          SizedBox(
            width: size.width * 0.04,
          ),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: Color.fromRGBO(42, 42, 42, 1),
            ),
          ),
        ],
      ),
    );
  }

  static Widget headerText(String text) {
    return SizedBox(
      width: double.infinity,
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 16,
        ),
        textAlign: TextAlign.start,
      ),
    );
  }

  static Widget profilePicture(
      String imagePath, IconData icon, BuildContext context, String text) {
    final size = MediaQuery.of(context).size;

    return SizedBox(
      height: size.height * 0.2,
      child: Column(
        children: [
          Stack(
            children: [
              SizedBox(
                height: size.height * 0.12,
                width: size.height * 0.12,
                child: ClipOval(
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                    left: size.width * 0.145, top: size.width * 0.145),
                width: size.width * 0.06,
                height: size.width * 0.06,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(size.width * 0.035),
                ),
                child: Center(
                  child: InkWell(
                    onTap: () {
                      // image picker
                    },
                    child: Icon(
                      icon,
                      size: 15,
                      color: const Color.fromRGBO(42, 42, 42, 0.5),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: size.height * 0.03,
          ),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: Color.fromRGBO(42, 42, 42, 0.5),
            ),
          )
        ],
      ),
    );
  }

  static Widget aboutMeSection(
      String title, String description, BuildContext ctx) {
    final size = MediaQuery.of(ctx).size;
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: Color.fromRGBO(42, 42, 42, 1),
              ),
              textAlign: TextAlign.start,
            ),
          ),
          SizedBox(
            height: size.height * 0.005,
          ),
          Container(
            width: double.infinity,
            height: size.height * 0.45,
            padding: EdgeInsets.all(size.width * 0.04),
            decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.all(Radius.circular(size.width * 0.02)),
                gradient: const LinearGradient(colors: [
                  Color.fromRGBO(110, 182, 255, 0.1),
                  Color.fromRGBO(255, 255, 255, 0.25),
                ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
            child: Text(
              description,
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w500,
                height: 1.3,
                letterSpacing: -0.17,
                fontSize: 12,
                color: Color.fromRGBO(42, 42, 42, 1),
              ),
              textAlign: TextAlign.start,
            ),
          )
        ],
      ),
    );
  }

  static Widget customButton(
      String title, VoidCallback onPressed, BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: size.width * 0.15),
      height: size.height * 0.07,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size.width * 0.03),
        color: const Color.fromRGBO(110, 182, 255, 1),
      ),
      child: InkWell(
        onTap: onPressed,
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w400,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:healthpilot/data/constants.dart';
// import 'package:healthpilot/features/chat/similar_people_screen.dart';
// import 'package:healthpilot/features/chat/widgets/custom_update_button.dart';
// import 'package:healthpilot/widget/custom_app_bar_title.dart';

// class PublicProfileScree extends StatelessWidget {
//   const PublicProfileScree({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         appBar: const PreferredSize(
//             preferredSize: Size(50, 60),
//             child: CustomAppBar(
//                 title: 'Public Profile',
//                 leadingIcon: Icons.arrow_back_outlined)),
//         body: _buildBody(context),
//       ),
//     );
//   }

//   Widget _buildBody(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 34),
//       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         _buildHeaderText(),
//         const SizedBox(
//           height: 23,
//         ),
//         Align(child: _buildProfileAvatar()),
//         const SizedBox(
//           height: 12,
//         ),
//         Align(child: _buildUploadImageButton()),
//         _buildAboutCard(),
//         const SizedBox(
//           height: 20,
//         ),
//         Align(
//             child: CustomUpdateButton(
//                 onPressed: () {
//                   Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => const SimilarPeopleScreen(),
//                       ));
//                 },
//                 title: 'Update Public Profile'))
//       ]),
//     );
//   }

//   Widget _buildHeaderText() {
//     return Text(
//       'Add some info you want people to see',
//       style: TextStyle(
//           color: const Color.fromRGBO(42, 42, 42, 1),
//           fontFamily: 'Plus Jakarta Sans',
//           fontSize: 16.sp,
//           fontStyle: FontStyle.normal,
//           fontWeight: FontWeight.w600,
//           letterSpacing: -0.165),
//     );
//   }

//   Widget _buildProfileAvatar() {
//     return const Stack(
//       alignment: Alignment.center,
//       children: [
//         CircleAvatar(
//           backgroundImage: AssetImage(devsImage),
//           radius: 45.5,
//         ),
//         Positioned(
//             bottom: 3,
//             right: 5,
//             child: CircleAvatar(
//               radius: 8,
//               backgroundColor: Color.fromRGBO(42, 42, 42, 1),
//             )),
//       ],
//     );
//   }

//   Widget _buildUploadImageButton() {
//     return TextButton(
//         onPressed: () {},
//         child: Text(
//           'Upload images',
//           style: TextStyle(
//               color: const Color.fromRGBO(42, 42, 42, 0.50),
//               fontFamily: 'Plus Jakarta Sans',
//               fontSize: 14.sp,
//               fontStyle: FontStyle.normal,
//               fontWeight: FontWeight.w400,
//               letterSpacing: -0.165),
//         ));
//   }

//   Widget _buildAboutCard() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'About me',
//           style: TextStyle(
//               color: const Color.fromRGBO(42, 42, 42, 1),
//               fontFamily: 'Plus Jakarta Sans',
//               fontSize: 14.sp,
//               fontStyle: FontStyle.normal,
//               fontWeight: FontWeight.w400,
//               letterSpacing: -0.165),
//         ),
//         Card(
//           elevation: 0,
//           shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(5),
//               side: const BorderSide(
//                   color: Color.fromRGBO(255, 255, 255, 0.25), width: 1)),
//           color: const Color.fromRGBO(110, 182, 255, 0.1),
//           child: Padding(
//               padding: const EdgeInsets.fromLTRB(18.0, 20, 13, 48),
//               child: Text(
//                 publicProfileAboutMe,
//                 style: TextStyle(
//                     color: const Color.fromRGBO(42, 42, 24, 1),
//                     fontFamily: 'Plus Jakarta Sans',
//                     fontSize: 12.sp,
//                     height: 1.7,
//                     fontStyle: FontStyle.normal,
//                     fontWeight: FontWeight.w500,
//                     letterSpacing: -0.165),
//               )),
//         )
//       ],
//     );
//   }
// }
