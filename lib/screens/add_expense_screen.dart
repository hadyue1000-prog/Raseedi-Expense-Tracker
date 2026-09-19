// ============================================================================
// اسم الملف: add_expense_screen.dart
// وظيفة الملف: شاشة لإضافة مصروف جديد (مثل: شراء غداء، دفع إيجار).
// علاقته بالمشروع: يأخذ بيانات المصروف ويحفظها ويخصمها من الرصيد.
// أين يتم استخدامه: يُنقل إليها من زر "إضافة مصروف" الأحمر في الصفحة الرئيسية.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart'; // نحتاجه لجلب قائمة تصنيفات المصروفات
import '../models/transaction_model.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

// ==========================================
// كلاس شاشة إضافة المصروف (AddExpenseScreen)
// ==========================================
// StatefulWidget لأننا نقرأ بيانات متغيرة من المستخدم (المبلغ والملاحظة).
class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  
  // ==========================================
  // المتغيرات
  // ==========================================
  
  // متحكمات الحقول لقراءة النصوص
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  // التصنيف الافتراضي الذي يظهر أولاً
  String _selectedCategory = 'أكل';

  // ==========================================
  // دالة الإغلاق (dispose)
  // ==========================================
  // التخلص من المتحكمات عند إغلاق الشاشة لتوفير الذاكرة
  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // ==========================================
  // دالة حفظ المصروف (_saveExpense)
  // ==========================================
  // مشابهة تماماً لدالة حفظ الدخل، مع تغيير نوع العملية ولون الرسالة.
  void _saveExpense() {
    // 1. التحقق من وجود رقم
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال المبلغ')),
      );
      return;
    }

    // 2. تحويل النص إلى رقم حقيقي، والتأكد من أنه منطقي (أكبر من صفر)
    final double? amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال مبلغ صحيح')),
      );
      return;
    }

    // 3. بناء كائن العملية الجديدة (مصروف)
    final newTransaction = TransactionModel(
      id: DateTime.now().toString(), // هوية فريدة بالاعتماد على الوقت بالثانية
      title: _selectedCategory, // نعتبر اسم التصنيف هو عنوان العملية
      amount: amount,
      category: _selectedCategory,
      note: _noteController.text, // الملاحظة
      type: TransactionType.expense, // ⚠️ هذا هو الفرق الأهم: نوعها "مصروف" ليتم خصمه لاحقاً
      date: DateTime.now(), // وقت الحفظ
    );

    // 4. الإضافة من خلال الـ Provider
    Provider.of<TransactionProvider>(context, listen: false)
        .addTransaction(newTransaction);

    // 5. إظهار رسالة النجاح
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم حفظ المصروف بنجاح'),
        backgroundColor: Colors.red, // الرسالة حمراء للدلالة على الصرف
      ),
    );

    // 6. العودة للرئيسية
    Navigator.pop(context);
  }

  // ==========================================
  // بناء الواجهة (build)
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      // الشريط العلوي باللون الأحمر (للدلالة على خروج المال)
      appBar: AppBar(
        title: Container(
          alignment: Alignment.topRight,
          child: const Text('إضافة مصروف')),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            
            // -------- 1. حقل المبلغ --------
            CustomTextField(
              label: 'المبلغ (ريال)',
              controller: _amountController,
              hint: '0.00',
              keyboardType: TextInputType.number, // كيبورد الأرقام
            ),
            const SizedBox(height: 20),

            // -------- 2. اختيار التصنيف (Dropdown) --------
            const Text(
              'التصنيف',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            
            // نستخدم Consumer لنجلب قائمة التصنيفات الحية من CategoryProvider
            // هذا يعني لو أضاف المستخدم تصنيفاً جديداً في المستقبل (مثل "هدايا")، سيظهر هنا تلقائياً.
            Consumer<CategoryProvider>(
              builder: (context, categoryProvider, child) {
                
                // جلب قائمة "الأسماء" فقط
                final categories = categoryProvider.expenseCategoryNames;
                
                // التأكد من أن التصنيف الذي اخترناه (مثل "أكل") لا يزال موجوداً في القائمة
                // إذا لم يكن موجوداً (مثلاً لأن المستخدم حذفه)، نختار أول تصنيف متاح كبديل
                if (!categories.contains(_selectedCategory) && categories.isNotEmpty) {
                  _selectedCategory = categories.first;
                }
                
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCategory, // القيمة المعروضة للمستخدم
                      items: categories.map((category) {
                        // تحويل قائمة النصوص إلى عناصر قابلة للاختيار
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      // دالة التغيير
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!; // تحديث القيمة المختارة وإعادة رسم الشاشة
                        });
                      },
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // -------- 3. حقل الملاحظة --------
            CustomTextField(
              label: 'ملاحظة (اختياري)',
              controller: _noteController,
              hint: 'أدخل أي ملاحظة إضافية',
            ),
            const SizedBox(height: 30),

            // -------- 4. زر الحفظ --------
            CustomButton(
              text: 'حفظ المصروف',
              onPressed: _saveExpense,
              color: Colors.red, // زر أحمر
            ),
          ],
        ),
      ),
    );
  }
}
