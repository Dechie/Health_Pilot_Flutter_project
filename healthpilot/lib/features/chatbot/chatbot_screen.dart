import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:healthpilot/features/chatbot/ai_assistant_provider.dart';
import 'package:healthpilot/features/chatbot/chatbot_models.dart';
import 'package:healthpilot/features/chatbot/widgets/chat_bubble.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';

const List<String> _kSuggestionLabels = [
  'Blood pressure basics',
  'Healthy sleep habits',
  'Understanding fevers',
  'Staying hydrated',
];

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  static String _formatTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final p = dt.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $p';
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    _textController.clear();
    _scrollToBottom();
    await context.read<AiAssistantProvider>().send(text);
    _scrollToBottom();
  }

  void _sendFromField() => _sendMessage(_textController.text);

  Future<void> _confirmClearChat() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Clear chat?',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
        content: Text(
          'This removes the messages in this session and shows the starter suggestions again.',
          style: GoogleFonts.plusJakartaSans(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      await context.read<AiAssistantProvider>().clear();
      _scrollToBottom();
    }
  }

  void _showHelpAndSafety() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Help & safety',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
        content: SingleChildScrollView(
          child: Text(
            'HealthBot provides general information only. It can make mistakes. '
            'Do not use it for emergencies—call your local emergency number. '
            'For diagnosis, treatment, or medication decisions, always follow '
            'advice from a qualified health professional.',
            style: GoogleFonts.plusJakartaSans(fontSize: 14, height: 1.35),
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final provider = context.watch<AiAssistantProvider>();
    final messages = provider.messages;
    final isTyping = provider.isTyping;
    final showSuggestions = !messages.any((m) => m.fromUser);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            // ── header ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: cs.primary.withValues(alpha: 0.25),
                      ),
                      child: Icon(Icons.arrow_back, color: cs.onSurface),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 9, left: 16),
                    height: 46,
                    width: 46,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: cs.primary,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 42,
                          width: 42,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: cs.primary,
                            border:
                                Border.all(color: cs.onPrimary, width: 2),
                          ),
                          child:
                              Icon(LineIcons.robot, color: cs.onPrimary),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'HealthBot',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                          ),
                        ),
                        Text(
                          'Online',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    tooltip: 'More',
                    onSelected: (value) {
                      if (value == 'clear') {
                        _confirmClearChat();
                      } else if (value == 'help') {
                        _showHelpAndSafety();
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'help',
                        child: Text('Help & safety',
                            style: GoogleFonts.plusJakartaSans()),
                      ),
                      const PopupMenuDivider(),
                      PopupMenuItem(
                        value: 'clear',
                        child: Text('Clear chat',
                            style: GoogleFonts.plusJakartaSans(
                                color: Colors.red.shade800)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // ── message list ─────────────────────────────────────────────────
            Expanded(
              child: ListView(
                controller: _scrollController,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                children: [
                  for (final msg in messages) _bubbleForMessage(msg),
                  if (isTyping) _typingRow(),
                ],
              ),
            ),
            // ── suggestion chips ─────────────────────────────────────────────
            if (showSuggestions)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Try asking',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 42,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _kSuggestionLabels.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: 8),
                        itemBuilder: (context, i) {
                          final label = _kSuggestionLabels[i];
                          return ActionChip(
                            label: Text(label,
                                style:
                                    GoogleFonts.plusJakartaSans(fontSize: 12)),
                            onPressed: () => _sendMessage(label),
                            visualDensity: VisualDensity.compact,
                            side: BorderSide(
                                color: cs.primary.withValues(alpha: 0.5)),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            // ── input bar ────────────────────────────────────────────────────
            Container(
              margin:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(28),
                border:
                    Border.all(color: cs.outline.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendFromField(),
                      style: GoogleFonts.plusJakartaSans(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Ask a health question…',
                        hintStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: cs.onSurfaceVariant,
                        ),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    onPressed: _sendFromField,
                    icon: Icon(Icons.send_rounded, color: cs.primary),
                    tooltip: 'Send',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bubbleForMessage(ChatMessage msg) {
    final bubble = ChatBubble(
      body: msg.body,
      time: _formatTime(msg.sentAt),
      nipPosition:
          msg.fromUser ? BubbleNip.rightBottom : BubbleNip.leftBottom,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment:
            msg.fromUser ? Alignment.centerRight : Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: 0.92,
          alignment:
              msg.fromUser ? Alignment.centerRight : Alignment.centerLeft,
          child: bubble,
        ),
      ),
    );
  }

  Widget _typingRow() {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Row(
        children: [
          Icon(LineIcons.robot, size: 18, color: cs.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(
            'HealthBot is typing…',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
