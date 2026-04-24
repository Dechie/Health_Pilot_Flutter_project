import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:healthpilot/features/chatbot/widgets/chat_bubble.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';

class _ChatTurn {
  const _ChatTurn({
    required this.fromUser,
    required this.body,
    required this.time,
  });

  final bool fromUser;
  final String body;
  final String time;
}

/// Suggested prompts (starter experience); not medical advice.
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
  bool _isBotTyping = false;

  late List<_ChatTurn> _turns = [
    _ChatTurn(
      fromUser: false,
      body:
          'Hey there 👋 I am here to answer general health questions. Ask in your own words or tap a suggestion below. This is not a substitute for professional care.',
      time: _formatNow(),
    ),
  ];

  static String _formatNow() {
    final t = TimeOfDay.now();
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final p = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $p';
  }

  bool get _showSuggestionChips => !_turns.any((t) => t.fromUser);

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _simulateBotReply(String userText) async {
    setState(() => _isBotTyping = true);
    _scrollToBottom();
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) {
      return;
    }
    setState(() {
      _isBotTyping = false;
      _turns = [
        ..._turns,
        _ChatTurn(
          fromUser: false,
          body:
              'Thanks for your message. I cannot diagnose or prescribe. For “$userText”, a reliable next step is to review trusted sources such as your national health service or speak with a clinician for personal advice.',
          time: _formatNow(),
        ),
      ];
    });
    _scrollToBottom();
  }

  void _appendUserMessage(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return;
    }
    setState(() {
      _turns = [
        ..._turns,
        _ChatTurn(fromUser: true, body: trimmed, time: _formatNow()),
      ];
    });
    _textController.clear();
    _scrollToBottom();
    _simulateBotReply(trimmed);
  }

  void _onSuggestionTapped(String label) {
    _appendUserMessage(label);
  }

  void _sendFromField() {
    _appendUserMessage(_textController.text);
  }

  Future<void> _confirmClearChat() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Clear chat?',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
        ),
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
      setState(() {
        _isBotTyping = false;
        _turns = [
          _ChatTurn(
            fromUser: false,
            body:
                'Hey there 👋 I am here to answer general health questions. Ask in your own words or tap a suggestion below. This is not a substitute for professional care.',
            time: _formatNow(),
          ),
        ];
      });
      _scrollToBottom();
    }
  }

  void _showHelpAndSafety() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Help & safety',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
        ),
        content: SingleChildScrollView(
          child: Text(
            'HealthBot provides general information only. It can make mistakes. '
            'Do not use it for emergencies—call your local emergency number. '
            'For diagnosis, treatment, or medication decisions, always follow advice from a qualified health professional.',
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
    final primary = const Color.fromARGB(255, 110, 182, 255);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      bottomSheet: Container(
        height: 48,
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendFromField(),
                decoration: const InputDecoration(
                  hintText: 'Message',
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Send',
              onPressed: _sendFromField,
              icon: Icon(
                Icons.send,
                color: primary,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Column(
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.fromARGB(63, 110, 182, 255),
                      ),
                      child: const Icon(Icons.arrow_back),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 9, left: 16),
                    height: 46,
                    width: 46,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.fromARGB(255, 110, 182, 255),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 42,
                          width: 42,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color.fromARGB(255, 110, 182, 255),
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            LineIcons.robot,
                            color: Colors.white,
                          ),
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
                          ),
                        ),
                        Text(
                          'Online',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: const Color.fromRGBO(42, 42, 42, 0.5),
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
                        child: Text(
                          'Help & safety',
                          style: GoogleFonts.plusJakartaSans(),
                        ),
                      ),
                      const PopupMenuDivider(),
                      PopupMenuItem(
                        value: 'clear',
                        child: Text(
                          'Clear chat',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.red.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Expanded(
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                  children: [
                    for (final t in _turns) _bubbleForTurn(t),
                    if (_isBotTyping) _typingRow(),
                  ],
                ),
              ),
              if (_showSuggestionChips) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Try asking',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color.fromRGBO(42, 42, 42, 0.65),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 42,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _kSuggestionLabels.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      final label = _kSuggestionLabels[i];
                      return ActionChip(
                        label: Text(
                          label,
                          style: GoogleFonts.plusJakartaSans(fontSize: 12),
                        ),
                        onPressed: () => _onSuggestionTapped(label),
                        visualDensity: VisualDensity.compact,
                        side: BorderSide(color: primary.withValues(alpha: 0.5)),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 64),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bubbleForTurn(_ChatTurn t) {
    final bubble = ChatBubble(
      body: t.body,
      time: t.time,
      nipPosition:
          t.fromUser ? BubbleNip.rightBottom : BubbleNip.leftBottom,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: t.fromUser ? Alignment.centerRight : Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: 0.92,
          alignment:
              t.fromUser ? Alignment.centerRight : Alignment.centerLeft,
          child: bubble,
        ),
      ),
    );
  }

  Widget _typingRow() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Row(
        children: [
          Icon(LineIcons.robot, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text(
            'HealthBot is typing…',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
