
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
 
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ==========================================
  // دالة تنفيذ إنشاء الحساب (_register)
  // ==========================================
  void _register() {
    // 1. التحقق من صحة الإدخال (Validation)
    // إذا كان أي حقل من الثلاثة فارغاً، نعرض تنبيهاً ولا نكمل العملية
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF2f8f83),
          content: Text(
            textAlign: TextAlign.right,
            'يرجى ملء جميع الحقول')),
      );
      return; 
    }

    Provider.of<AuthProvider>(context, listen: false).register(
      _nameController.text,
      _emailController.text,
      _passwordController.text,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Color(0xFF2f8f83),
        content: Text(
          textAlign: TextAlign.right,
          'تم إنشاء الحساب بنجاح. الرجاء تسجيل الدخول بنفس الإيميل وكلمة المرور',
        ),
      ),
    );

    Navigator.pop(context, _emailController.text);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,      
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2f8f83)), 
      ),
      
      body: SafeArea(

        child: SingleChildScrollView(

          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              
              const Text(

                'إنشاء حساب جديد',
                style: TextStyle(

                  fontSize: 26,
                  fontWeight: FontWeight.bold,

                ),

              ),

              const SizedBox(height: 6),
              const Text(

                'أدخل بياناتك لبدء إدارة مصروفاتك',
                style: TextStyle(color: Colors.grey),

              ),

              const SizedBox(height: 30),

              CustomTextField(

                label: 'الاسم الكامل',
                controller: _nameController,
                hint: 'أحمد محمد',

              ),

              const SizedBox(height: 16),

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
                text: 'إنشاء الحساب',
                onPressed: _register,
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                   GestureDetector(
                    onTap: () {
              
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'سجل الدخول',
                      style: TextStyle(

                        color: Color(0xFF2f8f83),
                        fontWeight: FontWeight.bold,

                      ),

                    ),

                  ),

                  SizedBox(
                    width: 10,
                  ),

                  const Text('لديك حساب بالفعل؟ '),
                 
                ],

              ),

            ],

          ),

        ),

      ),

    );

  }
  
}
