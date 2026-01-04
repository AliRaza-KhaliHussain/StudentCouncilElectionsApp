import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../election/viewmodels/add_election_viewmodel.dart';

class AddElectionScreen extends StatelessWidget {
  final Map<String, dynamic>? initialData;
  final String? electionId;

  const AddElectionScreen({super.key, this.initialData, this.electionId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddElectionViewModel(
        initialData: initialData,
        electionId: electionId,
      ),
      child: const _AddElectionForm(),
    );
  }
}

class _AddElectionForm extends StatelessWidget {
  const _AddElectionForm();

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AddElectionViewModel>(context);
    final theme = Theme.of(context);
    final green = AppColors.primary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(vm.isEditing ? "📝 Edit Election" : "🗳️ Create New Election"),
        backgroundColor: green,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'save_btn',
        backgroundColor: green,
        icon: const Icon(Icons.save_rounded),
        label: Text(vm.isEditing ? "Update Election" : "Save Election"),
        onPressed: vm.isLoading ? null : () => vm.saveElection(context),
      ).animate().scale(duration: 200.ms).fadeIn(),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Form(
          key: vm.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle("📋 Election Title"),
              TextFormField(
                controller: vm.titleController,
                decoration: _inputDecoration("Election Title", Icons.title, green),
                validator: (val) => val == null || val.isEmpty ? "Enter title" : null,
              ),
              const SizedBox(height: 20),
              _sectionTitle("🗓️ Date & Time"),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => vm.pickDate(context, isStart: true),
                      icon: const Icon(Icons.calendar_month),
                      label: Text(vm.startDate == null
                          ? "Start Date"
                          : "Start: ${vm.formatDate(vm.startDate!)}"),
                      style: _dateTimeButtonStyle(green),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: vm.startDate == null
                          ? null
                          : () => vm.pickDate(context, isStart: false),
                      icon: const Icon(Icons.calendar_today_outlined),
                      label: Text(vm.endDate == null
                          ? "End Date"
                          : "End: ${vm.formatDate(vm.endDate!)}"),
                      style: _dateTimeButtonStyle(green),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => vm.pickTime(context, isStart: true),
                      icon: const Icon(Icons.access_time),
                      label: Text(vm.startTime == null
                          ? "Start Time"
                          : vm.startTime!.format(context)),
                      style: _dateTimeButtonStyle(green),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => vm.pickTime(context, isStart: false),
                      icon: const Icon(Icons.timer),
                      label: Text(vm.endTime == null
                          ? "End Time"
                          : vm.endTime!.format(context)),
                      style: _dateTimeButtonStyle(green),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _sectionTitle("👥 Positions & Candidates"),
              ...vm.positions.asMap().entries.map((entry) {
                final index = entry.key;
                final position = entry.value;

                return Card(
                  elevation: 3,
                  color: theme.cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: position.titleController,
                          decoration: _inputDecoration("Position Title", Icons.work, green),
                          validator: (value) =>
                          value == null || value.isEmpty ? "Enter title" : null,
                        ),
                        const SizedBox(height: 12),
                        const Text("Candidates",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 8),
                        ...position.candidateControllers.asMap().entries.map((e) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: TextFormField(
                              controller: e.value,
                              decoration: InputDecoration(
                                labelText: "Candidate ${e.key + 1}",
                                prefixIcon: const Icon(Icons.person),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    position.candidateControllers.removeAt(e.key);
                                    vm.notifyListeners();
                                  },
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: green),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              validator: (val) =>
                              val == null || val.isEmpty ? "Enter candidate" : null,
                            ),
                          );
                        }),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () {
                              position.candidateControllers
                                  .add(TextEditingController());
                              vm.notifyListeners();
                            },
                            icon: const Icon(Icons.add, color: Colors.grey),
                            label: const Text("Add Candidate"),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Eligible Job Types",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: position.selectedJobTypes.map((type) {
                            return Chip(
                              label: Text(type),
                              backgroundColor: green.withOpacity(0.1),
                              deleteIcon: Icon(Icons.close, color: green),
                              onDeleted: () {
                                position.selectedJobTypes.remove(type);
                                vm.notifyListeners();
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: () => _showPerPositionJobTypeDialog(
                                context, vm, position, green),
                            icon: Icon(Icons.edit_note, color: green),
                            label: Text("Edit Job Types", style: TextStyle(color: green)),
                          ),
                        ),
                        if (vm.positions.length > 1)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () => vm.removePosition(index),
                              icon: const Icon(Icons.delete, color: Colors.red),
                              label: const Text(
                                "Remove Position",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ).animate().fade().scale();
              }),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: vm.addPosition,
                  icon: Icon(Icons.add_circle_outline, color: green),
                  label: Text("Add Position", style: TextStyle(color: green)),
                ),
              ),
              const SizedBox(height: 150),
            ],
          ),
        ),
      ),
    );
  }

  void _showPerPositionJobTypeDialog(BuildContext context, AddElectionViewModel vm,
      PositionData position, Color green) {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Select Job Types for Position"),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: vm.allJobTypes.map((type) {
                  final isSel = position.selectedJobTypes.contains(type);
                  return FilterChip(
                    label: Text(type),
                    selected: isSel,
                    onSelected: (_) {
                      if (isSel) {
                        position.selectedJobTypes.remove(type);
                      } else {
                        position.selectedJobTypes.add(type);
                      }
                      setState(() {});
                      vm.notifyListeners();
                    },
                    selectedColor: green,
                    backgroundColor: Colors.grey.shade200,
                    checkmarkColor: Colors.white,
                  );
                }).toList(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Done", style: TextStyle(color: green)),
            )
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon, Color color) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: color),
      fillColor: Colors.white,
      filled: true,
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: color),
        borderRadius: BorderRadius.circular(10),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  ButtonStyle _dateTimeButtonStyle(Color color) {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: color,
      side: BorderSide(color: color),
    );
  }
}
