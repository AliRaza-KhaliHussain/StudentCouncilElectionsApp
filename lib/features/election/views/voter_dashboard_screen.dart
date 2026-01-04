import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/views/settings_screen.dart';
import '../viewmodels/voter_dashboard_viewmodel.dart';
import 'widgets/election_card.dart';
import '../../../core/config/theme_provider.dart';
import '../../auth/views/login_screen.dart';
import '../../../shared/views/profile_screen.dart';

class VoterDashboardScreen extends StatefulWidget {
  const VoterDashboardScreen({super.key});

  @override
  State<VoterDashboardScreen> createState() => _VoterDashboardScreenState();
}

class _VoterDashboardScreenState extends State<VoterDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String? userName;
  late VoterDashboardViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = VoterDashboardViewModel();
    _viewModel.fetchElections();
    _tabController = TabController(length: 3, vsync: this);

    _searchController.addListener(() {
      final query = _searchController.text.trim();
      _viewModel.filterElections(query);
    });

    _fetchUserName();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _fetchUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('phone', isEqualTo: user.phoneNumber?.replaceFirst("+92", "0"))
            .limit(1)
            .get();
        if (snapshot.docs.isNotEmpty) {
          setState(() {
            userName = snapshot.docs.first.data()['name'] ?? 'Voter';
          });
        } else {
          setState(() {
            userName = user.displayName ?? 'Voter';
          });
        }
      } catch (e) {
        debugPrint('Error fetching user name: $e');
        setState(() {
          userName = user.displayName ?? 'Voter';
        });
      }
    }
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ChangeNotifierProvider<VoterDashboardViewModel>.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        drawer: _buildDrawer(),
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          title: Text('Welcome, ${userName ?? 'Voter'}'),
          actions: [
            IconButton(
              icon: Icon(
                isDark ? Icons.wb_sunny : Icons.nightlight_round,
                color: Colors.white,
              ),
              onPressed: () {
                Provider.of<ThemeProvider>(context, listen: false).toggleTheme(!isDark);
              },
              tooltip: 'Toggle Theme',
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            indicatorColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: const [
              Tab(text: "Open"),
              Tab(text: "Upcoming"),
              Tab(text: "Closed"),
            ],
          ),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search elections...',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: isDark ? AppColors.darkCard : AppColors.lightCard,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: TextStyle(color: isDark ? AppColors.darkText : AppColors.lightText),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () => _viewModel.fetchElections(),
                        color: AppColors.primary,
                        child: Consumer<VoterDashboardViewModel>(
                          builder: (context, vm, _) {
                            if (vm.isLoading) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            if (vm.error != null) {
                              return Center(
                                child: Text(
                                  '❌ ${vm.error}',
                                  style: TextStyle(color: AppColors.error),
                                ),
                              );
                            }

                            final tabs = [
                              vm.filteredElections.where(vm.isElectionOpen).toList(),
                              vm.filteredElections.where(vm.isElectionUpcoming).toList(),
                              vm.filteredElections.where(vm.isElectionClosed).toList(),
                            ];

                            return TabBarView(
                              controller: _tabController,
                              children: tabs.map((elections) {
                                if (elections.isEmpty) {
                                  return Center(
                                    child: Text(
                                      "No elections available.",
                                      style: TextStyle(color: isDark ? AppColors.darkText : AppColors.lightText),
                                    ),
                                  );
                                }
                                return ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: elections.length,
                                  itemBuilder: (context, index) {
                                    final election = elections[index];
                                    return AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                      margin: const EdgeInsets.symmetric(vertical: 8),
                                      child: ElectionCard(election: election),
                                    );
                                  },
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Drawer _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(userName ?? 'Voter'),
            accountEmail: Text(FirebaseAuth.instance.currentUser?.phoneNumber ?? ''),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: AppColors.white,
              child: Icon(Icons.person, color: AppColors.primary),
            ),
            decoration: const BoxDecoration(color: AppColors.primary),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text('Logout', style: TextStyle(color: AppColors.error)),
            onTap: _logout,
          ),
        ],
      ),
    );
  }
}



// import 'package:flutter/material.dart';

