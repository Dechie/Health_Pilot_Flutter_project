import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:healthpilot/data/constants.dart';
import 'package:intl/intl.dart';

import 'chat_screen.dart';

class GroupChatScreen extends StatelessWidget {
  final String groupId;
  final String userId;

  GroupChatScreen({super.key, required this.groupId, required this.userId});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final group = GroupChats.findGroupById(groupId);
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size(size.width, size.height * 0.15),
          child: CustomeAppBarForChatScreen(
            title: group.groupName,
            subTitle: ' ${group.membersId.length} members',
            profileImageUrl: devsImage,
            isMuted: group.isMuted,
            more: () {},
          )),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            group.groupChatHistory.isEmpty
                ? const EmptyChat()
                : ChatList(
                    senderId: groupId,
                    userId: userId,
                    chatList: group.groupChatHistory),
            SendMessage(
              attach: () {
                print('add file');
              },
              sendMessage: (message) {
                print('send $message');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CustomeAppBarForChatScreen extends StatelessWidget {
  final String title;
  final String subTitle;
  final String profileImageUrl;
  final bool isMuted;
  final VoidCallback more;
  const CustomeAppBarForChatScreen(
      {super.key,
      required this.title,
      required this.subTitle,
      required this.profileImageUrl,
      required this.isMuted,
      required this.more});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        margin: EdgeInsets.only(top: size.height * 0.01),
        child: Row(
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
              width: size.width * 0.03,
            ),
            Container(
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
            SizedBox(
              width: size.width * 0.015,
            ),
            SizedBox(
              width: size.height * 0.28,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: size.width * 0.4,
                        child: Text(
                          title,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Color.fromRGBO(42, 42, 42, 1)),
                        ),
                      ),
                      if (isMuted) SvgPicture.asset(muteIcon)
                    ],
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
            SizedBox(
              width: size.width * 0.03,
            ),
            InkWell(
              onTap: more,
              child: SvgPicture.asset(moreIcon),
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyChat extends StatelessWidget {
  const EmptyChat({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Expanded(
      child: Center(
        child: Container(
          height: size.height * 0.4,
          child: Column(
            children: [
              SvgPicture.asset(voiceChatIcon),
              const Text(
                'Be the first to say hello',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChatList extends StatelessWidget {
  final List<ChatMessage> chatList;
  final String senderId;
  final String userId;

  const ChatList({
    super.key,
    required this.chatList,
    required this.senderId,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Expanded(
      child: GroupedListView(
          elements: chatList,
          groupBy: (chat) => DateFormat.MMMd().format(chat.timestamp),
          groupSeparatorBuilder: (chat) => SizedBox(
                width: double.infinity,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: size.width * 0.1),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const Expanded(child: Divider()),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          DateFormat.MMMd().format(DateTime.now()) == chat
                              ? 'Today'
                              : chat,
                          style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 10,
                              color: Color.fromRGBO(42, 42, 42, 0.5)),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                ),
              ),
          itemBuilder: (context, chat) => Wrap(
                children: [
                  Bubble(
                    alignment: int.parse(chat.senderId) != int.parse(userId)
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    radius: const Radius.circular(5),
                    nip: int.parse(chat.senderId) != int.parse(userId)
                        ? BubbleNip.leftBottom
                        : BubbleNip.rightBottom,
                    margin: const BubbleEdges.symmetric(vertical: 5),
                    padding: const BubbleEdges.all(0),
                    showNip: true,
                    color: int.parse(chat.senderId) != 1
                        ? const Color.fromRGBO(110, 182, 255, 0.30)
                        : const Color.fromRGBO(110, 182, 255, 0.08),
                    // color: Color.fromRGBO(110, 182, 255, 0.30),
                    shadowColor: Colors.transparent,
                    child: Stack(
                      children: [
                        int.parse(chat.senderId) != int.parse(userId)
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14, horizontal: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.white,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      Users.findById(chat.senderId).displayName,
                                      style: const TextStyle(
                                          fontFamily: 'Plus Jakarta Sans',
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12,
                                          color:
                                              Color.fromRGBO(42, 42, 42, 0.5)),
                                    ),
                                    Wrap(
                                      children: [
                                        Text(
                                          chat.content,
                                          style: GoogleFonts.plusJakartaSans(
                                              color: const Color.fromRGBO(
                                                  42, 42, 42, 1),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400),
                                        ),
                                        SizedBox(
                                          width: size.width * 0.02,
                                        ),
                                        Text(
                                          DateFormat('hh:mm a')
                                              .format(chat.timestamp),
                                          style: GoogleFonts.plusJakartaSans(
                                              fontSize: 8,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            : Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14, horizontal: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.white,
                                ),
                                child: Wrap(
                                  children: [
                                    Text(
                                      DateFormat('hh:mm a')
                                          .format(chat.timestamp),
                                      style: GoogleFonts.plusJakartaSans(
                                          fontSize: 8,
                                          fontWeight: FontWeight.w400),
                                    ),
                                    SizedBox(
                                      width: size.width * 0.02,
                                    ),
                                    Expanded(
                                      child: Wrap(
                                        children: [
                                          Text(
                                            chat.content,
                                            style: GoogleFonts.plusJakartaSans(
                                                color: const Color.fromRGBO(
                                                    42, 42, 42, 1),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                        int.parse(chat.senderId) != int.parse(userId)
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14, horizontal: 10),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    gradient: const LinearGradient(colors: [
                                      Color.fromRGBO(110, 182, 255, 0.30),
                                      Color.fromRGBO(110, 182, 255, 0.26),
                                      Color.fromRGBO(110, 182, 255, 0.08),
                                    ], stops: [
                                      0.17,
                                      0.75,
                                      1
                                    ])),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      Users.findById(chat.senderId).displayName,
                                      style: const TextStyle(
                                          fontFamily: 'Plus Jakarta Sans',
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12,
                                          color:
                                              Color.fromRGBO(42, 42, 42, 0.5)),
                                    ),
                                    Wrap(
                                      // mainAxisAlignment:
                                      //     MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Wrap(
                                            children: [
                                              Text(
                                                chat.content,
                                                style:
                                                    GoogleFonts.plusJakartaSans(
                                                        color: const Color
                                                            .fromRGBO(
                                                            39, 10, 10, 1),
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w400),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          width: size.width * 0.02,
                                        ),
                                        Text(
                                          DateFormat('hh:mm a')
                                              .format(chat.timestamp),
                                          style: GoogleFonts.plusJakartaSans(
                                              fontSize: 8,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            : Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14, horizontal: 10),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    gradient: const LinearGradient(colors: [
                                      Color.fromRGBO(110, 182, 255, 0.30),
                                      Color.fromRGBO(110, 182, 255, 0.26),
                                      Color.fromRGBO(110, 182, 255, 0.08),
                                    ], stops: [
                                      0.17,
                                      0.75,
                                      1
                                    ])),
                                child: Wrap(
                                  // mainAxisAlignment:
                                  //     MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      DateFormat('hh:mm a')
                                          .format(chat.timestamp),
                                      style: GoogleFonts.plusJakartaSans(
                                          fontSize: 8,
                                          fontWeight: FontWeight.w400),
                                    ),
                                    SizedBox(
                                      width: size.width * 0.02,
                                    ),
                                    Wrap(
                                      children: [
                                        Text(
                                          chat.content,
                                          style: GoogleFonts.plusJakartaSans(
                                              color: const Color.fromRGBO(
                                                  39, 10, 10, 1),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                      ],
                    ),
                  ),
                ],
              )),
    );
  }
}

class SendMessage extends StatefulWidget {
  final Function sendMessage;
  final VoidCallback attach;
  const SendMessage(
      {super.key, required this.sendMessage, required this.attach});

  @override
  State<SendMessage> createState() => _SendMessageState();
}

class _SendMessageState extends State<SendMessage> {
  String message = '';
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        InkWell(
          onTap: widget.attach,
          child: const Icon(
            Icons.add_outlined,
            color: Color.fromRGBO(42, 42, 42, 1),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
              vertical: size.height * 0.01, horizontal: size.width * 0.04),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: const Color.fromRGBO(82, 30, 30, 0.247), width: 1)),
          height: size.height * 0.06,
          width: size.width * 0.72,
          child: TextField(
            onChanged: (Value) {
              setState(() {
                message = Value;
              });
            },
            maxLines: 1,
            decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Message',
                hintStyle: TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w400,
                  color: Color.fromRGBO(42, 42, 42, 0.25),
                  fontSize: 12,
                )),
          ),
        ),
        InkWell(
          onTap: () => widget.sendMessage(message),
          child: Icon(
            message.isEmpty
                ? Icons.keyboard_voice_outlined
                : Icons.send_outlined,
            color: const Color.fromRGBO(42, 42, 42, 1),
          ),
        )
      ],
    );
  }
}

// dummy data
class GroupChat {
  final String groupId;
  final bool isMuted;
  final bool isPro;
  final String groupName;
  final List<String> membersId;
  final List<ChatMessage> groupChatHistory;

  GroupChat({
    required this.isPro,
    required this.isMuted,
    required this.groupId,
    required this.groupName,
    required this.membersId,
    required this.groupChatHistory,
  });
}

class GroupChats {
  static final _groupChats = [
    GroupChat(
      isPro: true,
      isMuted: false,
      groupId: 'g1',
      groupName: 'Schizophrenia Support',
      membersId: ['1', '2', '3'],
      groupChatHistory: [
        ChatMessage(
          senderId: '1',
          content: 'Hello John Doe!',
          timestamp: DateTime.now().subtract(Duration(days: 2)),
        ),
        ChatMessage(
          senderId: '2',
          content: 'How are you today?',
          timestamp: DateTime.now().subtract(Duration(days: 2, hours: 23)),
        ),
        ChatMessage(
          senderId: '3',
          content: 'Hi! I\'m doing well, thanks!',
          timestamp: DateTime.now().subtract(Duration(days: 2, hours: 22)),
        ),
        ChatMessage(
          senderId: '1',
          content: 'That\'s great to hear!',
          timestamp: DateTime.now().subtract(Duration(days: 2, hours: 21)),
        ),
        ChatMessage(
          senderId: '2',
          content: 'By the way, have you seen the latest movie?',
          timestamp: DateTime.now().subtract(Duration(days: 2, hours: 20)),
        ),
      ],
    ),
    GroupChat(
      isMuted: true,
      isPro: false,
      groupId: 'g2',
      groupName: 'Schizophrenia Support',
      membersId: ['4', '2', '5'],
      groupChatHistory: [
        ChatMessage(
          senderId: '4',
          content: 'Hello John Doe!',
          timestamp: DateTime.now().subtract(Duration(days: 2)),
        ),
        ChatMessage(
          senderId: '5',
          content: 'How are you today?',
          timestamp: DateTime.now().subtract(Duration(days: 2, hours: 23)),
        ),
        ChatMessage(
          senderId: '1',
          content: 'Hi! I\'m doing well, thanks!',
          timestamp: DateTime.now().subtract(Duration(days: 2, hours: 22)),
        ),
        ChatMessage(
          senderId: '2',
          content: 'That\'s great to hear!',
          timestamp: DateTime.now().subtract(Duration(days: 2, hours: 21)),
        ),
        ChatMessage(
          senderId: '2',
          content: 'By the way, have you seen the latest movie?',
          timestamp: DateTime.now().subtract(Duration(days: 2, hours: 20)),
        ),
      ],
    ),
    GroupChat(
      isMuted: true,
      isPro: false,
      groupId: 'g3',
      groupName: 'Schizophrenia Support',
      membersId: ['1', '3', '5'],
      groupChatHistory: [
        ChatMessage(
          senderId: '1',
          content: 'Hello John Doe!',
          timestamp: DateTime.now().subtract(Duration(days: 2)),
        ),
        ChatMessage(
          senderId: '3',
          content: 'How are you today?',
          timestamp: DateTime.now().subtract(Duration(days: 2, hours: 23)),
        ),
        ChatMessage(
          senderId: '5',
          content: 'Hi! I\'m doing well, thanks!',
          timestamp: DateTime.now().subtract(Duration(days: 2, hours: 22)),
        ),
        ChatMessage(
          senderId: '1',
          content: 'That\'s great to hear!',
          timestamp: DateTime.now().subtract(Duration(days: 2, hours: 21)),
        ),
        ChatMessage(
          senderId: '1',
          content: 'By the way, have you seen the latest movie?',
          timestamp: DateTime.now().subtract(Duration(days: 2, hours: 20)),
        ),
      ],
    ),
  ];

  static List<GroupChat> get groupChats => _groupChats;
  static GroupChat findGroupById(String id) {
    return _groupChats.firstWhere((element) => element.groupId == id);
  }
}
