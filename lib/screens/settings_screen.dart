// ============================================================================
// اسم الملف: settings_screen.dart
// وظيفة الملف: شاشة الإعدادات الرئيسية في التطبيق.
// علاقته بالمشروع: تحتوي على روابط للانتقال إلى شاشات أخرى (الملف الشخصي، التصنيفات، الميزانية)
//                 وتحتوي على أزرار التحكم بالنظام (الوضع الداكن، تسجيل الخروج).
// أين يتم استخدامه: يُنقل إليها من أيقونة "الترس" في الصفحة الرئيسية.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';

// استيراد الشاشات التي سننتقل إليها
import 'login_screen.dart';
import 'profile_screen.dart';
import 'categories_screen.dart';
import 'budget_screen.dart';

// ==========================================
// كلاس شاشة الإعدادات (SettingsScreen)
// ==========================================
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. قراءة حالة الثيم (لتشغيل زر التبديل بين الداكن والفاتح)
    // نستخدم watch (أو الإلغاء لـ listen: false) لأننا نحتاج تحديث الشاشة فور تغير الثيم
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    // 2. قراءة بيانات المستخدم (الاسم)
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      
      // الشريط العلوي
      appBar: AppBar(
        title:  Container(
          alignment: Alignment.topRight,
          child: Text('الإعدادات')),
        backgroundColor: const Color(0xFF2f8f83),
        foregroundColor: Colors.white,
      ),
      
      // ListView تعرض العناصر بشكل قائمة وتسمح بالتمرير
      body: ListView(
        children: [
          
          // ==========================================
          // قسم الحساب
          // ==========================================
          _buildSectionHeader('الحساب'),

          // زر الملف الشخصي
          Directionality(
            textDirection: TextDirection.rtl,
        
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF2f8f83),
                child: Icon(Icons.person, color: Colors.white, size: 20),
              ),
              title: const Text('الملف الشخصي'),
              subtitle: Text(authProvider.userName), // عرض اسم المستخدم
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
            ),
          ),
          
          // خط فاصل (indent: 72 يجعله يبدأ بعد الأيقونة وليس من أول الشاشة)
          const Divider(indent: 72),

          // ==========================================
          // قسم المظهر والتطبيق
          // ==========================================
          _buildSectionHeader('المظهر والتطبيق'),

          // زر التبديل بين الوضع الداكن والفاتح
          Directionality(
            textDirection: TextDirection.rtl,

            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.indigo,
                child: Icon(
                  // تغيير الأيقونة حسب حالة الثيم
                  themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              title: const Text('الوضع الداكن'),
              subtitle: Text(themeProvider.isDarkMode ? 'مفعّل' : 'معطّل'),
              
              // Switch: زر تبديل (ON/OFF)
              trailing: Switch(
                value: themeProvider.isDarkMode, // القيمة الحالية
                activeThumbColor: const Color(0xFF6C63FF),
                onChanged: (value) {
                  // عند الضغط يتم استدعاء دالة تبديل الثيم من المزود
                  themeProvider.toggleTheme();
                },
              ),
            ),
          ),
          const Divider(indent: 72),

          // زر إدارة التصنيفات
          Directionality(
           textDirection: TextDirection.rtl,

            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.orange,
                child: Icon(Icons.category, color: Colors.white, size: 20),
              ),
              title: const Text('التصنيفات'),
              subtitle: const Text('إدارة تصنيفات المعاملات'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CategoriesScreen(),
                  ),
                );
              },
            ),
          ),
          const Divider(indent: 72),

          // زر إدارة الميزانية
          Directionality(
            textDirection: TextDirection.rtl,
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.teal,
                child: Icon(Icons.savings, color: Colors.white, size: 20),
              ),
              title: const Text('الميزانية الشهرية'),
              subtitle: const Text('ضبط ميزانيتك الشهرية'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BudgetScreen()),
                );
              },
            ),
          ),

          // ==========================================
          // قسم النظام
          // ==========================================
          _buildSectionHeader('النظام'),

          // زر تسجيل الخروج (ملون بالأحمر للتنبيه)
          Directionality(
            textDirection: TextDirection.rtl,

            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.red,
                child: Icon(Icons.logout, color: Colors.white, size: 20),
              ),
              title: const Text(
                'تسجيل الخروج',
                style: TextStyle(color: Colors.red),
              ),
              subtitle: const Text('الخروج من الحساب الحالي'),
              onTap: () {
                // إظهار نافذة تأكيد قبل الخروج الفعلي
                _showLogoutDialog(context, authProvider);
              },
            ),
          ),

          // ==========================================
          // قسم فريق التطوير (حقوق الملكية)
          // ==========================================
          _buildSectionHeader('فريق التطوير'),
          _buildDeveloperTile('م. مهند هاني', 'مطور التطبيق', Icons.person),
          const Divider(indent: 72),
          _buildDeveloperTile('م. هادي محمد', 'مطور التطبيق', Icons.person),
          const Divider(indent: 72),
          _buildDeveloperTile('م. محمد عدنان', 'مطور التطبيق', Icons.person),

          const SizedBox(height: 20),

          // ==========================================
          // معلومات التطبيق السفلية
          // ==========================================
          Center(
            child: Column(
              children: const [
                Text(
                  'رصيدي',
                  style: TextStyle(
                    color: Color(0xFF6C63FF),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'الإصدار 1.0.0',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  'تطبيق إدارة المال للطلاب الجامعيين',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ============================================================
  // دوال مساعدة لترتيب الكود وإعادة استخدامه
  // ============================================================

  // 1. بناء عنوان للقسم (مثل: الحساب، النظام)
  Widget _buildSectionHeader(String title) {
    return Container(
      alignment: Alignment.topRight,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF2f8f83),
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  // 2. بناء بطاقة تعريفية لمطور التطبيق
  Widget _buildDeveloperTile(String name, String role, IconData icon) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF2f8f83).withAlpha(30),
          child: Icon(icon, color: const Color(0xFF2f8f83), size: 20),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(role, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ),
    );
  }

  // 3. نافذة تأكيد تسجيل الخروج
  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('تسجيل الخروج'),
          content: const Text('هل أنت متأكد أنك تريد تسجيل الخروج؟'),
          actions: [
            // زر الإلغاء
            TextButton(
              onPressed: () => Navigator.pop(context), // إغلاق النافذة
              child: const Text('إلغاء'),
            ),
            // زر التأكيد
            TextButton(
              onPressed: () {
                // 1. تنفيذ الخروج ومسح بيانات الجلسة
                authProvider.logout();

                // 2. الانتقال إلى شاشة الدخول وحذف مسار العودة 
                // لكي لا يتمكن المستخدم من الرجوع بالتمرير للخلف بعد خروجه
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('تسجيل الخروج'),
            ),
          ],
        );
      },
    );
  }
}
