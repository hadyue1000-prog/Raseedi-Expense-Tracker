// ============================================================================
// اسم الملف: profile_screen.dart
// وظيفة الملف: شاشة تعرض معلومات حساب المستخدم وملخصاً لنشاطه المالي.
// علاقته بالمشروع: تستخدم بيانات AuthProvider لعرض الاسم والايميل، وبيانات TransactionProvider لعرض الرصيد والعمليات.
// أين يتم استخدامه: يُنقل إليها من "الملف الشخصي" في شاشة الإعدادات.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/transaction_provider.dart';
import 'ai_chat_screen.dart';

// ==========================================
// كلاس شاشة الملف الشخصي (ProfileScreen)
// ==========================================
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. قراءة بيانات المستخدم (اسمه، ايميله)
    final authProvider = Provider.of<AuthProvider>(context);
    
    // 2. قراءة بيانات العمليات (الرصيد، عدد العمليات، المصروفات)
    final transProvider = Provider.of<TransactionProvider>(context);

    return Scaffold(
      
      // الشريط العلوي (بنفسجي)
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        backgroundColor: const Color(0xFF2f8f83),
        foregroundColor: Colors.white,
      ),
      
      body: SingleChildScrollView(
        child: Column(
          children: [
            
            // ==========================================
            // القسم العلوي (البطاقة البنفسجية وصورة المستخدم)
            // ==========================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30),
              decoration: const BoxDecoration(
                color: Color(0xFF2f8f83),
                // تدوير الزوايا السفلية فقط لتبدو متصلة بالشريط العلوي
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  
                  // صورة المستخدم (دائرة بيضاء بداخلها الحرف الأول من اسمه)
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Text(
                      // التحقق: إذا كان الاسم ليس فارغاً، نأخذ الحرف الأول (index 0) ونكبره
                      authProvider.userName.isNotEmpty
                          ? authProvider.userName[0].toUpperCase()
                          : 'م', // إذا كان فارغاً لأي سبب نضع حرف الميم افتراضياً
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2f8f83), // الحرف باللون البنفسجي
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  
                  // اسم المستخدم
                  Text(
                    authProvider.userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  
                  // البريد الإلكتروني (لون أبيض شفاف قليلاً)
                  Text(
                    authProvider.userEmail,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ==========================================
            // قسم ملخص النشاط (3 صناديق صغيرة)
            // ==========================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'ملخص النشاط',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // الأرقام مرتبة بجانب بعضها
                  Row(
                    children: [
                      // صندوق: إجمالي عدد العمليات المسجلة
                      Expanded(
                        child: _buildActivityCard(
                          label: 'عمليات',
                          value: '${transProvider.transactions.length}',
                          icon: Icons.receipt,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      
                      // صندوق: الرصيد الحالي
                      Expanded(
                        child: _buildActivityCard(
                          label: 'الرصيد',
                          value: '${transProvider.getBalance().toStringAsFixed(0)} ر',
                          icon: Icons.account_balance_wallet,
                          color: const Color(0xFF2f8f83),
                        ),
                      ),
                      const SizedBox(width: 10),
                      
                      // صندوق: إجمالي ما صرفه
                      Expanded(
                        child: _buildActivityCard(
                          label: 'مصروف',
                          value: '${transProvider.getTotalExpense().toStringAsFixed(0)} ر',
                          icon: Icons.arrow_upward,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ==========================================
                  // قسم بيانات الحساب (الاسم، الايميل، النوع)
                  // ==========================================
                  const Text(
                    'بيانات الحساب',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // استخدام دالة مساعدة لإنشاء صفوف المعلومات
                  _buildInfoRow(
                    icon: Icons.person,
                    label: 'الاسم',
                    value: authProvider.userName,
                  ),
                  const Divider(), // خط فاصل خفيف
                  
                  _buildInfoRow(
                    icon: Icons.email,
                    label: 'البريد الإلكتروني',
                    value: authProvider.userEmail,
                  ),
                  const Divider(),
                  
                  // معلومة ثابتة مخصصة لجمهور التطبيق (الطلاب)
                  _buildInfoRow(
                    icon: Icons.school,
                    label: 'النوع',
                    value: 'طالب جامعي',
                  ),
                  const Divider(),
                  const SizedBox(height: 12),

                  // ==========================================
                  // زر بارز للمساعد المالي الذكي
                  // ==========================================
                  GestureDetector(
                    // عند الضغط يفتح شاشة الدردشة
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AiChatScreen(),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        // خلفية متدرجة (Gradient) لتبدو مميزة وعصرية
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2f8f83), Color.fromARGB(255, 31, 92, 85)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(Icons.arrow_back_ios, color: Colors.white70, size: 16),

                          Row(children: [


                           
                             Text(
                              'المساعد المالي الذكي',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            
                          ),SizedBox(width: 12),
                           Icon(Icons.auto_awesome, color: Colors.white, size: 24),
                          
                          ],)
                        ],
                      ),

                    ),
                  ),
                                    const SizedBox(height: 12),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // دوال مساعدة لتقليل تكرار الكود
  // ============================================================

  // 1. صندوق الإحصاء الصغير (مثل: عدد العمليات)
  Widget _buildActivityCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          Text(label, style: TextStyle(color: color, fontSize: 10)),
        ],
      ),
    );
  }

  // 2. صف عرض معلومة نصية (مثل: الايميل وجانبه أيقونة)
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(label,
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15)),
            ],
          ),
                    const SizedBox(width: 14),

          Icon(icon, color: const Color(0xFF2f8f83), size: 22),

        ],
      ),
    );
  }
}
