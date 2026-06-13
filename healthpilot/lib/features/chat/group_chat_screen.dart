import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:healthpilot/data/constants.dart';
import 'package:healthpilot/features/chat/chat_models.dart';
import 'package:healthpilot/features/chat/chat_provider.dart';
import 'package:healthpilot/features/chat/chat_screen.dart';
import 'package:healthpilot/features/chat/widgets/chat_markdown_body.dart';
import 'package:healthpilot/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class GroupChatScreen extends StatefulWidget {
  final String groupId;
  final String userId;

  const GroupChatScreen(
      {super.key, required this.groupId, required this.userId});

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  void _onSend(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    context
        .read<ChatProvider>()
        .sendGroup(widget.groupId, widget.userId, trimmed);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final provider = context.watch<ChatProvider>();
    final group = provider.findGroup(widget.groupId);
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size(size.width, size.height * 0.15),
          child: _GroupAppBar(
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
              group.groupChatHistory.isEmpty
                  ? const EmptyChat()
                  : _GroupChatList(
                      senderId: widget.groupId,
                      userId: widget.userId,
                      chatList: group.groupChatHistory),
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

class _GroupAppBar extends StatelessWidget {
  final String title;
  final String subTitle;
  final String profileImageUrl;
  final bool isMuted;
  final VoidCallback more;
  const _GroupAppBar(
      {required this.title,
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

class _GroupChatList extends StatelessWidget {
  final List<DirectMessage> chatList;
  final String senderId;
  final String userId;

  const _GroupChatList({
    required this.chatList,
    required this.senderId,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ChatProvider>();
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

          String senderName = '';
          if (isIncoming) {
            try {
              senderName = provider.findUser(chat.senderId).displayName;
            } catch (_) {
              senderName = chat.senderId;
            }
          }

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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: isIncoming
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.end,
                children: [
                  if (isIncoming)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        senderName,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                  isIncoming
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
                            if (chat.isDelivered) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Sent',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w400,
                                  color: (isDark ? cs.onPrimary : cs.onSurface)
                                      .withValues(alpha: 0.8),
                                ),
                              ),
                            ],
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

/// Scrolls its text like a news ticker when the content overflows its box.
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
    await Future<void>.delayed(const Duration(seconds: 2));
    while (mounted) {
      if (!_controller.hasClients) return;
      final max = _controller.position.maxScrollExtent;
      if (max <= 0) return;
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
