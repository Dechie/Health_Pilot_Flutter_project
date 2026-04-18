import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:healthpilot/features/chat/audio_call_screen.dart';
import 'package:healthpilot/features/chat/chat_screen.dart';
import 'package:healthpilot/features/health/health_profile_screen.dart';
import 'package:intl/intl.dart';

import '../../data/constants.dart';
import 'vidoe_call_screen.dart';

class UserDetailScreen extends StatelessWidget {
  final String id;
  const UserDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final user = Users.findById(id);
    return Scaffold(
        floatingActionButton: Padding(
          padding: EdgeInsets.only(bottom: size.height * 0.65),
          child: SizedBox(
            height: size.height * 0.075,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        ChatScreen(senderId: user.userId, userId: '123')));
              },
              backgroundColor: const Color.fromRGBO(110, 182, 255, 0.25),
              elevation: 0,
              child: SvgPicture.asset(profileChatIcon),
            ),
          ),
        ),
        appBar: PreferredSize(
            preferredSize: Size(double.infinity, size.height * 0.25),
            child: CustomeAppBarForUserDetailScreen(
              title: user.displayName,
              profileImageUrl: devsImage,
              audioCall: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => AudioCallScreen(
                          id: id,
                        )));
              },
              videoCall: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => videoCallScreen(
                          id: id,
                        )));
              },
              more: () {},
              subTitle:
                  DateFormat.MMMMd().format(user.chatHistory.last.timestamp),
            )),
        body: const SingleChildScrollView(
          child: Column(
            children: [
              UserProfileInfo(
                mobile: '+251905221804',
                id: 'ID15463164946',
                notification: false,
              ),
              TabBarViewWidget()
            ],
          ),
        ));
  }
}

class CustomeAppBarForUserDetailScreen extends StatelessWidget {
  final String title;
  final String subTitle;
  final String profileImageUrl;
  final VoidCallback audioCall;
  final VoidCallback videoCall;
  final VoidCallback more;

  const CustomeAppBarForUserDetailScreen(
      {super.key,
      required this.title,
      required this.subTitle,
      required this.profileImageUrl,
      required this.audioCall,
      required this.videoCall,
      required this.more});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      color: const Color.fromRGBO(110, 182, 255, 0.05),
      margin: EdgeInsets.only(top: size.height * 0.01),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: size.height * 0.06,
                    height: size.height * 0.06,
                    decoration: const BoxDecoration(
                      color: Color.fromRGBO(110, 182, 225, 0.25),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                        child: Icon(
                      Icons.arrow_back,
                      color: Color.fromRGBO(110, 182, 255, 1),
                    )),
                  ),
                ),
                SizedBox(
                  width: size.width * 0.55,
                ),
                InkWell(
                  onTap: videoCall,
                  child: SvgPicture.asset(videoCallIcon),
                ),
                SizedBox(
                  width: size.width * 0.03,
                ),
                InkWell(
                  onTap: audioCall,
                  child: SvgPicture.asset(callIcon),
                ),
                SizedBox(
                  width: size.width * 0.03,
                ),
                InkWell(
                  onTap: more,
                  child: SvgPicture.asset(moreIcon),
                ),
              ],
            ),
            Row(
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Color.fromRGBO(110, 182, 255, 1),
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: size.height * 0.026,
                        backgroundImage: AssetImage(profileImageUrl),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: size.width * 0.015,
                ),
                SizedBox(
                  width: size.height * 0.23,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Color.fromRGBO(42, 42, 42, 1)),
                      ),
                      Text(
                        subTitle,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.w300,
                            fontSize: 12,
                            fontFamily: 'Plus Jakarta Sans',
                            color: Color.fromRGBO(42, 42, 42, 1)),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: size.width * 0.2,
                  height: size.height * 0.04,
                  decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color.fromRGBO(110, 182, 255, 0.3),
                          Color.fromRGBO(110, 182, 255, 0.26),
                          Color.fromRGBO(110, 182, 255, 0.08),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(5)),
                  child: const Center(
                    child: Text(
                      'Premium',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 10,
                        fontFamily: 'Plus Jakarta Sans',
                        color: Color.fromRGBO(42, 42, 42, 1),
                      ),
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

class UserProfileInfo extends StatelessWidget {
  final String mobile;
  final String id;
  final bool notification;
  const UserProfileInfo({
    super.key,
    required this.mobile,
    required this.id,
    required this.notification,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          InfoBuilder(
            content: mobile,
            title: 'Mobile',
          ),
          const SizedBox(
            height: 10,
          ),
          InfoBuilder(
            content: id,
            title: 'User ID',
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: size.height * 0.06,
                width: size.width * 0.5,
                child: const InfoBuilder(
                  content: 'Notifications',
                  title: 'On',
                ),
              ),
              CustomeSwitch(
                status: true,
                onChange: (value) {
                  print(value);
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}

class InfoBuilder extends StatelessWidget {
  final String content;
  final String title;
  const InfoBuilder({
    super.key,
    required this.content,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            content,
            style: const TextStyle(
                fontWeight: FontWeight.w400,
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 14,
                color: Color.fromRGBO(42, 42, 42, 1)),
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            title,
            style: const TextStyle(
                fontWeight: FontWeight.w400,
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 10,
                color: Color.fromRGBO(42, 42, 42, 0.5)),
          ),
        ],
      ),
    );
  }
}

class CustomeSwitch extends StatefulWidget {
  const CustomeSwitch({super.key, required this.onChange, this.status});
  final Function onChange;
  final status;

  @override
  State<CustomeSwitch> createState() => _CustomeSwitchState();
}

class _CustomeSwitchState extends State<CustomeSwitch> {
  bool value = false;
  @override
  void initState() {
    value = widget.status;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
        onTap: () {
          setState(() {
            value = !value;

            widget.onChange(value);
          });
        },
        child: Stack(
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          children: [
            Container(
              width: size.width * 0.12,
              height: size.height * 0.03,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: value
                      ? const Color.fromRGBO(110, 182, 255, 0.05)
                      : const Color.fromRGBO(42, 42, 42, 0.1),
                  border: Border.all(
                      color: const Color.fromRGBO(110, 182, 255, 1))),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: size.height * 0.02,
              height: size.height * 0.02,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: const Color.fromRGBO(110, 182, 255, 1)),
            ),
          ],
        ));
  }
}

class TabBarViewWidget extends StatelessWidget {
  const TabBarViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    Widget tab(String text) {
      return Tab(
        child: Text(
          text,
          style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 14,
              fontWeight: FontWeight.w400),
        ),
      );
    }

    return DefaultTabController(
      length: 5,
      initialIndex: 0,
      child: SizedBox(
        height: size.height * 0.5,
        child: Column(
          children: [
            TabBar(
              unselectedLabelColor: const Color.fromRGBO(42, 42, 42, 1),
              labelColor: const Color.fromRGBO(110, 182, 255, 1),
              // tabAlignment: TabAlignment.center,
              isScrollable: true,
              labelPadding: const EdgeInsets.symmetric(horizontal: 20),
              indicatorSize: TabBarIndicatorSize.label,
              tabs: [
                tab('Media'),
                tab('Files'),
                tab('Audio'),
                tab('Links'),
                tab('Groups'),
              ],
            ),
            Expanded(
              child: TabBarView(children: [
                Center(
                  child: tab('No media shared!'),
                ),
                Center(
                  child: tab('No files shared!'),
                ),
                Center(
                  child: tab('No links shared!'),
                ),
                Center(
                  child: tab('No groups in common!'),
                ),
              ]),
            )
          ],
        ),
      ),
    );
  }
}
