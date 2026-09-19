// ============================================================================
// اسم الملف: summary_card.dart
// وظيفة الملف: يحتوي على تصميم بطاقة (Card) لعرض ملخص الأرقام (الرصيد، الدخل، المصروفات).
// علاقته بالمشروع: تصميم موحد لعرض المعلومات المالية الهامة بشكل بارز وجميل.
// أين يتم استخدامه: بشكل رئيسي في شاشة الصفحة الرئيسية (HomeScreen).
// ============================================================================

import 'package:flutter/material.dart';

// ==========================================
// كلاس بطاقة الملخص المخصصة (SummaryCard)
// ==========================================
// نوع الكلاس StatelessWidget:
// يعرض البيانات التي نمررها له فقط ولا تتغير حالته من داخله.
class SummaryCard extends StatelessWidget {
  
  // ==========================================
  // المتغيرات (خصائص البطاقة)
  // ==========================================
  
  // عنوان البطاقة (مثال: "الرصيد الحالي"، "إجمالي الدخل")
  final String title;   
  
  // المبلغ المراد عرضه كنص (مثال: "2500")
  final String amount;  
  
  // اللون الأساسي للبطاقة (سيُستخدم للأيقونة والنص ولون الخلفية الشفاف)
  // مثال: أخضر للدخل، أحمر للمصروفات، بنفسجي للرصيد
  final Color color;    
  
  // الأيقونة المعروضة بجانب العنوان
  final IconData icon;  

  // ==========================================
  // البنّاء (Constructor)
  // ==========================================
  const SummaryCard({
    super.key,
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
  });

  // ==========================================
  // دالة البناء (build)
  // ==========================================
  @override
  Widget build(BuildContext context) {
    // نستخدم Container لبناء صندوق له خلفية وإطار
    return Container(
      // المسافة الداخلية (Padding) حول المحتوى
      padding: const EdgeInsets.all(16),
      
      // تزيين الصندوق (BoxDecoration)
      decoration: BoxDecoration(
        // لون الخلفية: نفس اللون المرر لكن بشفافية 10% (0.1) ليكون باهتاً وجميلاً
        color: color.withValues(alpha: 0.1), 
        
        // تدوير زوايا الصندوق
        borderRadius: BorderRadius.circular(12),
        
        // إضافة إطار خارجي (Border) رفيع بنفس اللون بشفافية 30%
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      
      // نستخدم Column لترتيب العناصر فوق بعضها (العنوان فوق الرقم)
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end, // محاذاة لليمين
        children: [
          
          // 1. الأيقونة والعنوان بجانب بعضهما في صف (Row)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 6), // مسافة بين الأيقونة والعنوان

               Icon(icon, color: color, size: 20),

            ],
          ),
          
          const SizedBox(height: 8), // مسافة بين العنوان والرقم
          
          // 2. الرقم (المبلغ) بخط كبير وواضح
          Text(
            amount,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold, // خط عريض
              fontSize: 20,
            ),
          ),
          
          // 3. وحدة العملة (ريال) بخط أصغر وبشفافية 70%
          Text(
            'ريال',
            style: TextStyle(
              color: color.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
