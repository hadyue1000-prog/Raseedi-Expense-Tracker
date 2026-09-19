import 'package:flutter/material.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    _navigateToOnboarding();
  }

  void _navigateToOnboarding() async {
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      //importnant for if the user close the app before the tow sconds

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2f8f83),

      body: Center(
        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            Container(

              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Image.asset("icon/logo.png",width: 200,),

            ),

            const SizedBox(height: 20),

            const Text(

              'رصيدي',
              style: TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,

              ),

            ),

            const SizedBox(height: 8),
          
            const Text(

              'إدارة مصروفاتك بذكاء',
              style: TextStyle(
                color: Color.fromARGB(193, 255, 255, 255),
                fontSize: 16,

              ),

            ),

            const SizedBox(height: 40),

           
            const CircularProgressIndicator(
              
              color: Colors.white,
              strokeWidth: 2, 
              
            ),

          ],

        ),

      ),

    );

  }

}