// import 'package:provider/provider.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// import '../constants/app_colors.dart';
// import '../viewmodels/voter_dashboard_viewmodel.dart';
// import '../components/election_card.dart';
// import '../controllers/theme_provider.dart';
// import 'login_screen.dart';
// import 'profile_screen.dart';
// import 'settings_screen.dart';
//
// class VoterDashboardScreen extends StatefulWidget {
//   const VoterDashboardScreen({super.key});
//
//   @override
//   State<VoterDashboardScreen> createState() => _VoterDashboardScreenState();
// }
//
// class _VoterDashboardScreenState extends State<VoterDashboardScreen> with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   final TextEditingController _searchController = TextEditingController();
//   String? userName;
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//     _searchController.addListener(() {
//       final query = _searchController.text.trim();
//       Provider.of<VoterDashboardViewModel>(context, listen: false).filterElections(query);
//     });
//     _fetchUserName();
//   }
//
//   @override
//   void dispose() {
//     _tabController.dispose();
//     _searchController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _fetchUserName() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       try {
//         final snapshot = await FirebaseFirestore.instance
//             .collection('users')
//             .where('phone', isEqualTo: user.phoneNumber?.replaceFirst("+92", "0"))
//             .limit(1)
//             .get();
//         if (snapshot.docs.isNotEmpty) {
//           setState(() {
//             userName = snapshot.docs.first.data()['name'] ?? 'Voter';
//           });
//         } else {
//           setState(() {
//             userName = user.displayName ?? 'Voter';
//           });
//         }
//       } catch (e) {
//         debugPrint('Error fetching user name: $e');
//         setState(() {
//           userName = user.displayName ?? 'Voter';
//         });
//       }
//     }
//   }
//
//   void _logout() async {
//     await FirebaseAuth.instance.signOut();
//     if (mounted) {
//       Navigator.pushAndRemoveUntil(
//         context,
//         MaterialPageRoute(builder: (_) => const LoginScreen()),
//             (route) => false,
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//
//     return ChangeNotifierProvider(
//       create: (_) => VoterDashboardViewModel()..fetchElections(),
//       child: Scaffold(
//         backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
//         drawer: Drawer(
//           child: ListView(
//             padding: EdgeInsets.zero,
//             children: [
//               UserAccountsDrawerHeader(
//                 accountName: Text(userName ?? 'Voter'),
//                 accountEmail: Text(FirebaseAuth.instance.currentUser?.phoneNumber ?? ''),
//                 currentAccountPicture: const CircleAvatar(
//                   backgroundColor: AppColors.white,
//                   child: Icon(Icons.person, color: AppColors.primary),
//                 ),
//                 decoration: const BoxDecoration(color: AppColors.primary),
//               ),
//               ListTile(
//                 leading: const Icon(Icons.person_outline),
//                 title: const Text('Profile'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.settings_outlined),
//                 title: const Text('Settings'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
//                 },
//               ),
//               const Divider(),
//               ListTile(
//                 leading: const Icon(Icons.logout, color: AppColors.error),
//                 title: const Text('Logout', style: TextStyle(color: AppColors.error)),
//                 onTap: _logout,
//               ),
//             ],
//           ),
//         ),
//         appBar: AppBar(
//           backgroundColor: AppColors.primary,
//           title: Text('Welcome, ${userName ?? 'Voter'}'),
//           actions: [
//             IconButton(
//               icon: Icon(
//                 isDark ? Icons.wb_sunny : Icons.nightlight_round,
//                 color: Colors.white,
//               ),
//               onPressed: () {
//                 Provider.of<ThemeProvider>(context, listen: false).toggleTheme(!isDark);
//               },
//               tooltip: 'Toggle Theme',
//             ),
//           ],
//           bottom: TabBar(
//             controller: _tabController,
//             labelColor: Colors.white,
//             indicatorColor: Colors.white,
//             unselectedLabelColor: Colors.white70,
//             tabs: const [
//               Tab(text: "Open"),
//               Tab(text: "Upcoming"),
//               Tab(text: "Closed"),
//             ],
//           ),
//         ),
//         body: LayoutBuilder(
//           builder: (context, constraints) {
//             final isWide = constraints.maxWidth > 600;
//             return Center(
//               child: ConstrainedBox(
//                 constraints: const BoxConstraints(maxWidth: 800),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const SizedBox(height: 12),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 16),
//                       child: TextField(
//                         controller: _searchController,
//                         decoration: InputDecoration(
//                           hintText: 'Search elections...',
//                           prefixIcon: const Icon(Icons.search),
//                           filled: true,
//                           fillColor: isDark ? AppColors.darkCard : AppColors.lightCard,
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide.none,
//                           ),
//                         ),
//                         style: TextStyle(color: isDark ? AppColors.darkText : AppColors.lightText),
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Expanded(
//                       child: RefreshIndicator(
//                         onRefresh: () =>
//                             Provider.of<VoterDashboardViewModel>(context, listen: false).fetchElections(),
//                         color: AppColors.primary,
//                         child: Consumer<VoterDashboardViewModel>(
//                           builder: (context, vm, _) {
//                             if (vm.isLoading) {
//                               return const Center(child: CircularProgressIndicator());
//                             }
//                             if (vm.error != null) {
//                               return Center(
//                                 child: Text(
//                                   '❌ ${vm.error}',
//                                   style: TextStyle(color: AppColors.error),
//                                 ),
//                               );
//                             }
//
//                             final tabs = [
//                               vm.filteredElections.where(vm.isElectionOpen).toList(),
//                               vm.filteredElections.where(vm.isElectionUpcoming).toList(),
//                               vm.filteredElections.where(vm.isElectionClosed).toList(),
//                             ];
//
//                             return TabBarView(
//                               controller: _tabController,
//                               children: tabs.map((elections) {
//                                 if (elections.isEmpty) {
//                                   return Center(
//                                     child: Text(
//                                       "No elections available.",
//                                       style: TextStyle(color: isDark ? AppColors.darkText : AppColors.lightText),
//                                     ),
//                                   );
//                                 }
//                                 return ListView.builder(
//                                   padding: const EdgeInsets.all(16),
//                                   itemCount: elections.length,
//                                   itemBuilder: (context, index) {
//                                     final election = elections[index];
//                                     return AnimatedContainer(
//                                       duration: const Duration(milliseconds: 300),
//                                       curve: Curves.easeInOut,
//                                       margin: const EdgeInsets.symmetric(vertical: 8),
//                                       child: ElectionCard(election: election),
//                                     );
//                                   },
//                                 );
//                               }).toList(),
//                             );
//                           },
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
