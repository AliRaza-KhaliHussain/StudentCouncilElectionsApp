import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../viewmodels/all_results_viewmodel.dart';
import 'election_detail_screen.dart';

class AllResultsScreen extends StatefulWidget {
  const AllResultsScreen({super.key});

  @override
  State<AllResultsScreen> createState() => _AllResultsScreenState();
}

class _AllResultsScreenState extends State<AllResultsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final primary = AppColors.primary;

    return ChangeNotifierProvider(
      create: (_) => AllResultsViewModel()..fetchAllResults(),
      child: Scaffold(
        backgroundColor: background,
        appBar: AppBar(
          title: const Text('All Results'),
          centerTitle: true,
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: Consumer<AllResultsViewModel>(
            builder: (context, vm, _) {
              if (vm.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (vm.error != null) {
                return Center(
                  child: Text(
                    '❌ ${vm.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              final tabs = [
                vm.results.where(vm.isCurrent).toList(),
                vm.results.where(vm.isPast).toList(),
                vm.results.where(vm.isUpcoming).toList(),
              ];

              return LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 600;

                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              children: [
                                Icon(Icons.bar_chart, color: primary),
                                const SizedBox(width: 8),
                                Text(
                                  'All Election Results',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: TabBar(
                              controller: _tabController,
                              labelColor: primary,
                              indicatorColor: primary,
                              unselectedLabelColor: Colors.grey,
                              tabs: const [
                                Tab(text: "Current"),
                                Tab(text: "Past"),
                                Tab(text: "Upcoming"),
                              ],
                            ),
                          ),
                          Expanded(
                            child: TabBarView(
                              controller: _tabController,
                              children: tabs.map((results) {
                                if (results.isEmpty) {
                                  return const Center(
                                    child: Text("No results available."),
                                  );
                                }

                                return ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: results.length,
                                  itemBuilder: (context, index) {
                                    final election = results[index];
                                    final isValid = vm.isBlockchainValid[election.electionId] ?? true;

                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => ElectionDetailScreen(
                                              election: election,
                                              candidateColors: vm.candidateColors,
                                              isBlockchainValid: isValid,
                                            ),
                                          ),
                                        );
                                      },
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                        margin: const EdgeInsets.symmetric(vertical: 10),
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: cardColor,
                                          borderRadius: BorderRadius.circular(16),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Icon(
                                              Icons.how_to_vote_rounded,
                                              color: primary,
                                              size: 40,
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    election.electionTitle,
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.w600,
                                                      color: textColor,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Row(
                                                    children: [
                                                      const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                                      const SizedBox(width: 6),
                                                      Flexible(
                                                        child: Text(
                                                          "${_formatDateTime(election.startDate)} → ${_formatDateTime(election.endDate)}",
                                                          style: const TextStyle(
                                                            fontSize: 14,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  if (!isValid)
                                                    const Padding(
                                                      padding: EdgeInsets.only(top: 6),
                                                      child: Text(
                                                        '⚠ Blockchain Invalid',
                                                        style: TextStyle(
                                                          color: Colors.red,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                            const Icon(Icons.chevron_right, color: Colors.grey),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return "${dt.year}-${_pad(dt.month)}-${_pad(dt.day)} ${_pad(dt.hour)}:${_pad(dt.minute)}";
  }

  String _pad(int n) => n.toString().padLeft(2, '0');
}
