// ============================================================================
// اسم الملف: transactions_screen.dart
// وظيفة الملف: شاشة لعرض قائمة بجميع العمليات المالية السابقة.
// علاقته بالمشروع: يسمح للمستخدم بتصفح تاريخ عملياته، حذفها، أو رؤية تفاصيلها.
// أين يتم استخدامه: يُنقل إليها من زر "العمليات" في الصفحة الرئيسية.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/transaction_provider.dart';
import '../models/transaction_model.dart';

// ==========================================
// كلاس شاشة العمليات (TransactionsScreen)
// ==========================================
class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      // 1. الشريط العلوي
      appBar: AppBar(
        title: Container(
          alignment: Alignment.topRight,
          child: const Text('العمليات المالية')),
        backgroundColor: const Color(0xFF2f8f83),
        foregroundColor: Colors.white,
      ),
      
      // 2. جسم الشاشة
      // نستخدم Consumer لمراقبة TransactionProvider وتحديث القائمة فور إضافة/حذف أي عملية
      body: Consumer<TransactionProvider>(
        builder: (context, transProvider, child) {
          
          // سحب قائمة العمليات من المزود
          final transactions = transProvider.transactions;

          // ==========================================
          // حالة: القائمة فارغة
          // ==========================================
          if (transactions.isEmpty) {
            // Center لوضع الرسالة في منتصف الشاشة
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 60, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    'لا توجد عمليات بعد',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          // ==========================================
          // حالة: يوجد عمليات
          // ==========================================
          // نعكس ترتيب القائمة (.reversed) ليظهر الأحدث (الذي أضيف مؤخراً) في أعلى الشاشة.
          final reversedList = transactions.reversed.toList();

          // ListView.builder: أداة قوية وموفرة للذاكرة لإنشاء القوائم الطويلة.
          // إنها "تبني" فقط العناصر التي تظهر حالياً على الشاشة، وليس كل العناصر دفعة واحدة.
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reversedList.length, // عدد العناصر
            itemBuilder: (context, index) {
              final transaction = reversedList[index];
              // دالة مساعدة رسم بطاقة العملية، نمرر لها العملية والمزود
              return _buildTransactionCard(context, transaction, transProvider);
            },
          );
        },
      ),
    );
  }

  // ============================================================
  // دالة مساعدة: بناء بطاقة العملية الواحدة
  // ============================================================
  Widget _buildTransactionCard(
    BuildContext context,
    TransactionModel transaction,
    TransactionProvider provider,
  ) {
    // تحديد متغيرات الشكل (اللون والإشارة) حسب نوع العملية (دخل أم مصروف)
    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome ? Colors.green : Colors.red;
    final sign = isIncome ? '+' : '-';

    // Card يوفر خلفية مع ظل خفيف وحواف دائرية
    return Card(
      margin: const EdgeInsets.only(bottom: 10), // مسافة تحت كل بطاقة
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      
      // ListTile: ويدجت جاهز وممتاز للقوائم (يحتوي على leading, title, subtitle, trailing)
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        
          // التفاعلات:
          // onTap: عند الضغط العادي (نقرة سريعة) نظهر نافذة التفاصيل من الأسفل.
          onTap: () => _showTransactionDetails(context, transaction, provider),
        
          // onLongPress: عند الضغط المطول، نظهر رسالة تنبيه لطلب تأكيد الحذف.
          onLongPress: () => _showDeleteDialog(context, transaction.id, provider),
        
          // الدائرة التي تحتوي الأيقونة (يمين الشاشة في العربي)
          leading: CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.1), // لون باهت
            child: Icon(
              isIncome ? Icons.arrow_downward : Icons.arrow_upward,
              color: color,
              size: 22,
            ),
          ),
          
          // العنوان (مثال: غداء الجامعة)
          title: Text(
            transaction.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          
          // النص الفرعي (يحتوي على التصنيف، والملاحظة إن وجدت، والتاريخ)
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // التصنيف (مثال: أكل)
              Text(
                transaction.category,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              // الملاحظة: نستخدم if لعرضها فقط إذا كان المستخدم قد كتب شيئاً
              if (transaction.note.isNotEmpty)
                Text(
                  transaction.note,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                  maxLines: 1, // سطر واحد فقط
                  overflow: TextOverflow.ellipsis, // وضع (...) إذا طال النص
                ),
              // التاريخ المنسق
              Text(
                '${transaction.date.day}/${transaction.date.month}/${transaction.date.year}',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
          
          // المبلغ على اليسار
          trailing: Text(
            '$sign${transaction.amount.toStringAsFixed(0)} ر',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // دالة إظهار نافذة التفاصيل من الأسفل (BottomSheet)
  // نفس الدالة المشروحة في ملف home_screen.dart
  // ============================================================
  void _showTransactionDetails(
    BuildContext context,
    TransactionModel transaction,
    TransactionProvider provider,
  ) {
    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome ? Colors.green : Colors.red;
    final typeText = isIncome ? 'دخل' : 'مصروف';
    final sign = isIncome ? '+' : '-';

    final date = transaction.date;
    final dateText =
        '${date.day}/${date.month}/${date.year}  ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: color.withValues(alpha: 0.12),
                        child: Icon(
                          isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                          color: color,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              transaction.title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                typeText,
                                style: TextStyle(
                                  color: color,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '$sign${transaction.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: color,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                      Icons.category_outlined, 'التصنيف', transaction.category),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                      Icons.calendar_today_outlined, 'التاريخ', dateText),
                  if (transaction.note.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildDetailRow(
                        Icons.notes_outlined, 'ملاحظة', transaction.note),
                  ],
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context); // إغلاق التفاصيل أولاً
                        // إظهار نافذة الحذف
                        _showDeleteDialog(context, transaction.id, provider);
                      },
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      label: const Text(
                        'حذف العملية',
                        style: TextStyle(color: Colors.red),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red, width: 1.2),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // نافذة تأكيد الحذف
  // نفس الدالة المشروحة في ملف home_screen.dart
  // ============================================================
  void _showDeleteDialog(
    BuildContext context,
    String transactionId,
    TransactionProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('حذف العملية'),
          content: const Text('هل أنت متأكد من حذف هذه العملية؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                provider.deleteTransaction(transactionId); // تنفيذ الحذف
                Navigator.pop(context); // إغلاق النافذة
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('حذف'),
            ),
          ],
        );
      },
    );
  }
}
