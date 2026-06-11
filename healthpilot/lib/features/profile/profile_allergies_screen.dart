import 'package:flutter/material.dart';
import 'package:healthpilot/features/health_assessment/allergy_suggestion_catalog.dart';
import 'package:healthpilot/features/profile/profile_provider.dart';
import 'package:provider/provider.dart';

List<String> parseAllergiesField(String? raw) {
  if (raw == null || raw.trim().isEmpty) return [];
  return raw
      .split(',')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();
}

/// Profile allergies editor — PATCHes `/api/v1/auth/me/` with `allergies` only.
class ProfileAllergiesScreen extends StatefulWidget {
  const ProfileAllergiesScreen({super.key});

  @override
  State<ProfileAllergiesScreen> createState() => _ProfileAllergiesScreenState();
}

class _ProfileAllergiesScreenState extends State<ProfileAllergiesScreen> {
  final _searchController = TextEditingController();
  late List<String> _selected;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileProvider>().profile;
    _selected = parseAllergiesField(profile.allergies);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _filteredSuggestions {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return [];
    return AllergySuggestionCatalog.names
        .where((name) => name.toLowerCase().contains(q))
        .toList();
  }

  void _toggle(String allergy) {
    setState(() {
      if (_selected.contains(allergy)) {
        _selected.remove(allergy);
      } else {
        _selected.add(allergy);
      }
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await context.read<ProfileProvider>().saveAllergies(_selected);
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save allergies. Try again.')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final suggestions = _filteredSuggestions;

    return Scaffold(
      appBar: AppBar(title: const Text('Allergies')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add any known allergies',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search allergies',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  if (suggestions.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Suggestions',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    ...suggestions.map(
                      (allergy) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(allergy),
                        trailing: Icon(
                          _selected.contains(allergy)
                              ? Icons.check_circle
                              : Icons.add_circle_outline,
                          color: cs.primary,
                        ),
                        onTap: () => _toggle(allergy),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    'Selected',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  if (_selected.isEmpty)
                    Text(
                      'No allergies added yet.',
                      style: TextStyle(color: cs.onSurfaceVariant),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _selected
                          .map(
                            (allergy) => InputChip(
                              label: Text(allergy),
                              onDeleted: () => _toggle(allergy),
                            ),
                          )
                          .toList(),
                    ),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
