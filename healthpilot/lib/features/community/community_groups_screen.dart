import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:healthpilot/features/community/community_models.dart';
import 'package:healthpilot/features/community/community_provider.dart';

/// Browse, create, join and leave community support groups
/// (`/community/groups/`).
class CommunityGroupsScreen extends StatelessWidget {
  const CommunityGroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommunityProvider>();
    final groups = provider.groups;

    return Scaffold(
      appBar: AppBar(title: const Text('Community Groups')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('New group'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<CommunityProvider>().refreshGroups(),
          child: groups.isEmpty
              ? ListView(
                  children: const [
                    SizedBox(height: 120),
                    Center(child: Text('No groups yet. Create the first one.')),
                  ],
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                  itemCount: groups.length,
                  itemBuilder: (context, i) =>
                      _GroupCard(group: groups[i]),
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                ),
        ),
      ),
    );
  }

  Future<void> _showCreateDialog(BuildContext context) async {
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
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.group});
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
          ],
        ),
      ),
    );
  }
}
