// ============================================================================
// اسم الملف: statistics_screen.dart
// وظيفة الملف: شاشة تعرض إحصائيات التطبيق (ملخص الدخل، المصروفات، الرصيد).
// علاقته بالمشروع: يعطي المستخدم نظرة عامة عن وضعه المالي بالأرقام.
// أين يتم استخدامه: يُنقل إليها من زر "الإحصائيات" البرتقالي في الصفحة الرئيسية.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/budget_provider.dart';
import '../models/transaction_model.dart';

// ==========================================
// كلاس شاشة الإحصائيات (StatisticsScreen)
// ==========================================
// الشاشة StatelessWidget لكن محتواها يتحدث باستخدام Consumer2.
class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Consumer2: نستمع لمزود العمليات ومزود الميزانية في نفس الوقت
    return Consumer2<TransactionProvider, BudgetProvider>(
      builder: (context, transProvider, budgetProvider, child) {
        // ==========================================
        // 1. جلب البيانات وحساب الإحصائيات
        // ==========================================
        final transactions = transProvider.transactions;
        final totalIncome = transProvider.getTotalIncome();
        final totalExpense = transProvider.getTotalExpense();
        final balance = transProvider.getBalance();
        final biggestExpense = transProvider.getBiggestExpense();
        final budget = budgetProvider.monthlyBudget;

        // حساب عدد عمليات الدخل فقط باستخدام فلترة (where)
        final incomeCount = transactions
            .where((t) => t.type == TransactionType.income)
            .length;

        // حساب عدد عمليات المصروفات فقط
        final expenseCount = transactions
            .where((t) => t.type == TransactionType.expense)
            .length;

        // ==========================================
        // 2. بناء الواجهة
        // ==========================================
        return Scaffold(
          appBar: AppBar(
            title: Container(
              alignment: Alignment.topRight,
              child: const Text('الإحصائيات'),
            ),
            backgroundColor:
                Theme.of(context).appBarTheme.backgroundColor ??
                Theme.of(context).colorScheme.primary,
            foregroundColor:
                Theme.of(context).appBarTheme.foregroundColor ??
                Theme.of(context).colorScheme.onPrimary,
          ),

          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // -------- قسم الملخص الشامل --------
                const Text(
                  'ملخص مالي شامل',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // بطاقات الإحصائيات الرئيسية (باستخدام الدالة المساعدة بالأسفل)
                _buildStatCard(
                  context: context,
                  label: 'إجمالي الدخل',
                  value: '${totalIncome.toStringAsFixed(2)} ريال',
                  icon: Icons.arrow_downward,
                  color: Colors.green,
                ),
                const SizedBox(height: 10),
                _buildStatCard(
                  context: context,
                  label: 'إجمالي المصروفات',
                  value: '${totalExpense.toStringAsFixed(2)} ريال',
                  icon: Icons.arrow_upward,
                  color: Colors.red,
                ),
                const SizedBox(height: 10),

                // الرصيد: نلونه أحمر إذا كان بالسالب، وبنفسجي إذا كان موجباً
                _buildStatCard(
                  context: context,
                  label: 'الرصيد الحالي',
                  value: '${balance.toStringAsFixed(2)} ريال',
                  icon: Icons.account_balance_wallet,
                  color: balance >= 0
                      ? Theme.of(context).colorScheme.primary
                      : Colors.red,
                ),
                const SizedBox(height: 10),

                // أكبر مصروف (نتحقق أولاً إذا كان هناك مصروف أصلاً)
                _buildStatCard(
                  context: context,
                  label: 'أكبر مصروف',
                  value: biggestExpense > 0
                      ? '${biggestExpense.toStringAsFixed(2)} ريال'
                      : 'لا يوجد', // إذا لم يسجل أي مصروف
                  icon: Icons.trending_up,
                  color: Colors.deepOrange,
                ),
                const SizedBox(height: 10),

                _buildStatCard(
                  context: context,
                  label: 'الميزانية الشهرية',
                  value: '${budget.toStringAsFixed(0)} ريال',
                  icon: Icons.savings,
                  color: Colors.teal,
                ),
                const SizedBox(height: 24),

                // -------- قسم عداد العمليات --------
                const Text(
                  'تفاصيل العمليات',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                // 3 صناديق بجانب بعضها لعدد العمليات
                Row(
                  children: [
                    Expanded(
                      child: _buildCountCard(
                        label: 'عمليات الدخل',
                        count: incomeCount,
                        color: Colors.green,
                        icon: Icons.add_circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildCountCard(
                        label: 'عمليات المصروف',
                        count: expenseCount,
                        color: Colors.red,
                        icon: Icons.remove_circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildCountCard(
                        label: 'الإجمالي',
                        count: transactions.length, // كل العمليات
                        color: Theme.of(context).colorScheme.primary,
                        icon: Icons.receipt,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // -------- قسم المقارنة البصرية --------
                const Text(
                  'مقارنة الدخل والمصروفات',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                // شريط الدخل
                _buildSimpleBar(
                  context: context,
                  label: 'الدخل',
                  amount: totalIncome,
                  // نرسل أكبر رقم بين الدخل والمصروف ليكون هو 100% في الشريط
                  maxAmount: totalIncome > totalExpense
                      ? totalIncome
                      : totalExpense,
                  color: Colors.green,
                ),
                const SizedBox(height: 10),

                // شريط المصروفات
                _buildSimpleBar(
                  context: context,
                  label: 'المصروفات',
                  amount: totalExpense,
                  maxAmount: totalIncome > totalExpense
                      ? totalIncome
                      : totalExpense,
                  color: Colors.red,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // دوال مساعدة (Helper Widgets) لتجنب تكرار الكود
  // ============================================================

  // 1. بطاقة إحصاء عريضة (أيقونة، عنوان، مبلغ)
  Widget _buildStatCard({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                label,
                style:
                    Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.75),
                      fontSize: 13,
                    ) ??
                    const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          CircleAvatar(
            radius: 22,
            backgroundColor: color.withValues(alpha: 0.1),
            child: Icon(icon, color: color, size: 22),
          ),
        ],
      ),
    );
  }

  // 2. صندوق عداد صغير (لعدد العمليات)
  Widget _buildCountCard({
    required String label,
    required int count,
    required Color color,
    required IconData icon,
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
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            '$count', // الرقم
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label, // النص الصغير تحته
            textAlign: TextAlign.center,
            style: TextStyle(color: color, fontSize: 10),
          ),
        ],
      ),
    );
  }

  // 3. شريط نسبة بصري (شريط يمتلئ حسب الرقم)
  Widget _buildSimpleBar({
    required BuildContext context,
    required String label,
    required double amount,
    required double maxAmount,
    required Color color,
  }) {
    // حساب نسبة الامتلاء للشريط (رقم بين 0.0 و 1.0)
    final ratio = maxAmount > 0 ? (amount / maxAmount) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // النص أعلى الشريط
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${amount.toStringAsFixed(0)} ريال',
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 6),

        // الشريط البصري
        Container(
          height: 14,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(7),
          ),
          // الجزء الملون من الشريط الذي يتمدد حسب النسبة
          child: FractionallySizedBox(
            alignment: AlignmentDirectional
                .centerStart, // يبدأ الامتلاء من جهة البدء في اللغة الحالية
            widthFactor: ratio.toDouble(), // نسبة العرض
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(7),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
