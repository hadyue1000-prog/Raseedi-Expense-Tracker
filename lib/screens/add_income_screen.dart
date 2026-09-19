// ============================================================================
// اسم الملف: add_income_screen.dart
// وظيفة الملف: شاشة إضافة مصدر دخل جديد (مثل: راتب، مكافأة).
// علاقته بالمشروع: يأخذ البيانات من المستخدم (مبلغ، مصدر، ملاحظة) ويحفظها كـ "عملية" (Transaction).
// أين يتم استخدامه: يُنقل إليها من زر "إضافة دخل" الأخضر في الصفحة الرئيسية.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/transaction_provider.dart';
import '../models/transaction_model.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

// ==========================================
// كلاس شاشة إضافة الدخل (AddIncomeScreen)
// ==========================================
// نوع الكلاس StatefulWidget:
// لأننا نحتاج لقراءة ما يكتبه المستخدم في الحقول (المبلغ والملاحظة)، ونحتاج لتحديث الشاشة
// عند تغيير القائمة المنسدلة (Dropdown) الخاصة بمصدر الدخل.
class AddIncomeScreen extends StatefulWidget {
  const AddIncomeScreen({super.key});

  @override
  State<AddIncomeScreen> createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends State<AddIncomeScreen> {
  
  // ==========================================
  // المتغيرات
  // ==========================================
  
  // 1. متحكمات حقول النص (Controllers) لقراءة ما يكتبه المستخدم
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  // 2. مصدر الدخل المختار حالياً (القيمة الافتراضية التي تظهر أولاً)
  String _selectedSource = 'مصروف والدين';

  // 3. قائمة مصادر الدخل الثابتة (يمكن للمستخدم الاختيار منها)
  final List<String> _sources = [
    'مصروف والدين',
    'عمل جزئي',
    'منحة دراسية',
    'جائزة',
    'أخرى',
  ];

  // ==========================================
  // دالة الإغلاق والتنظيف (dispose)
  // ==========================================
  // نحذف المتحكمات عند الخروج من الشاشة للحفاظ على الذاكرة
  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // ==========================================
  // دالة حفظ الدخل (_saveIncome)
  // ==========================================
  // تُنفذ عند الضغط على زر "حفظ الدخل" الأخضر أسفل الشاشة
  void _saveIncome() {
    // 1. التحقق: هل حقل المبلغ فارغ؟
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال المبلغ')),
      );
      return; // إيقاف التنفيذ
    }

    // 2. التحقق: هل ما كتبه المستخدم هو "رقم" فعلاً وأكبر من صفر؟
    // tryParse: تحاول تحويل النص لرقم (double)، إذا فشلت (كأن يكتب المستخدم أحرف) تعيد null.
    final double? amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال مبلغ صحيح')),
      );
      return;
    }

    // 3. تجهيز بيانات العملية الجديدة (TransactionModel)
    final newTransaction = TransactionModel(
      // نستخدم تاريخ ووقت اللحظة الحالية كـ "معرف فريد" ID (لأنه لا يتكرر)
      id: DateTime.now().toString(), 
      title: _selectedSource, // نعتبر المصدر هو عنوان العملية
      amount: amount,         // الرقم الذي تم التأكد منه
      category: _selectedSource, // التصنيف هو المصدر
      note: _noteController.text, // الملاحظة (حتى لو كانت فارغة)
      type: TransactionType.income, // نوع العملية: دخل
      date: DateTime.now(), // وقت الحفظ
    );

    // 4. إرسال العملية إلى الـ Provider ليقوم بحفظها وتحديث الرصيد
    // listen: false لأننا نستدعي دالة (لا نراقب الواجهة هنا)
    Provider.of<TransactionProvider>(context, listen: false)
        .addTransaction(newTransaction);

    // 5. عرض رسالة نجاح خضراء
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم حفظ الدخل بنجاح'),
        backgroundColor: Colors.green,
      ),
    );

    // 6. العودة للصفحة الرئيسية أوتوماتيكياً
    Navigator.pop(context);
  }

  // ==========================================
  // دالة البناء (build)
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      // الشريط العلوي بلون أخضر (للدلالة على الدخل/الإيجابية)
      appBar: AppBar(
        title: const Text('إضافة دخل'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white, // لون الأيقونات والنص
      ),
      
      // لتمكين التمرير إذا ظهرت لوحة المفاتيح
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            // -------- 1. حقل إدخال المبلغ --------
            CustomTextField(
              label: 'المبلغ (ريال)',
              controller: _amountController,
              hint: '0.00',
              // إجبار الكيبورد أن تظهر كأرقام فقط لتسهيل الإدخال
              keyboardType: TextInputType.number, 
            ),
            const SizedBox(height: 20),

            // -------- 2. قائمة اختيار المصدر (Dropdown) --------
            const Text(
              'مصدر الدخل',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            
            // حاوية لتصميم إطار القائمة المنسدلة
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline( // إخفاء الخط السفلي الافتراضي
                child: DropdownButton<String>(
                  value: _selectedSource, // القيمة المعروضة حالياً
                  // تحويل قائمة النصوص إلى قائمة من DropdownMenuItem
                  items: _sources.map((source) {
                    return DropdownMenuItem(
                      value: source,
                      child: Text(source),
                    );
                  }).toList(),
                  // تُستدعى عندما يختار المستخدم مصدراً آخر
                  onChanged: (value) {
                    // setState: تُخبر فلاتر بضرورة تحديث الواجهة لإظهار القيمة الجديدة المحددة
                    setState(() {
                      _selectedSource = value!;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // -------- 3. حقل إدخال الملاحظة (اختياري) --------
            CustomTextField(
              label: 'ملاحظة (اختياري)',
              controller: _noteController,
              hint: 'أدخل أي ملاحظة إضافية...',
            ),
            const SizedBox(height: 30),

            // -------- 4. زر الحفظ --------
            CustomButton(
              text: 'حفظ الدخل',
              onPressed: _saveIncome,
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}
