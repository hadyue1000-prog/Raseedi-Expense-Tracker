// ============================================================================
// اسم الملف: transaction_provider.dart
// وظيفة الملف: المخزن الرئيسي لجميع العمليات المالية (الدخل والمصروفات).
// علاقته بالمشروع: هو قلب التطبيق المالي، حيث يتم إضافة وحذف وحساب العمليات من هنا.
// أين يتم استخدامه: تقريباً في كل شاشات التطبيق (الرئيسية، العمليات، الإحصائيات، إضافة مصروف...).
// ============================================================================

import 'package:flutter/material.dart';
import '../models/transaction_model.dart';

// ==========================================
// كلاس مزود العمليات المالية (TransactionProvider)
// ==========================================
// يرث من ChangeNotifier لتحديث الواجهة فور إضافة أو حذف أي عملية.
class TransactionProvider extends ChangeNotifier {
  
  // ==========================================
  // المتغيرات الخاصة (Private Variables)
  // ==========================================
  
  // قائمة (List) تحتوي على جميع العمليات المالية التي تم إنشاؤها من كلاس TransactionModel
  // ⚠️ ملاحظة: هذه البيانات محفوظة "مؤقتاً في الذاكرة" حالياً.
  // إذا تم إغلاق التطبيق ستضيع البيانات. في التطبيقات الحقيقية يجب ربطها بقاعدة بيانات أو تخزين محلي.
  final List<TransactionModel> _transactions = [
    // أضفنا 3 عمليات افتراضية تظهر للمستخدم أول مرة يفتح فيها التطبيق ليجربه
    
    
    
  ];

  // ==========================================
  // دوال القراءة (Getters)
  // ==========================================
  
  // تُرجع قائمة العمليات كاملة لاستخدامها في الشاشات
  List<TransactionModel> get transactions => _transactions;

  // ==========================================
  // نظام البحث (Search)
  // ==========================================
  
  // نخزن فيه الكلمة التي يبحث عنها المستخدم في شريط البحث
  String _searchQuery = '';

  // دالة تُستدعى كلما كتب المستخدم حرفاً في شريط البحث
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners(); // نُحدث الواجهة لتظهر نتائج البحث فوراً
  }

  // هذه دالة ذكية تُرجع "العمليات المفلترة" بناءً على كلمة البحث
  // تُستخدم في شاشة العمليات (TransactionsScreen) لعرض النتائج
  List<TransactionModel> get filteredTransactions {
    // إذا كان شريط البحث فارغاً، نعيد القائمة كاملة
    if (_searchQuery.isEmpty) return _transactions;
    
    // عملية الفلترة (where): تبحث داخل كل عنصر في القائمة
    return _transactions.where((t) {
      // نحول كل النصوص للحروف الصغيرة (toLowerCase) لتجاهل حالة الأحرف في الإنجليزي
      final query = _searchQuery.toLowerCase();
      // نعيد true (ليظهر العنصر) إذا كان العنوان أو التصنيف يحتوي على كلمة البحث
      return t.title.toLowerCase().contains(query) ||
          t.category.toLowerCase().contains(query);
    }).toList(); // نحول النتيجة النهائية إلى قائمة List
  }

  // ==========================================
  // دوال إضافة وحذف العمليات
  // ==========================================
  
  // دالة إضافة عملية جديدة
  // تُستدعى من شاشة "إضافة دخل" أو "إضافة مصروف" أو "المساعد الذكي"
  void addTransaction(TransactionModel transaction) {
    _transactions.add(transaction); // نضيف العملية للقائمة
    notifyListeners(); // نخبر الشاشات بتحديث الرصيد والقوائم
  }

  // دالة حذف عملية
  // تُستدعى عند السحب للحذف أو من زر الحذف
  void deleteTransaction(String id) {
    // نبحث عن العملية التي تحمل نفس المعرف (id) ونحذفها
    _transactions.removeWhere((transaction) => transaction.id == id);
    notifyListeners(); // نحدث الشاشات ليعاد حساب الرصيد
  }

  // ==========================================
  // دوال الحسابات الرياضية والإحصائيات
  // ==========================================
  
  // دالة تحسب مجموع كل عمليات الدخل
  double getTotalIncome() {
    double total = 0;
    // نمر (حلقة تكرارية loop) على كل العمليات
    for (var transaction in _transactions) {
      // نتحقق إذا كان نوع العملية دخل (income)
      if (transaction.type == TransactionType.income) {
        total += transaction.amount; // نجمع المبلغ للرقم الكلي
      }
    }
    return total;
  }

  // دالة تحسب مجموع كل المصروفات
  double getTotalExpense() {
    double total = 0;
    for (var transaction in _transactions) {
      if (transaction.type == TransactionType.expense) {
        total += transaction.amount;
      }
    }
    return total;
  }

  // دالة تحسب الرصيد المتبقي (إجمالي الدخل ناقص إجمالي المصروفات)
  double getBalance() {
    return getTotalIncome() - getTotalExpense();
  }

  // دالة تجد أكبر مصروف قام به المستخدم
  // تُستخدم لعرض "أكبر مصروف" في الصفحة الرئيسية
  double getBiggestExpense() {
    // 1. نصنع قائمة مصغرة تحتوي على المصروفات فقط
    final expenses = _transactions
        .where((t) => t.type == TransactionType.expense)
        .toList();

    // 2. إذا لم يقم بأي مصروف، نرجع 0
    if (expenses.isEmpty) return 0;

    // 3. نفترض مبدئياً أن أول مصروف هو الأكبر
    double biggest = expenses[0].amount;
    
    // 4. نقارن باقي المصروفات بهذا الرقم
    for (var expense in expenses) {
      if (expense.amount > biggest) {
        biggest = expense.amount; // إذا وجدنا أكبر، نبدله
      }
    }
    return biggest;
  }
}
