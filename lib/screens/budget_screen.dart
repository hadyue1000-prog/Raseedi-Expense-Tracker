// ============================================================================
// اسم الملف: budget_screen.dart
// وظيفة الملف: شاشة لإدارة الميزانية الشهرية.
// علاقته بالمشروع: يعرض شريط تقدم لاستهلاك الميزانية ويسمح للمستخدم بتعديل ميزانيته.
// أين يتم استخدامه: يُنقل إليها من الإعدادات (SettingsScreen).
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/budget_provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

// ==========================================
// كلاس شاشة الميزانية (BudgetScreen)
// ==========================================
// StatefulWidget لأننا نحتاج لحقل نصي لتعديل الميزانية.
class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  
  // ==========================================
  // المتغيرات
  // ==========================================
  // متحكم حقل إدخال الميزانية الجديدة
  final TextEditingController _budgetController = TextEditingController();

  // ==========================================
  // دالة التهيئة الأولية (initState)
  // ==========================================
  @override
  void initState() {
    super.initState();
    // عند فتح الشاشة، نريد أن يظهر الرقم الحالي للميزانية داخل حقل النص جاهزاً للتعديل.
    final currentBudget =
        Provider.of<BudgetProvider>(context, listen: false).monthlyBudget;
    _budgetController.text = currentBudget.toStringAsFixed(0);
  }

  // التخلص من المتحكم عند إغلاق الشاشة
  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  // ==========================================
  // دالة حفظ الميزانية الجديدة (_saveBudget)
  // ==========================================
  void _saveBudget() {
    // محاولة تحويل النص المكتوب إلى رقم
    final double? newBudget = double.tryParse(_budgetController.text);

    // التحقق من صحة الإدخال
    if (newBudget == null || newBudget <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        
        const SnackBar(content: Text('يرجى إدخال ميزانية صحيحة')),
      );
      return;
    }

    // إرسال الميزانية الجديدة إلى BudgetProvider لتحديثها في كل التطبيق
    Provider.of<BudgetProvider>(context, listen: false).updateBudget(newBudget);

    // رسالة نجاح
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم تحديث الميزانية بنجاح'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // ==========================================
  // بناء الواجهة (build)
  // ==========================================
  @override
  Widget build(BuildContext context) {
    // Consumer2: نستمع لمزودين اثنين: 
    // BudgetProvider: لمعرفة الميزانية الكلية.
    // TransactionProvider: لمعرفة كم تم صرفه للآن.
    return Consumer2<BudgetProvider, TransactionProvider>(
      builder: (context, budgetProvider, transProvider, child) {
        
        final budget = budgetProvider.monthlyBudget;
        final totalExpense = transProvider.getTotalExpense();
        
        // حساب المتبقي (الميزانية ناقص المصروفات)
        final remaining = budget - totalExpense;
        
        // حساب نسبة الإنفاق (قيمة بين 0.0 و 1.0) لاستخدامها في شريط التقدم
        // clamp(0.0, 1.0) تحمينا من أن يتجاوز الرقم 1.0 إذا صرف المستخدم أكثر من ميزانيته
        final percentage = (totalExpense / budget).clamp(0.0, 1.0);

        return Scaffold(
          appBar: AppBar(
            title: Container(
              alignment: Alignment.topRight,
              child: const Text('الميزانية الشهرية')),
            backgroundColor: const Color(0xFF2f8f83),
            foregroundColor: Colors.white,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                
                // -------- 1. بطاقة الميزانية الحالية الكبيرة --------
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2f8f83).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF2f8f83).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'الميزانية الشهرية',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${budget.toStringAsFixed(0)} ريال',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2f8f83),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // -------- 2. شريط تقدم الإنفاق (Progress Bar) --------
                const Text(
                  'نسبة الإنفاق',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                
                // ClipRRect يجعل زوايا شريط التقدم دائرية
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: percentage, // النسبة (مثل 0.5 تعني 50%)
                    minHeight: 20, // سماكة الشريط
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      // إذا تجاوز الصرف 80% يتحول لون الشريط للأحمر كتنبيه، وإلا فهو أخضر
                      percentage > 0.8 ? Colors.red : Colors.green,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(percentage * 100).toStringAsFixed(1)}% من الميزانية',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),

                // -------- 3. صندوقان للمنفَق والمتبقي --------
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoBox(
                        label: 'المُنفَق',
                        amount: totalExpense,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoBox(
                        label: 'المتبقي',
                        amount: remaining,
                        // اللون أخضر إذا كان هناك متبقي، أحمر إذا تجاوز الميزانية
                        color: remaining >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // -------- 4. حقل وزر تحديث الميزانية --------
                const Text(
                  'تحديث الميزانية',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                
                CustomTextField(
                  label: 'الميزانية الشهرية الجديدة (ريال)',
                  controller: _budgetController,
                  hint: '0',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),
                
                CustomButton(
                  text: 'حفظ الميزانية',
                  onPressed: _saveBudget,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // دالة مساعدة لرسم صندوق معلومات صغير
  // ============================================================
  Widget _buildInfoBox({
    required String label,
    required double amount,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: color, fontSize: 13)),
          const SizedBox(height: 4),
          Text(
            '${amount.toStringAsFixed(0)} ر',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
