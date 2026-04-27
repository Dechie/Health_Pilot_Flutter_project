import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:healthpilot/data/constants.dart';
import 'package:healthpilot/features/chat/audio_call_screen.dart';
import 'package:healthpilot/features/chat/user_detail_screen.dart';
import 'package:healthpilot/theme/app_theme.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatelessWidget {
  final String senderId;
  final String userId;

  const ChatScreen({super.key, required this.senderId, required this.userId});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final user = Users.findById(senderId);
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size(size.width, size.height * 0.15),
          child: CustomeAppBarForChatScreen(
            title: user.displayName,
            subTitle:
                'Last seen ${DateFormat.yMMMMd().format(user.chatHistory.last.timestamp)}',
            profileImageUrl: devsImage,
            callNow: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => AudioCallScreen(
                        id: senderId,
                      )));
            },
            more: () {},
            senderId: user.userId,
          )),
      body: SafeArea(
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              user.chatHistory.isEmpty
                  ? const EmptyChat()
                  : ChatList(
                      senderId: senderId,
                      userId: userId,
                      chatList: user.chatHistory),
              SendMessage(
                attach: () {
                  debugPrint('add file');
                },
                sendMessage: (message) {
                  debugPrint('send $message');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomeAppBarForChatScreen extends StatelessWidget {
  final String title;

  final String subTitle;
  final String profileImageUrl;
  final VoidCallback callNow;
  final VoidCallback more;
  final String senderId;
  const CustomeAppBarForChatScreen(
      {super.key,
      required this.title,
      required this.subTitle,
      required this.profileImageUrl,
      required this.callNow,
      required this.more,
      required this.senderId});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cs = Theme.of(context).colorScheme;
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
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.arrow_back,
                    color: cs.onSurface,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: size.width * 0.03,
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => UserDetailScreen(
                          id: senderId,
                        )));
              },
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: cs.primary,
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
              width: size.height * 0.28,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  Text(
                    subTitle,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      fontFamily: 'Plus Jakarta Sans',
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: callNow,
              child: SvgPicture.asset(
                callIcon,
                colorFilter: ColorFilter.mode(cs.onSurface, BlendMode.srcIn),
              ),
            ),
            SizedBox(
              width: size.width * 0.03,
            ),
            InkWell(
              onTap: more,
              child: SvgPicture.asset(
                moreIcon,
                colorFilter: ColorFilter.mode(cs.onSurface, BlendMode.srcIn),
              ),
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
        child: SizedBox(
          height: size.height * 0.4,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                voiceChatIcon,
                height: size.height * 0.1,
              ),
              const SizedBox(height: 20),
              const Text(
                'Be the first to say hello',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color.fromRGBO(42, 42, 42, 1),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.12),
                child: const Text(
                  'Send a message below to start this conversation.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Color.fromRGBO(42, 42, 42, 0.55),
                  ),
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
                      Expanded(
                        child: Divider(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.25),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          DateFormat.MMMd().format(DateTime.now()) == chat
                              ? 'Today'
                              : chat,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 10,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.25),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          itemBuilder: (context, chat) {
            final isIncoming = int.parse(chat.senderId) != int.parse(userId);
            final cs = Theme.of(context).colorScheme;

            final bubbleDecoration = isIncoming
                ? BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                  )
                : BoxDecoration(
                    gradient: AppTheme.chatBubbleGradient(context),
                    borderRadius: BorderRadius.circular(10),
                  );

            return Bubble(
              alignment:
                  isIncoming ? Alignment.centerLeft : Alignment.centerRight,
              radius: const Radius.circular(10),
              nip: isIncoming ? BubbleNip.leftBottom : BubbleNip.rightBottom,
              margin: const BubbleEdges.symmetric(vertical: 5),
              padding: const BubbleEdges.all(0),
              showNip: true,
              color: Colors.transparent,
              shadowColor: Colors.transparent,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                decoration: bubbleDecoration,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        chat.content,
                        style: GoogleFonts.plusJakartaSans(
                          color: isIncoming ? cs.onSurface : cs.onPrimary,
                          fontSize: 12,
                          fontWeight: isIncoming ? FontWeight.w400 : FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      DateFormat('hh:mm a').format(chat.timestamp),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 8,
                        fontWeight: FontWeight.w400,
                        color: (isIncoming ? cs.onSurface : cs.onPrimary)
                            .withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
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
    final cs = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        InkWell(
          onTap: widget.attach,
          child: Icon(
            Icons.add_outlined,
            color: cs.onSurface,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
              vertical: size.height * 0.01, horizontal: size.width * 0.04),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: cs.outline, width: 1),
              color: cs.surfaceContainerHighest),
          height: size.height * 0.06,
          width: size.width * 0.72,
          child: TextField(
            onChanged: (value) {
              setState(() {
                message = value;
              });
            },
            maxLines: 1,
            style: TextStyle(color: cs.onSurface),
            decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Message',
                hintStyle: TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w400,
                  color: cs.onSurfaceVariant,
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
            color: cs.onSurface,
          ),
        )
      ],
    );
  }
}

class User {
  // Attributes
  String userId;
  String displayName;
  String profilePictureUrl;
  String status;
  List<ChatMessage> chatHistory;
  bool isOnline;
  String bio;
  bool isPro;

  // Constructor
  User(
      {required this.userId,
      required this.displayName,
      required this.profilePictureUrl,
      required this.status,
      required this.chatHistory,
      required this.isOnline,
      required this.bio,
      required this.isPro});
}

