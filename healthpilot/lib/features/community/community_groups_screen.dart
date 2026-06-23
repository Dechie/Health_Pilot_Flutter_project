import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:healthpilot/core/auth/auth_state.dart';
import 'package:healthpilot/features/chat/chat_provider.dart';
import 'package:healthpilot/features/chat/group_chat_screen.dart';
import 'package:healthpilot/features/community/community_models.dart';
import 'package:healthpilot/features/community/community_provider.dart';

/// Browse, create, join and leave community support groups
/// (`/community/groups/`). Standalone screen; the list itself is
/// [CommunityGroupsBody] so the Community hub can embed it.
class CommunityGroupsScreen extends StatelessWidget {
  const CommunityGroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Community Groups')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showCreateCommunityGroupDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('New group'),
      ),
      body: const SafeArea(child: CommunityGroupsBody()),
    );
  }
}

/// The groups list (no Scaffold) — reusable inside the Community hub.
class CommunityGroupsBody extends StatelessWidget {
  const CommunityGroupsBody({super.key, this.padding});

  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final groups = context.watch<CommunityProvider>().groups;
    return RefreshIndicator(
      onRefresh: () => context.read<CommunityProvider>().refreshGroups(),
      child: groups.isEmpty
          ? ListView(
              children: const [
                SizedBox(height: 120),
                Center(child: Text('No groups yet. Create the first one.')),
              ],
            )
          : ListView.separated(
              padding: padding ?? const EdgeInsets.fromLTRB(16, 12, 16, 96),
              itemCount: groups.length,
              itemBuilder: (context, i) => CommunityGroupCard(group: groups[i]),
              separatorBuilder: (_, __) => const SizedBox(height: 10),
            ),
    );
  }
}

/// Shows the "new community group" dialog (shared by the standalone screen and
/// the Community hub).
Future<void> showCreateCommunityGroupDialog(BuildContext context) async {
    final nameCtrl = TextEditingController();
    final slugCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    var submitting = false;

    String slugify(String s) => s
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'(^-+)|(-+$)'), '');

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: const Text('New community group'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Name'),
                  onChanged: (v) {
                    if (slugCtrl.text.isEmpty ||
                        slugCtrl.text == slugify(nameCtrl.text)) {
                      slugCtrl.text = slugify(v);
                    }
                  },
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                TextFormField(
                  controller: slugCtrl,
                  decoration: const InputDecoration(labelText: 'Slug'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                TextFormField(
                  controller: descCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Description (optional)'),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: submitting ? null : () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: submitting
                  ? null
                  : () async {
                      if (!(formKey.currentState?.validate() ?? false)) return;
                      setLocal(() => submitting = true);
                      try {
                        await context.read<CommunityProvider>().createGroup(
                              name: nameCtrl.text.trim(),
                              slug: slugify(slugCtrl.text),
                              description: descCtrl.text.trim(),
                            );
                        if (ctx.mounted) Navigator.of(ctx).pop();
                      } catch (_) {
                        setLocal(() => submitting = false);
                        if (ctx.mounted) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Could not create group (slug may be taken).')),
                          );
                        }
                      }
                    },
              child: Text(submitting ? 'Creating…' : 'Create'),
            ),
          ],
        ),
      ),
    );
  }

class CommunityGroupCard extends StatelessWidget {
  const CommunityGroupCard({super.key, required this.group});
  final CommunityGroup group;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(group.name,
                      style: Theme.of(context).textTheme.titleSmall),
                ),
                if (group.isMember)
                  OutlinedButton(
                    onPressed: () =>
                        context.read<CommunityProvider>().leaveGroup(group.id),
                    child: const Text('Leave'),
                  )
                else
                  FilledButton(
                    onPressed: () =>
                        context.read<CommunityProvider>().joinGroup(group.id),
                    child: const Text('Join'),
                  ),
              ],
            ),
            if (group.description != null && group.description!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(group.description!,
                  style: Theme.of(context).textTheme.bodyMedium),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.group_outlined, size: 16, color: cs.primary),
                const SizedBox(width: 4),
                Text('${group.memberCount} members',
                    style: Theme.of(context).textTheme.bodySmall),
                if (group.conditionTags.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      group.conditionTags.join(', '),
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: cs.onSurfaceVariant),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
            // Opt-in chat: shown only when the backend has linked a GroupChat.
            // Joining the community group does NOT auto-join chat — the user
            // chooses to open the conversation here.
            if (group.chatGroupId != null) ...[
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => _openChat(context),
                  icon: const Icon(Icons.forum_outlined, size: 18),
                  label: const Text('Open group chat'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Opt-in entry to the linked GroupChat: joins the chat room (idempotent),
  /// then opens it. Separate from community membership by design.
  Future<void> _openChat(BuildContext context) async {
    final chatGroupId = group.chatGroupId;
    if (chatGroupId == null) return;
    final chat = context.read<ChatProvider>();
    final userId = context.read<AuthState>().userId;
    final navigator = Navigator.of(context);
    try {
      await chat.joinGroup(chatGroupId);
    } catch (_) {/* may already be a member; opening still works */}
    if (!context.mounted) return;
    navigator.push(MaterialPageRoute<void>(
      builder: (_) => GroupChatScreen(groupId: chatGroupId, userId: userId),
    ));
  }
}
