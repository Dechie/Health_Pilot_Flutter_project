import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:healthpilot/data/constants.dart';
import 'package:healthpilot/theme/app_theme.dart';
import 'package:intl/intl.dart';

import 'chat_screen.dart';

class GroupChatScreen extends StatefulWidget {
  final String groupId;
  final String userId;

  const GroupChatScreen({super.key, required this.groupId, required this.userId});

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  late final List<ChatMessage> _messages;

  @override
  void initState() {
    super.initState();
    _messages = List.of(GroupChats.findGroupById(widget.groupId).groupChatHistory);
  }

  void _onSend(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    setState(() {
      _messages.add(ChatMessage(
        senderId: widget.userId,
        content: trimmed,
        timestamp: DateTime.now(),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final group = GroupChats.findGroupById(widget.groupId);
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
      body: SafeArea(
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              _messages.isEmpty
                  ? const EmptyChat()
                  : ChatList(
                      senderId: widget.groupId,
                      userId: widget.userId,
                      chatList: _messages),
              SendMessage(
                attach: () {},
                sendMessage: _onSend,
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
            Container(
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
            SizedBox(
              width: size.width * 0.015,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: _TickerText(
                          text: title,
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                      if (isMuted) ...[
                        const SizedBox(width: 6),
                        SvgPicture.asset(
                          muteIcon,
                          width: 18,
                          height: 18,
                          colorFilter:
                              ColorFilter.mode(cs.onSurface, BlendMode.srcIn),
                        ),
                      ]
                    ],
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                      isIncoming ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                  children: [
                    if (isIncoming)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          Users.findById(chat.senderId).displayName,
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight: FontWeight.w500,
                            fontSize: 11,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Text(
                            chat.content,
                            style: GoogleFonts.plusJakartaSans(
                              color: isIncoming ? cs.onSurface : cs.onPrimary,
                              fontSize: 12,
                              fontWeight:
                                  isIncoming ? FontWeight.w400 : FontWeight.w500,
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
  final _controller = TextEditingController();
  String _message = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    if (_message.trim().isEmpty) return;
    widget.sendMessage(_message.trim());
    _controller.clear();
    setState(() => _message = '');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cs = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        InkWell(
          onTap: widget.attach,
          child: Icon(Icons.add_outlined, color: cs.onSurface),
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
            controller: _controller,
            onChanged: (value) => setState(() => _message = value),
            onSubmitted: (_) => _send(),
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
          onTap: _send,
          child: Icon(
            _message.trim().isEmpty
                ? Icons.keyboard_voice_outlined
                : Icons.send_outlined,
            color: cs.onSurface,
          ),
        ),
      ],
    );
  }
}

/// Scrolls its text like a news ticker when the content overflows its box.
/// Stays static when the text fits.
class _TickerText extends StatefulWidget {
  final String text;
  final TextStyle style;

  const _TickerText({required this.text, required this.style});

  @override
  State<_TickerText> createState() => _TickerTextState();
}

class _TickerTextState extends State<_TickerText> {
  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loop());
  }

  @override
  void didUpdateWidget(_TickerText old) {
    super.didUpdateWidget(old);
    if (old.text != widget.text) {
      _controller.jumpTo(0);
      _loop();
    }
  }

  Future<void> _loop() async {
    // Wait for first scroll metrics to settle.
    await Future<void>.delayed(const Duration(seconds: 2));
    while (mounted) {
      if (!_controller.hasClients) return;
      final max = _controller.position.maxScrollExtent;
      if (max <= 0) return; // text fits — nothing to do
      await _controller.animateTo(
        max,
        duration: Duration(milliseconds: (max * 30).round().clamp(1200, 9000)),
        curve: Curves.linear,
      );
      if (!mounted) return;
      await Future<void>.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      _controller.jumpTo(0);
      await Future<void>.delayed(const Duration(seconds: 2));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _controller,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      child: Text(widget.text, style: widget.style, maxLines: 1),
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
