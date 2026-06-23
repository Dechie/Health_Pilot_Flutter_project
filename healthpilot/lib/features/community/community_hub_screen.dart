import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:healthpilot/core/auth/auth_state.dart';
import 'package:healthpilot/features/chat/chat_provider.dart';
import 'package:healthpilot/features/chat/chat_screen.dart';
import 'package:healthpilot/features/chat/connection_requests_screen.dart';
import 'package:healthpilot/features/chat/similar_people_screen.dart';
import 'package:healthpilot/features/community/community_groups_screen.dart';
import 'package:healthpilot/features/community/community_models.dart';
import 'package:healthpilot/features/community/community_provider.dart';

/// Dedicated Community hub: the front door for discovery & the social graph
/// (peers, groups, requests). Distinct from the Chat tab, which owns the
/// conversations these flows feed into.
///
/// Reached from the assessment result ("Go to Community"), the chat hub, and a
/// home shortcut. Pass [initialTab] (0 = For You, 1 = People, 2 = Groups).
class CommunityHubScreen extends StatefulWidget {
  const CommunityHubScreen({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  State<CommunityHubScreen> createState() => _CommunityHubScreenState();
}

class _CommunityHubScreenState extends State<CommunityHubScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CommunityProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: widget.initialTab.clamp(0, 2),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Community'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'For You'),
              Tab(text: 'People'),
              Tab(text: 'Groups'),
            ],
          ),
        ),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () => context.read<CommunityProvider>().load(),
            child: const TabBarView(
              children: [
                _ForYouTab(),
                _PeopleTab(),
                _GroupsTab(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── For You ──────────────────────────────────────────────────────────────────

class _ForYouTab extends StatelessWidget {
  const _ForYouTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommunityProvider>();
    if (provider.status == CommunityStatus.loading &&
        provider.suggestedPeers.isEmpty &&
        provider.groups.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    final peers = provider.suggestedPeers.take(3).toList();
    final groups = provider.groups.take(3).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        if (provider.incomingRequests.isNotEmpty)
          _RequestsBanner(count: provider.incomingRequests.length),
        Text('Find your people',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          'Connect with people facing similar things and join support groups '
          'for what matters to you.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        _SectionHeader(
          title: 'People like you',
          onSeeAll: () => DefaultTabController.of(context).animateTo(1),
        ),
        if (peers.isEmpty)
          const _EmptyLine('No suggestions yet.')
        else
          ...peers.map((p) => DiscoverablePeerCard(peer: p)),
        const SizedBox(height: 16),
        _SectionHeader(
          title: 'Support groups for you',
          onSeeAll: () => DefaultTabController.of(context).animateTo(2),
        ),
        if (groups.isEmpty)
          const _EmptyLine('No groups yet.')
        else
          ...groups.map((g) => CommunityGroupCard(group: g)),
      ],
    );
  }
}

// ── People ───────────────────────────────────────────────────────────────────

class _PeopleTab extends StatelessWidget {
  const _PeopleTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommunityProvider>();
    if (provider.status == CommunityStatus.loading &&
        provider.suggestedPeers.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    final connections =
        provider.connections.where((c) => c.status == 'accepted').toList();
    final peers = provider.suggestedPeers;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        if (provider.incomingRequests.isNotEmpty)
          _RequestsBanner(count: provider.incomingRequests.length),
        if (connections.isNotEmpty) ...[
          Text('Your connections',
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          ...connections.map((c) => _ConnectionTile(connection: c)),
          const SizedBox(height: 16),
        ],
        Text('Discover', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        if (peers.isEmpty)
          const _EmptyLine('No suggestions right now.')
        else
          ...peers.map((p) => DiscoverablePeerCard(peer: p)),
      ],
    );
  }
}

class _ConnectionTile extends StatelessWidget {
  const _ConnectionTile({required this.connection});
  final ConnectionRequest connection;

  Future<void> _message(BuildContext context) async {
    final chat = context.read<ChatProvider>();
    final currentUserId = context.read<AuthState>().userId;
    final navigator = Navigator.of(context);
    final peerId = connection.peerIdOf(currentUserId);
    final peerName = connection.peerNameOf(currentUserId);
    try {
      final created = await chat.startPrivateChat(peerId);
      chat.addConnection(peerId, peerName, created.id);
    } catch (_) {/* fall through to open the thread anyway */}
    navigator.push(MaterialPageRoute<void>(
      builder: (_) =>
          ChatScreen(senderId: peerId.toString(), userId: currentUserId),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.read<AuthState>().userId;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.person_outline)),
        title: Text(connection.peerNameOf(currentUserId)),
        trailing: FilledButton.tonalIcon(
          onPressed: () => _message(context),
          icon: const Icon(Icons.chat_bubble_outline, size: 18),
          label: const Text('Message'),
        ),
      ),
    );
  }
}

// ── Groups ───────────────────────────────────────────────────────────────────

class _GroupsTab extends StatelessWidget {
  const _GroupsTab();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => showCreateCommunityGroupDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('New group'),
            ),
          ),
        ),
        const Expanded(
          child: CommunityGroupsBody(
            padding: EdgeInsets.fromLTRB(16, 4, 16, 24),
          ),
        ),
      ],
    );
  }
}

// ── Shared bits ──────────────────────────────────────────────────────────────

class _RequestsBanner extends StatelessWidget {
  const _RequestsBanner({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      color: cs.primaryContainer.withValues(alpha: 0.5),
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: const Icon(Icons.person_add_alt_1_outlined),
        title: Text('$count connection request${count == 1 ? '' : 's'}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const ConnectionRequestsScreen(),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.onSeeAll});
  final String title;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleSmall),
        ),
        TextButton(onPressed: onSeeAll, child: const Text('See all')),
      ],
    );
  }
}

class _EmptyLine extends StatelessWidget {
  const _EmptyLine(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(text, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}