class ChatMessage {
  String senderId;
  String content;
  DateTime timestamp;

  ChatMessage({
    required this.senderId,
    required this.content,
    required this.timestamp,
  });
}

class Users {
  static final _userList = [
    User(
      userId: '1',
      displayName: 'John Doe',
      profilePictureUrl: 'https://example.com/john_doe.jpg',
      status: 'Online',
      chatHistory: [
        ChatMessage(
          senderId: '123',
          content: 'Hello John Doe!',
          timestamp: DateTime.now().subtract(Duration(days: 2)),
        ),
        ChatMessage(
          senderId: '123',
          content: 'How are you today?',
          timestamp: DateTime.now().subtract(Duration(days: 2, hours: 23)),
        ),
        ChatMessage(
          senderId: '1',
          content: 'Hi! I\'m doing well, thanks!',
          timestamp: DateTime.now().subtract(Duration(days: 2, hours: 22)),
        ),
        ChatMessage(
          senderId: '123',
          content: 'That\'s great to hear!',
          timestamp: DateTime.now().subtract(Duration(days: 2, hours: 21)),
        ),
        ChatMessage(
          senderId: '1',
          content: 'By the way, have you seen the latest movie?',
          timestamp: DateTime.now().subtract(Duration(days: 2, hours: 20)),
        ),
      ],
      isOnline: true,
      bio: 'Hello, I am John Doe!',
      isPro: true,
    ),
    User(
      userId: '2',
      displayName: 'Emma Smith',
      profilePictureUrl: 'https://example.com/emma_smith.jpg',
      status: 'Offline',
      chatHistory: [
        ChatMessage(
          senderId: '123',
          content: 'Hi Emma Smith!',
          timestamp: DateTime.now().subtract(Duration(days: 1, hours: 20)),
        ),
        ChatMessage(
          senderId: '123',
          content: 'Are you free for a call later?',
          timestamp: DateTime.now().subtract(Duration(days: 1, hours: 19)),
        ),
        ChatMessage(
          senderId: '2',
          content: 'I have a meeting scheduled, but how about tomorrow?',
          timestamp: DateTime.now().subtract(Duration(days: 1, hours: 18)),
        ),
        ChatMessage(
          senderId: '123',
          content: 'Sure, let\'s plan for tomorrow. What time works for you?',
          timestamp: DateTime.now().subtract(Duration(days: 1, hours: 17)),
        ),
      ],
      isOnline: false,
      bio: 'Greetings from Emma Smith!',
      isPro: false,
    ),
    User(
      userId: '3',
      displayName: 'Alice Johnson',
      profilePictureUrl: 'https://example.com/alice_johnson.jpg',
      status: 'Online',
      chatHistory: [
        ChatMessage(
          senderId: '123',
          content: 'Hello Alice Johnson!',
          timestamp: DateTime.now().subtract(Duration(hours: 18)),
        ),
        ChatMessage(
          senderId: '3',
          content: 'Hi John! How\'s it going?',
          timestamp: DateTime.now().subtract(Duration(hours: 17)),
        ),
        ChatMessage(
          senderId: '123',
          content: 'Not bad, just working on some projects. How about you?',
          timestamp: DateTime.now().subtract(Duration(hours: 16)),
        ),
        ChatMessage(
          senderId: '3',
          content:
              'I am preparing for a presentation. Its a bit stressful, but exciting!',
          timestamp: DateTime.now().subtract(Duration(hours: 15)),
        ),
        ChatMessage(
          senderId: '123',
          content:
              'I can imagine. You wll do great! If you need any help, let me know.',
          timestamp: DateTime.now().subtract(Duration(hours: 14)),
        ),
      ],
      isOnline: true,
      bio: 'Nice to meet you!',
      isPro: true,
    ),
    User(
      userId: '4',
      displayName: 'Bob Williams',
      profilePictureUrl: 'https://example.com/bob_williams.jpg',
      status: 'Offline',
      chatHistory: [
        ChatMessage(
          senderId: '4',
          content: 'Hi John! How\'s it going?',
          timestamp: DateTime.now().subtract(Duration(hours: 17)),
        ),
      ],
      isOnline: false,
      bio: 'Bob here!',
      isPro: false,
    ),
    User(
      userId: '5',
      displayName: 'Sophia Brown',
      profilePictureUrl: 'https://example.com/sophia_brown.jpg',
      status: 'Online',
      chatHistory: [
        ChatMessage(
          senderId: '123',
          content: 'Hi Sophia!',
          timestamp: DateTime.now().subtract(Duration(hours: 12)),
        ),
        ChatMessage(
          senderId: '5',
          content: 'Hey Alice! Do you have any plans this weekend?',
          timestamp: DateTime.now().subtract(Duration(hours: 11)),
        ),
        ChatMessage(
          senderId: '123',
          content: 'Not yet. Maybe we can plan something together!',
          timestamp: DateTime.now().subtract(Duration(hours: 10)),
        ),
        ChatMessage(
          senderId: '5',
          content: 'That sounds like a great idea! Lets catch up and decide.',
          timestamp: DateTime.now().subtract(Duration(hours: 9)),
        ),
      ],
      isOnline: true,
      bio: 'Sophia, reporting for duty!',
      isPro: true,
    ),
  ];
  static List<User> get users => _userList;

  static User findById(String id) {
    return _userList.firstWhere((user) => user.userId == id);
  }
}
