// ============================================================================
// اسم الملف: home_screen.dart
// وظيفة الملف: الشاشة الرئيسية للتطبيق (الواجهة الأساسية).
// علاقته بالمشروع: هي لوحة التحكم (Dashboard) التي تعرض الرصيد الحالي، الإحصائيات السريعة، وأزرار التنقل.
// أين يتم استخدامه: هي الشاشة التي تفتح بعد تسجيل الدخول.
// ============================================================================

import 'package:flutter/material.dart';
// استيراد Provider للوصول إلى البيانات
import 'package:provider/provider.dart';

// استيراد المزودات (Providers) التي سنحتاج قراءة بياناتها
import '../providers/transaction_provider.dart';
import '../providers/budget_provider.dart';
import '../providers/auth_provider.dart';
import '../models/transaction_model.dart';

// استيراد التصاميم والشاشات الأخرى
import '../widgets/summary_card.dart';
import 'add_expense_screen.dart';
import 'add_income_screen.dart';
import 'transactions_screen.dart';
import 'statistics_screen.dart';
import 'settings_screen.dart';
import 'ai_chat_screen.dart';

// ==========================================
// كلاس الشاشة الرئيسية (HomeScreen)
// ==========================================
// StatelessWidget لأن الشاشة تستمد تغيراتها من الـ Providers (عبر الـ Consumer)
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Consumer2: ويدجت ذكي يراقب اثنين Providers في نفس الوقت 
    // (TransactionProvider للعمليات، و BudgetProvider للميزانية).
    // كلما تغيرت بيانات أحدهما، سيتم إعادة رسم الشاشة هنا فقط لتحديث الأرقام.
    return Consumer2<TransactionProvider, BudgetProvider>(
      builder: (context, transProvider, budgetProvider, child) {
        
        // 1. جلب الأرقام من المزودات (Providers)
        final balance = transProvider.getBalance();
        final totalIncome = transProvider.getTotalIncome();
        final totalExpense = transProvider.getTotalExpense();
        final monthlyBudget = budgetProvider.monthlyBudget;
        
        // جلب اسم المستخدم من AuthProvider (نستخدم listen: false لأننا لا نتوقع أن يتغير اسمه وهو في هذه الشاشة)
        final authProvider = Provider.of<AuthProvider>(context, listen: false);

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          
          // ==========================================
          // الشريط العلوي (AppBar)
          // ==========================================
          appBar: AppBar(
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).colorScheme.primary,
            elevation: 0,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  );
                },
              ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                
                  children: [
                    Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'رصيدي',
                      style: Theme.of(context).appBarTheme.titleTextStyle ?? const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 2,),
                    Text(
                      'مرحباً، ${authProvider.userName}',
                      style: Theme.of(context).appBarTheme.toolbarTextStyle ?? const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
                  Image.asset("icon/logo.png",width: 70),
                
                  ],
                
                ),
              ],
            ),
            
          ),
          
          // ==========================================
          // جسم الشاشة (Body)
          // ==========================================
          body: SingleChildScrollView( // لتمكين التمرير
            child: Column(
              children: [
                
                // -------- 1. بطاقة الرصيد الكبيرة --------
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).colorScheme.primary,
                    // تدوير الزوايا السفلية فقط لتبدو متصلة بالشريط العلوي
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'الرصيد الحالي',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white70, fontSize: 16) ?? const TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${balance.toString()} ريال يمني',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // -------- 2. ملخص الأرقام (الدخل، المصروفات، الميزانية) --------
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      // Expanded يجعل العنصر يتمدد ليملأ نصف المساحة المتاحة
                      Expanded(
                        child: SummaryCard(
                          title: 'الدخل',
                          amount: totalIncome.toString(),
                          color: Colors.green,
                          icon: Icons.arrow_downward,
                        ),
                      ),
                      const SizedBox(width: 12), // فاصل بين البطاقتين
                      Expanded(
                        child: SummaryCard(
                          title: 'المصروفات',
                          amount: totalExpense.toStringAsFixed(0),
                          color: Colors.red,
                          icon: Icons.arrow_upward,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SummaryCard(
                    title: 'الميزانية الشهرية',
                    amount: monthlyBudget.toStringAsFixed(0),
                    color: const Color(0xFF2f8f83),
                    icon: Icons.savings,
                  ),
                ),
                 const SizedBox(height: 12),



                // -------- 3. الإجراءات السريعة (الأزرار الأربعة) --------
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'الإجراءات السريعة',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          // نستخدم دالة مساعدة _buildActionButton لإنشاء الأزرار بشكل مرتب
                          _buildActionButton(
                            context,
                            icon: Icons.remove_circle_outline,
                            label: 'إضافة مصروف',
                            color: Colors.red,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AddExpenseScreen(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          _buildActionButton(
                            context,
                            icon: Icons.add_circle_outline,
                            label: 'إضافة دخل',
                            color: Colors.green,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AddIncomeScreen(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          _buildActionButton(
                            context,
                            icon: Icons.list_alt,
                            label: 'العمليات',
                            color: Theme.of(context).colorScheme.primary,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const TransactionsScreen(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          _buildActionButton(
                            context,
                            icon: Icons.bar_chart,
                            label: 'الإحصائيات',
                            color: Colors.orange,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const StatisticsScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // -------- 4. آخر العمليات وشريط البحث --------
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'آخر العمليات',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // شريط البحث
                      TextField(
                        textAlign: TextAlign.end,
                        // بمجرد أن يكتب المستخدم أي حرف (value)، نرسله إلى الـ Provider
                        onChanged: (value) {
                          transProvider.setSearchQuery(value);
                        },
                        decoration: InputDecoration(
                          hintText: '  ... ابحث عن عملية',
                          suffixIcon: const Icon(Icons.search),
                           
                          
                          
                          filled: true, // تلوين خلفية الحقل
                          fillColor: Theme.of(context).inputDecorationTheme.fillColor ?? Colors.white,
                          contentPadding: const EdgeInsets.symmetric(vertical: 0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none, // بدون إطار أسود
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // التحقق: هل القائمة فارغة بعد البحث؟
                      if (transProvider.filteredTransactions.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Text(
                              'لا توجد عمليات تطابق بحثك',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                      else
                        // إذا كان هناك عمليات، نعرض آخر 5 منها فقط
                        // نستخدم spread operator (...) لدمج القائمة داخل الـ Column
                        ...transProvider.filteredTransactions.reversed
                            .take(5) // نأخذ 5 عناصر كحد أقصى
                            .map((transaction) {
                          
                          // تحديد لون الأيقونة حسب نوع العملية
                          final isIncome =
                              transaction.type == TransactionType.income;
                          final color = isIncome ? Colors.green : Colors.red;

                          return Card(

                            margin: const EdgeInsets.only(bottom: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Directionality(
                              textDirection: TextDirection.rtl,
                              child: ListTile(
                                
                                // عند الضغط على العملية، نظهر نافذة التفاصيل
                                onTap: () => _showTransactionDetails(
                                  context,
                                  transaction,
                                  transProvider,
                                ),
                                leading: CircleAvatar(
                                  backgroundColor: color.withValues(alpha: 0.1),
                                  child: Icon(
                                    isIncome
                                        ? Icons.arrow_downward
                                        : Icons.arrow_upward,
                                    color: color,
                                    size: 20,
                                  ),
                                ),
                                title: Text(
                                  transaction.title,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  transaction.category,
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                                trailing: Text(
                                  '${isIncome ? "+" : "-"}${transaction.amount.toStringAsFixed(0)} ر.ي',
                                  style: TextStyle(
                                    color: color,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          
          // ==========================================
          // الزر العائم (Floating Action Button) للذكاء الاصطناعي
          // ==========================================
          // وضعناه في الأسفل على اليسار (أو اليمين حسب اللغة)
          floatingActionButton: AnimatedAiFab(),
        );
      },
    );
  }

  // ============================================================
  // دالة إظهار نافذة تفاصيل العملية (BottomSheet)
  // ============================================================
  // تنبثق من أسفل الشاشة عند الضغط على أي عملية.
  void _showTransactionDetails(
    BuildContext context,
    TransactionModel transaction,
    TransactionProvider provider,
  ) {
    // تجهيز البيانات
    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome ? Colors.green : Colors.red;
    final typeText = isIncome ? 'دخل' : 'مصروف';
    final sign = isIncome ? '+' : '-';

    // تنسيق التاريخ والوقت
    final date = transaction.date;
    final dateText =
        '${date.day}/${date.month}/${date.year}  ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    // فتح النافذة المنبثقة
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // لتسمح للنافذة بأخذ الحجم الذي تحتاجه
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)), // زوايا علوية دائرية
      ),
      builder: (context) {
        return Padding(
          // viewInsets يضيف مسافة إضافية من الأسفل في حال ظهرت لوحة المفاتيح
          padding: MediaQuery.of(context).viewInsets,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  
                  // مقبض التمرير الرمادي الصغير بالأعلى
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

                  // عنوان ومبلغ العملية
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '$sign${transaction.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: color,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),),
                      
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              transaction.title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            // شريحة صغيرة توضح نوع العملية
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
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),

                      CircleAvatar(
                        radius: 28,
                        backgroundColor: color.withValues(alpha: 0.12),
                        child: Icon(
                          isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                          color: color,
                          size: 28,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  const Divider(), // خط فاصل
                  const SizedBox(height: 16),

                  // صفوف التفاصيل
                  _buildDetailRow(Icons.category_outlined, 'التصنيف', transaction.category),
                  const SizedBox(height: 12),
                  _buildDetailRow(Icons.calendar_today_outlined, 'التاريخ', dateText),

                  // إظهار حقل الملاحظة فقط إذا كان يوجد نص
                  if (transaction.note.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildDetailRow(Icons.notes_outlined, 'ملاحظة', transaction.note),
                  ],

                  const SizedBox(height: 28),

                  // زر حذف العملية
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // 1. نغلق النافذة المنبثقة أولاً
                        Navigator.pop(context);
                        // 2. نعرض صندوق تأكيد الحذف
                        _showDeleteDialog(context, transaction.id, provider);
                      },
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      label: const Text(
                        'حذف العملية',
                        style: TextStyle(color: Colors.red),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red, width: 1.2), // حدود حمراء
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

  // دالة مساعدة لرسم صف يحتوي على تفصيلة واحدة
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
           Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                label, // اسم الحقل (مثل: التصنيف)
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 2),
              Text(
                value, // القيمة (مثل: أكل)
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ],

        ),
                const SizedBox(width: 12),

         Icon(icon, size: 20, color: Colors.grey[600]),
      ],
    );
  }

  // ============================================================
  // نافذة تنبيه: تأكيد الحذف (AlertDialog)
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
            // زر التراجع
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            // زر التأكيد
            TextButton(
              onPressed: () {
                // استدعاء دالة الحذف من الـ Provider
                provider.deleteTransaction(transactionId);
                // إغلاق نافذة التنبيه
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red), // تلوين الزر بالأحمر
              child: const Text('حذف'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // دالة مساعدة: تصميم زر من الأزرار الأربعة السريعة
  // ============================================================
  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded( // لكي تأخذ الأزرار مسافات متساوية
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              // إضافة ظل خفيف للزر
              BoxShadow(
                color: Theme.of(context).shadowColor.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: TextStyle(
                  fontSize: 10,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// كلاس خاص بالزر العائم للمساعد الذكي مع حركة نابضة (Animation)
// ============================================================
// نستخدم StatefulWidget لأننا نحتاج للتحكم بحالة الحركة (AnimationController)
class AnimatedAiFab extends StatefulWidget {
  const AnimatedAiFab({super.key});

  @override
  State<AnimatedAiFab> createState() => _AnimatedAiFabState();
}

// with SingleTickerProviderStateMixin: ضرورية للسماح للودجت بتحديث الشاشة مع كل فريم من الحركة
class _AnimatedAiFabState extends State<AnimatedAiFab>
    with SingleTickerProviderStateMixin {
  
  // المتحكم بالحركة
  late AnimationController _controller;
  // قيمة التكبير والتصغير
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // إعداد الحركة لتستغرق ثانيتين، وتكرر نفسها ذهاباً وإياباً (reverse: true)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // نحدد مدى التكبير: من الحجم الطبيعي 1.0 إلى 1.1 
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut), // نوع حركة ناعم
    );
  }

  @override
  void dispose() {
    // يجب التخلص من المتحكم عند الخروج لمنع الأخطاء واستهلاك الذاكرة
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ScaleTransition تطبق حركة التكبير/التصغير على الزر العائم
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FloatingActionButton(
        onPressed: () {
          // فتح شاشة الدردشة الذكية
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AiChatScreen(),
            ),
          );
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 8,
        child: Icon(Icons.smart_toy, color: Theme.of(context).colorScheme.onPrimary, size: 30), // أيقونة روبوت
      ),
    );
  }
}
