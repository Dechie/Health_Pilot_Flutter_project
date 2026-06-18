import 'dart:async';

import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:healthpilot/data/constants.dart';
import 'package:healthpilot/features/chat/audio_call_screen.dart';
import 'package:healthpilot/features/chat/chat_models.dart';
import 'package:healthpilot/features/chat/chat_provider.dart';
import 'package:healthpilot/features/chat/widgets/chat_markdown_body.dart';
import 'package:healthpilot/features/chat/user_detail_screen.dart';
import 'package:healthpilot/features/community/community_models.dart';
import 'package:healthpilot/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  final String senderId;
  final String userId;

  const ChatScreen({super.key, required this.senderId, required this.userId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<ChatProvider>();
      provider.markRead(widget.senderId);
      provider.fetchPrivateMessages(widget.senderId);
    });
    _pollTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (!mounted) return;
      final provider = context.read<ChatProvider>();
      provider.markRead(widget.senderId);
      provider.fetchPrivateMessages(widget.senderId);
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final provider = context.watch<ChatProvider>();
    final user = provider.findUser(widget.senderId);
    if (user == null) {
      return Scaffold(
        body: Center(
          child: Text(
            'User not found',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size(size.width, size.height * 0.15),
          child: CustomeAppBarForChatScreen(
            title: user.displayName,
            subTitle: user.chatHistory.isNotEmpty
                ? 'Last seen ${DateFormat.yMMMMd().format(user.chatHistory.last.timestamp)}'
                : '',
            profileImageUrl: devsImage,
            callNow: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => AudioCallScreen(id: widget.senderId)));
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
              if (provider.isLoadingThread(widget.senderId))
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (user.chatHistory.isEmpty)
                const EmptyChat()
              else
                ChatList(
                    senderId: widget.senderId,
                    userId: widget.userId,
                    chatList: user.chatHistory),
              SendMessage(
                attach: () {
                  debugPrint('add file');
                },
                sendMessage: (message) {
                  context
                      .read<ChatProvider>()
                      .sendDirect(widget.senderId, widget.userId, message);
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
                          peer: SuggestedPeer(
                            id: int.parse(senderId),
                            fullName: title,
                            age: 0,
                            score: 0,
                            reason: '',
                          ),
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
            Expanded(
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
  final List<DirectMessage> chatList;
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
          final isDark = Theme.of(context).brightness == Brightness.dark;

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
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              decoration: bubbleDecoration,
              child: isIncoming
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Flexible(
                          child: ChatMarkdownBody(
                            rawText: chat.content,
                            textColor: cs.onSurface,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          DateFormat('hh:mm a').format(chat.timestamp),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 8,
                            fontWeight: FontWeight.w400,
                            color: cs.onSurface.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ChatMarkdownBody(
                            rawText: chat.content,
                            textColor: isDark ? cs.onPrimary : cs.onSurface,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            chat.sendFailed
                                ? 'Failed'
                                : chat.isDelivered
                                    ? 'Sent'
                                    : 'Sending…',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 8,
                              fontWeight: FontWeight.w400,
                              color: chat.sendFailed
                                  ? cs.error
                                  : (isDark ? cs.onPrimary : cs.onSurface)
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
  final void Function(String) sendMessage;
  final VoidCallback attach;
  const SendMessage(
      {super.key, required this.sendMessage, required this.attach});

  @override
  State<SendMessage> createState() => _SendMessageState();
}

class _SendMessageState extends State<SendMessage> {
  final _controller = TextEditingController();
  String message = '';

  void _send() {
    final trimmed = message.trim();
    if (trimmed.isEmpty) return;
    widget.sendMessage(trimmed);
    _controller.clear();
    setState(() => message = '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
          child: Icon(
            Icons.add_outlined,
            color: cs.onSurface,
          ),
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(
                vertical: size.height * 0.01, horizontal: size.width * 0.04),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: cs.outline, width: 1),
                color: cs.surfaceContainerHighest),
            height: size.height * 0.06,
            child: TextField(
              controller: _controller,
              onChanged: (value) {
                setState(() {
                  message = value;
                });
              },
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
        ),
        InkWell(
          onTap: _send,
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
