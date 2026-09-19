
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import 'home_screen.dart';
import 'register_screen.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
  
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();

  }

 
  void _login() {

    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF2f8f83),
          content: Text(
            textAlign: TextAlign.right,
            'يرجى ملء جميع الحقول')),
      );
      return; 
    }

    final success = Provider.of<AuthProvider>(context, listen: false).login(
      _emailController.text,
      _passwordController.text,
    );

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF2f8f83),
          content: Text(
            
            textAlign: TextAlign.right,
            'يرجى إنشاء حساب أولاً، ثم تسجيل الدخول بنفس البيانات المسجلة',
          ),
        ),
      );
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (route) => false, 
    );
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: SafeArea(
        
        child: SingleChildScrollView(

          padding: const EdgeInsets.all(24),
          child: Column(

            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const SizedBox(height: 40),
              Center(

                child: Image.asset("icon/logo.png", width: 80),

              ),

              const SizedBox(height: 16),

              const Center(
                child: Text(
                  'رصيدي',
                  style: TextStyle(

                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2f8f83),

                  ),

                ),

              ),

              const SizedBox(height: 40),

              const Text(
                'تسجيل الدخول',
                style: TextStyle(

                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  
                ),
                
              ),

              const SizedBox(height: 6),

              const Text(

                'أدخل بياناتك للمتابعة',
                style: TextStyle(color: Colors.grey),

              ),

              const SizedBox(height: 30),

              CustomTextField(
                
                label: 'البريد الإلكتروني',
                controller: _emailController, 
                hint: 'example@email.com',
                keyboardType: TextInputType.emailAddress,

              ),

              const SizedBox(height: 16),

              CustomTextField(
                label: 'كلمة المرور',
                controller: _passwordController,
                hint: '••••••••',
                obscureText: true,

              ),

              const SizedBox(height: 30),

              CustomButton(

                text: 'تسجيل الدخول',
                onPressed: _login,
                 
              ),
              
              const SizedBox(height: 20),

              Row(

                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(

                    onTap: () async {
                      final registeredEmail = await Navigator.push<String?>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );

                      if (registeredEmail != null && registeredEmail.isNotEmpty) {
                        setState(() {
                          _emailController.text = registeredEmail;
                          
                        }
                        
                        );
                      }

                    },
                    
                    child: const Text(
                      'أنشئ حساباً',
                      style: TextStyle(

                        color: Color(0xFF2f8f83),
                        fontWeight: FontWeight.bold,

                      ),

                    ),

                  ),
                  
                  SizedBox(
                    width: 10,
                  ),

                  const Text('ليس لديك حساب؟ '),
                  
                  
                ],

              ),

            ],

          ),

        ),

      ),

    );

  }
  
}
