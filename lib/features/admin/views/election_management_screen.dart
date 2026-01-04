import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';
import '../../election/viewmodels/election_management_viewmodel.dart';
import 'add_election_screen.dart';

class ElectionManagementScreen extends StatelessWidget {
  const ElectionManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ElectionManagementViewModel(),
      child: const _ElectionManagementContent(),
    );
  }
}

class _ElectionManagementContent extends StatelessWidget {
  const _ElectionManagementContent();

  void _showEditDialog(
      BuildContext context, String title, String currentValue, Function(String) onSave) {
    final controller = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.edit, color: Colors.blueAccent),
            const SizedBox(width: 8),
            Text('Edit $title'),
          ],
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(labelText: title),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              onSave(controller.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String message, Function() onDelete) async {
    final vm = Provider.of<ElectionManagementViewModel>(context, listen: false);
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text("Confirm Delete"),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            icon: const Icon(Icons.delete),
            label: const Text("Delete"),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        await onDelete();
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Item deleted")),
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Failed to delete: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vm = Provider.of<ElectionManagementViewModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text("🛠️ Manage Elections"),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: "Add Election",
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddElectionScreen()),
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: vm.elections.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(
                child: Text("No elections found.", style: TextStyle(fontSize: 16, color: Colors.grey)));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            itemCount: docs.length,
            itemBuilder: (_, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final title = data['title'] ?? 'Untitled';
              final status = data['status'] ?? 'Unknown';
              final positions = List<Map<String, dynamic>>.from(data['positions'] ?? []);

              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                color: theme.cardColor,
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: const Icon(Icons.how_to_vote, color: AppColors.primary),
                  ),
                  title: Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  subtitle: Text("Status: $status", style: theme.textTheme.bodySmall),
                  trailing: Wrap(
                    spacing: 6,
                    children: [
                      Tooltip(
                        message: "Edit Election",
                        child: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blueAccent),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddElectionScreen(
                                electionId: doc.id,
                                initialData: data,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Tooltip(
                        message: "Delete Election",
                        child: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDelete(
                            context,
                            "Are you sure you want to delete this election?",
                                () => vm.deleteElection(doc.id),
                          ),
                        ),
                      ),
                    ],
                  ),
                  children: [
                    ...positions.asMap().entries.map((entry) {
                      final posIndex = entry.key;
                      final position = entry.value;
                      final positionName = position['name'] ?? '';
                      final candidates = List<String>.from(position['candidates'] ?? []);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.group, color: AppColors.primary),
                            title: Text(positionName),
                            trailing: Wrap(
                              spacing: 4,
                              children: [
                                Tooltip(
                                  message: "Edit Position",
                                  child: IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                    onPressed: () => _showEditDialog(
                                      context,
                                      "Position Name",
                                      positionName,
                                          (newName) => vm.updatePositionName(doc.id, positions, posIndex, newName),
                                    ),
                                  ),
                                ),
                                Tooltip(
                                  message: "Delete Position",
                                  child: IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _confirmDelete(
                                      context,
                                      "Are you sure you want to delete this position?",
                                          () => vm.deletePosition(doc.id, positions, posIndex),
                                    ),
                                  ),
                                ),
                                Tooltip(
                                  message: "Add Candidate",
                                  child: IconButton(
                                    icon: const Icon(Icons.person_add, color: AppColors.primary),
                                    onPressed: () async {
                                      final candidateController = TextEditingController();
                                      await showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Row(
                                            children: const [
                                              Icon(Icons.person_add, color: AppColors.primary),
                                              SizedBox(width: 8),
                                              Text("Add New Candidate"),
                                            ],
                                          ),
                                          content: TextField(
                                            controller: candidateController,
                                            decoration: const InputDecoration(labelText: "Candidate Name"),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: const Text("Cancel"),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                                              onPressed: () async {
                                                final name = candidateController.text.trim();
                                                if (name.isNotEmpty) {
                                                  await vm.addCandidate(doc.id, positions, posIndex, name);
                                                  if (!context.mounted) return;
                                                  Navigator.pop(context);
                                                }
                                              },
                                              child: const Text("Add"),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ...candidates.map((candidate) {
                            final candIndex = candidates.indexOf(candidate);
                            return ListTile(
                              leading: const SizedBox(width: 20),
                              title: Text('• $candidate'),
                              trailing: Wrap(
                                spacing: 4,
                                children: [
                                  Tooltip(
                                    message: "Edit Candidate",
                                    child: IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                      onPressed: () => _showEditDialog(
                                        context,
                                        "Candidate",
                                        candidate,
                                            (newName) => vm.updateCandidateName(doc.id, positions, posIndex, candIndex, newName),
                                      ),
                                    ),
                                  ),
                                  Tooltip(
                                    message: "Delete Candidate",
                                    child: IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _confirmDelete(
                                        context,
                                        "Are you sure you want to delete this candidate?",
                                            () => vm.deleteCandidate(doc.id, positions, posIndex, candIndex),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      );
                    }).toList(),
                    ListTile(
                      leading: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                      title: const Text("Add New Position"),
                      onTap: () async {
                        final positionNameController = TextEditingController();
                        await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Row(
                              children: const [
                                Icon(Icons.add_circle_outline, color: AppColors.primary),
                                SizedBox(width: 8),
                                Text("Add New Position"),
                              ],
                            ),
                            content: TextField(
                              controller: positionNameController,
                              decoration: const InputDecoration(labelText: "Position Name"),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Cancel"),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                                onPressed: () async {
                                  final name = positionNameController.text.trim();
                                  if (name.isNotEmpty) {
                                    await vm.addPosition(doc.id, positions, name);
                                    if (!context.mounted) return;
                                    Navigator.pop(context);
                                  }
                                },
                                child: const Text("Add"),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}