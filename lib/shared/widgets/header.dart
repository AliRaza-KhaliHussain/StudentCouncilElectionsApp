import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../providers/menu_provider.dart';
import '../../core/constants/constants.dart';
import '../../core/constants/responsive.dart';
import '../views/profile_screen.dart';
import '../../features/blockchain/views/blockchain_logs_screen.dart';

class Header extends StatelessWidget {
  const Header({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (!Responsive.isDesktop(context))
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: context.read<MenuAppController>().controlMenu,
          ),
        if (!Responsive.isMobile(context))
          Text(
            "Admin Dashboard",
            style: Theme.of(context).textTheme.titleLarge,
          ),
        if (!Responsive.isMobile(context)) const Spacer(flex: 2),
        const Expanded(child: BlockchainValidationButton()),
        const ProfileCard(),
      ],
    );
  }
}

class BlockchainValidationButton extends StatelessWidget {
  const BlockchainValidationButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.verified, color: Colors.white),
        label: const Text(
          "Validate Blockchain",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onPressed: () async {
          final electionId = await _selectElection(context);
          if (electionId != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlockchainValidationScreen(electionId: electionId),
              ),
            );
          }
        },
      ),
    );
  }

  Future<String?> _selectElection(BuildContext context) async {
    final snapshot = await FirebaseFirestore.instance.collection('elections').get();
    final elections = snapshot.docs;

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Select Election to Validate"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: elections.map((doc) {
              return ListTile(
                title: Text(doc['title']),
                onTap: () => Navigator.pop(context, doc.id),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }
}

class ProfileCard extends StatefulWidget {
  const ProfileCard({Key? key}) : super(key: key);

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  String? userName;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserName();
  }

  Future<void> fetchUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('phone', isEqualTo: user.phoneNumber?.replaceFirst("+92", "0"))
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          userName = snapshot.docs.first.data()['name'];
        });
      }
    } catch (e) {
      debugPrint("Failed to load user name: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
      ),
      child: Container(
        margin: const EdgeInsets.only(left: defaultPadding),
        padding: const EdgeInsets.symmetric(
          horizontal: defaultPadding,
          vertical: defaultPadding / 2,
        ),
        decoration: BoxDecoration(
          color: secondaryColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Image.asset(
              "assets/images/profile_pic.png",
              height: 38,
            ),
            if (!Responsive.isMobile(context))
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding / 2),
                child: Text(
                  isLoading
                      ? "Loading..."
                      : userName ?? "User",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            const Icon(Icons.keyboard_arrow_right, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
