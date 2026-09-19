

import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../widgets/custom_button.dart';


class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(      
     
      body: SafeArea(

        child: Padding(

          padding: const EdgeInsets.all(24),
          child: Column(
            children: [              
              const Spacer(), 

              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  
                  color: const Color(0xFF2f8f83).withValues(alpha: 0.1),
                  shape: BoxShape.circle,

                ),
                child: Image.asset("icon/logo.png")

              ),
              
              const SizedBox(height: 40),

              const Text(

                'مرحباً بك في رصيدي',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 38, 117, 108),
                
                ),

              ),
              
              const SizedBox(height: 16),

              const Text(

                'تطبيق رصيدي يساعدك على متابعة\nمصروفاتك ودخلك بسهولة وبساطة '
                '\nتحكم في ميزانيتك وحقق أهدافك المالية',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,                   
                  height: 1.6, 

                ),

              ),
              
              const SizedBox(height: 30),

              _buildFeatureItem(Icons.add_circle_outline, 'سجّل دخلك ومصروفاتك'),
              const SizedBox(height: 10),
              _buildFeatureItem(Icons.pie_chart_outline, 'تابع إحصائياتك'),
              const SizedBox(height: 10),
              _buildFeatureItem(Icons.savings_outlined, 'حدد ميزانيتك الشهرية'),

              const Spacer(), 

              CustomButton(

                text: 'ابدأ الآن',
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                },
              ),
              
              const SizedBox(height: 16),
            ],

          ),

        ),

      ),

    );

  }

  Widget _buildFeatureItem(IconData icon, String text) {

    return Row(

      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        
        Text(
          text,
          style: const TextStyle(fontSize: 15),
        ),

        const SizedBox(width: 10),

        Icon(icon, color: const Color(0xFF2f8f83), size: 22),

      ],

    );

  }
  
}
