import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/constants.dart';
import '../../../auth/models/user_model.dart';

class RecentRegisteredVoters extends StatefulWidget {
  const RecentRegisteredVoters({Key? key}) : super(key: key);

  @override
  State<RecentRegisteredVoters> createState() => _RecentRegisteredVotersState();
}

class _RecentRegisteredVotersState extends State<RecentRegisteredVoters> {
  final int pageSize = 10;
  int currentPage = 0;
  String selectedField = 'name';
  String searchText = '';
  bool ascending = true;

  final List<String> searchFields = ['name', 'phone', 'cnic', 'job_type'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 600;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(defaultPadding),
          decoration: BoxDecoration(
            color: colorScheme.secondaryContainer.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.how_to_reg_rounded, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    "Registered Voters",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: defaultPadding),

              /// Search & Filter UI
              Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  DropdownButton<String>(
                    value: selectedField,
                    onChanged: (value) {
                      setState(() {
                        selectedField = value!;
                        currentPage = 0;
                      });
                    },
                    items: searchFields
                        .map((f) => DropdownMenuItem(
                      value: f,
                      child: Text("Sort  by ${f.toUpperCase()}"),
                    ))
                        .toList(),
                  ),
                  SizedBox(
                    width: isSmallScreen ? double.infinity : 300,
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: "Search...",
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) {
                        setState(() {
                          searchText = val.trim();
                          currentPage = 0;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: defaultPadding),

              /// Data Table
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('role', isEqualTo: 'voter')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No voters found."));
                  }

                  List<AppUser> users = snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return AppUser.fromMap(data, doc.id);
                  }).toList();

                  if (searchText.isNotEmpty) {
                    users = users.where((user) {
                      final value = (user.toMap()[selectedField] ?? '')
                          .toString()
                          .toLowerCase();
                      return value.contains(searchText.toLowerCase());
                    }).toList();
                  }

                  users.sort((a, b) {
                    final aVal = (a.toMap()[selectedField] ?? '')
                        .toString()
                        .toLowerCase();
                    final bVal = (b.toMap()[selectedField] ?? '')
                        .toString()
                        .toLowerCase();
                    return ascending
                        ? aVal.compareTo(bVal)
                        : bVal.compareTo(aVal);
                  });

                  final totalPages = (users.length / pageSize).ceil();
                  final pagedUsers =
                  users.skip(currentPage * pageSize).take(pageSize).toList();

                  return Column(
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minWidth: constraints.maxWidth),
                          child: DataTable(
                            sortColumnIndex: searchFields.indexOf(selectedField),
                            sortAscending: ascending,
                            headingRowColor: MaterialStateColor.resolveWith(
                                    (states) => colorScheme.primary.withOpacity(0.08)),
                            columnSpacing: defaultPadding,
                            columns: [
                              DataColumn(
                                label: const Text("Name"),
                                onSort: (_, __) => setState(() {
                                  selectedField = 'name';
                                  ascending = !ascending;
                                }),
                              ),
                              DataColumn(
                                label: const Text("Phone Number"),
                                onSort: (_, __) => setState(() {
                                  selectedField = 'phone';
                                  ascending = !ascending;
                                }),
                              ),
                              DataColumn(
                                label: const Text("CNIC"),
                                onSort: (_, __) => setState(() {
                                  selectedField = 'cnic';
                                  ascending = !ascending;
                                }),
                              ),
                              DataColumn(
                                label: const Text("Job Type"),
                                onSort: (_, __) => setState(() {
                                  selectedField = 'job_type';
                                  ascending = !ascending;
                                }),
                              ),
                            ],
                            rows: pagedUsers.map((user) {
                              return DataRow(
                                cells: [
                                  DataCell(Row(
                                    children: [
                                      SvgPicture.asset(
                                        "assets/icons/profile.svg",
                                        height: 20,
                                        color: colorScheme.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Flexible(child: Text(user.name)),
                                    ],
                                  )),
                                  DataCell(Text(user.phone)),
                                  DataCell(Text(user.cnic)),
                                  DataCell(Text(user.jobType ?? '-')),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ).animate().fade(duration: 400.ms).slideY(),

                      const SizedBox(height: 12),

                      /// Pagination
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: currentPage > 0
                                ? () => setState(() => currentPage--)
                                : null,
                            icon: const Icon(Icons.arrow_back_ios_new_rounded),
                          ),
                          Text("Page ${currentPage + 1} of $totalPages"),
                          IconButton(
                            onPressed: (currentPage + 1) < totalPages
                                ? () => setState(() => currentPage++)
                                : null,
                            icon: const Icon(Icons.arrow_forward_ios_rounded),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
