import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:healthpilot/data/constants.dart';
import 'package:healthpilot/features/chat/chat_models.dart';
import 'package:healthpilot/features/chat/chat_provider.dart';
import 'package:healthpilot/features/chat/chat_screen.dart';
import 'package:healthpilot/features/chat/connection_requests_screen.dart';
import 'package:healthpilot/features/chat/group_chat_screen.dart';
import 'package:healthpilot/features/chat/similar_people_screen.dart';
import 'package:healthpilot/features/chat/widgets/custom_profile_tile.dart';
import 'package:healthpilot/features/community/community_provider.dart';
import 'package:healthpilot/core/auth/auth_state.dart';
import 'package:provider/provider.dart';

class GeneralChatScreen extends StatefulWidget {
  const GeneralChatScreen({super.key, this.showBackButton = false});

  /// When true (e.g. pushed from assessment flow), show an app bar back control.
  /// When false, used inside [HomePageScreen] bottom navigation without a back affordance.
  final bool showBackButton;

  @override
  State<GeneralChatScreen> createState() => _GeneralChatScreenState();
}

class _GeneralChatScreenState extends State<GeneralChatScreen> {
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshCommunity());
  }

  Future<void> _refreshCommunity() async {
    if (!mounted) return;
    final community = context.read<CommunityProvider>();
    await community.refreshConnections();
    if (mounted) {
      final currentUserId = context.read<AuthState>().userId;
      await context
          .read<ChatProvider>()
          .syncAcceptedConnections(community.connections, currentUserId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final provider = context.watch<ChatProvider>();

    final q = _query.toLowerCase();

    final users = q.isEmpty
        ? provider.users
        : provider.users
            .where((u) =>
                u.displayName.toLowerCase().contains(q) ||
                u.chatHistory.any((m) => m.content.toLowerCase().contains(q)))
            .toList();

    final groups = q.isEmpty
        ? provider.groups
        : provider.groups
            .where((g) =>
                g.groupName.toLowerCase().contains(q) ||
                g.groupChatHistory
                    .any((m) => m.content.toLowerCase().contains(q)))
            .toList();

    final conversations = q.isEmpty
        ? provider.conversations
        : provider.conversations
            .where((c) =>
                c.name.toLowerCase().contains(q) ||
                c.lastMessage.toLowerCase().contains(q))
            .toList();

    return SafeArea(
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: widget.showBackButton,
            toolbarHeight: 70,
            elevation: 0,
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: _buildTabBar(),
            centerTitle: true,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _RequestsBadge(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const ConnectionRequestsScreen(),
                    ));
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: _buildFloatingActionButton(),
          body: RefreshIndicator(
            onRefresh: _refreshCommunity,
            child: Column(children: [
            _buildSearchBar(context),
            Expanded(
              child: TabBarView(children: [
                // All chats
                Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Flexible(
                          child: GroupedListView<ChatThread, String>(
                            elements: conversations,
                            groupBy: (c) => c.isPro.toString(),
                            order: GroupedListOrder.DESC,
                            itemBuilder: (context, c) {
                              return CustomChatProfileTile(
                                name: c.name,
                                isPro: c.isPro,
                                unreadMessage: provider.unreadCount(c.id),
                                profilePic: devsImage,
                                chat: c.lastMessage,
                                onPressed: () {
                                  final currentUserId =
                                      context.read<AuthState>().userId;
                                  provider.markRead(c.id);
                                  if (!c.isGroupChat) {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => ChatScreen(
                                            senderId: c.id,
                                            userId: currentUserId),
                                      ),
                                    );
                                  } else {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => GroupChatScreen(
                                            groupId: c.id,
                                            userId: currentUserId),
                                      ),
                                    );
                                  }
                                },
                              );
                            },
                            groupHeaderBuilder: (element) => Container(
                              height: size.height * 0.05,
                            ),
                            itemComparator: (a, b) => a.name.compareTo(b.name),
                            groupComparator: (v1, v2) => v1.compareTo(v2),
                            groupSeparatorBuilder: (value) => SizedBox(
                              height: size.height * 0.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // People chats
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GroupedListView<ChatUser, String>(
                    elements: users,
                    groupBy: (u) => u.isPro.toString(),
                    order: GroupedListOrder.DESC,
                    itemBuilder: (context, u) {
                      return CustomChatProfileTile(
                        name: u.displayName,
                        isPro: u.isPro,
                        unreadMessage: provider.unreadCount(u.userId),
                        profilePic: devsImage,
                        chat: u.chatHistory.isNotEmpty
                            ? u.chatHistory.last.content
                            : '',
                        onPressed: () {
                          final currentUserId =
                              context.read<AuthState>().userId;
                          provider.markRead(u.userId);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  ChatScreen(senderId: u.userId, userId: currentUserId),
                            ),
                          );
                        },
                      );
                    },
                    groupHeaderBuilder: (element) => Container(
                      height: size.height * 0.05,
                    ),
                    itemComparator: (a, b) =>
                        a.displayName.compareTo(b.displayName),
                    groupComparator: (v1, v2) => v1.compareTo(v2),
                    groupSeparatorBuilder: (value) => SizedBox(
                      height: size.height * 0.2,
                    ),
                  ),
                ),

                // Group chats
                Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => _showCreateGroupDialog(context),
                              icon: const Icon(Icons.add, size: 20),
                              label: const Text('Create Group'),
                            ),
                          ),
                        ),
                        Flexible(
                          child: GroupedListView<ChatGroup, String>(
                            elements: groups,
                            groupBy: (g) => g.isPro.toString(),
                            order: GroupedListOrder.DESC,
                            itemBuilder: (context, g) {
                              return CustomChatProfileTile(
                                name: g.groupName,
                                isPro: g.isPro,
                                unreadMessage: provider.unreadCount(g.groupId),
                                profilePic: devsImage,
                                chat: g.groupChatHistory.isNotEmpty
                                    ? g.groupChatHistory.last.content
                                    : '',
                                onPressed: () {
                                  final currentUserId =
                                      context.read<AuthState>().userId;
                                  provider.markRead(g.groupId);
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => GroupChatScreen(
                                          groupId: g.groupId,
                                          userId: currentUserId)));
                                },
                              );
                            },
                            groupHeaderBuilder: (element) => Container(
                              height: size.height * 0.05,
                            ),
                            itemComparator: (a, b) =>
                                a.groupName.compareTo(b.groupName),
                            groupComparator: (v1, v2) => v1.compareTo(v2),
                            groupSeparatorBuilder: (value) => SizedBox(
                              height: size.height * 0.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ]),
            )
          ]),
        ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext ctx) {
    return Padding(
      padding: EdgeInsets.only(left: 29.0.w, right: 23.w, top: 17),
      child: SizedBox(
        height: 44,
        child: TextFormField(
          onChanged: (value) => setState(() => _query = value),
          decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.search,
                size: 20,
              ),
              hintText: 'Search people, groups, or messages',
              hintStyle: const TextStyle(
                color: Color.fromRGBO(193, 193, 193, 1),
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 14,
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.w400,
              ),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                      width: 1, color: Color.fromRGBO(217, 217, 217, 1)))),
        ),
      ),
    );
  }

  Future<void> _showCreateGroupDialog(BuildContext ctx) async {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: ctx,
      builder: (dContext) => AlertDialog(
        title: const Text('Create Group'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Group name',
                hintText: 'Enter group name',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'What is this group about?',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dContext).pop(true),
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final name = nameController.text.trim();
      if (name.isNotEmpty) {
        await context.read<ChatProvider>().createGroup(
              name,
              descController.text.trim(),
            );
      }
    }
    nameController.dispose();
    descController.dispose();
  }

  Widget _buildFloatingActionButton() {
    final cs = Theme.of(context).colorScheme;
    return FloatingActionButton(
      onPressed: () {
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => SimilarPeopleScreen()));
      },
      backgroundColor: cs.primary,
      child: Icon(
        Icons.person_search_outlined,
        size: 30,
        color: cs.onPrimary,
      ),
    );
  }

  TabBar _buildTabBar() {
    final cs = Theme.of(context).colorScheme;
    return TabBar(
        isScrollable: true,
        tabAlignment: TabAlignment.center,
        labelPadding: const EdgeInsets.symmetric(horizontal: 14),
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: cs.primary,
        unselectedLabelColor: cs.onSurface.withValues(alpha: 0.7),
        unselectedLabelStyle: TextStyle(
          color: cs.onSurface.withValues(alpha: 0.7),
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 14,
          fontStyle: FontStyle.normal,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.165,
        ),
        labelStyle: TextStyle(
          color: cs.primary,
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 14,
          fontStyle: FontStyle.normal,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.165,
        ),
        indicatorColor: cs.primary,
        tabs: const [
          Tab(
            text: 'All',
          ),
          Tab(
            text: 'People',
          ),
          Tab(
            text: 'Groups',
          ),
        ]);
  }
}

class _RequestsBadge extends StatelessWidget {
  final VoidCallback onTap;
  const _RequestsBadge({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final count = context.watch<CommunityProvider>().incomingRequests.length;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 40,
        width: 40,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Center(
              child: Icon(
                Icons.person_add_alt_1_outlined,
                size: 24,
                color: cs.onSurface,
              ),
            ),
            if (count > 0)
              Positioned(
                right: 0,
                top: 2,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    count > 9 ? '9+' : '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
