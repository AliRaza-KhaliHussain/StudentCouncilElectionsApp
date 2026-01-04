import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isImageLoaded = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    // ✅ Wait until the first frame is rendered before using context
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await precacheImage(const AssetImage('assets/images/splash_vote.jpg'), context);
      setState(() {
        _isImageLoaded = true;
      });
      _controller.forward(); // Start animation after image is loaded
    });

    // ✅ Navigate after delay
    Future.delayed(const Duration(seconds: 8), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: _isImageLoaded
          ? FadeTransition(
        opacity: _animation,
        child: _buildSplashContent(),
      )
          : const Center(child: CircularProgressIndicator()), // Loading indicator while image loads
    );
  }

  Widget _buildSplashContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/splash_vote.jpg',
            height: 250,
          ),
          const SizedBox(height: 30),
          Text(
            'Online  Secure Voting',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Your vote, your power — secured by technology',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}





// import 'package:flutter/material.dart';
// import 'package:project/views/voter_dashboard_screen.dart';
// import 'package:project/views/voting_screen.dart';
// import '../constants/app_colors.dart';
// import 'login_screen.dart';
// import 'app.dart';
//
// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});
//
//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _animation;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 2),
//     )..forward();
//
//     _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
//
//     Future.delayed(const Duration(seconds: 5), () {
//       Navigator.pushReplacement(
//         context,
//         //MaterialPageRoute(builder: (_) => const MainScreen()),
//          MaterialPageRoute(builder: (_) => const LoginScreen()),
//        // MaterialPageRoute(builder: (_) => const VoterDashboardScreen()),
//         //MaterialPageRoute(builder: (_) => const VotingScreen()),
//
//
//
//       );
//     });
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.lightBackground, // ✅ Centralized light background
//       body: FadeTransition(
//         opacity: _animation,
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Image.asset(
//                 'assets/images/splash_vote.jpg',
//                 height: 250,
//               ),
//               const SizedBox(height: 30),
//               Text(
//                 'Online Secure Voting',
//                 style: TextStyle(
//                   fontSize: 26,
//                   fontWeight: FontWeight.bold,
//                   color: AppColors.primary, // ✅ Green primary color
//                 ),
//               ),
//               const SizedBox(height: 12),
//               Text(
//                 'Your vote, your power — secured by technology',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 15,
//                   color: Colors.black, // You can replace with a centralized muted text color if needed
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
