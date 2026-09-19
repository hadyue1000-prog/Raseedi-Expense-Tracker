// ============================================================================
// اسم الملف: category_provider.dart
// وظيفة الملف: يتحكم في قائمة التصنيفات الخاصة بالمصروفات (مثل: أكل، مواصلات).
// علاقته بالمشروع: يوفر للمستخدم قائمة جاهزة ليختار منها عند إضافة مصروف جديد.
// أين يتم استخدامه: في شاشة CategoriesScreen، وشاشة إضافة مصروف (AddExpenseScreen).
// ============================================================================

import 'package:flutter/material.dart';

// ==========================================
// كلاس مزود تصنيفات المصروفات (CategoryProvider)
// ==========================================
// يرث من ChangeNotifier لتحديث القوائم المنسدلة (Dropdowns) عند إضافة أو حذف تصنيف.
class CategoryProvider extends ChangeNotifier {
  
  // ==========================================
  // المتغيرات الخاصة (Private Variables)
  // ==========================================
  
  // قائمة تحتوي على التصنيفات. كل تصنيف يمثل قاموس (Map) يحتوي على اسم وأيقونة ولون ووصف.
  // تم وضع بيانات افتراضية شائعة لمساعدة المستخدم المبتدئ.
  final List<Map<String, dynamic>> _expenseCategories = [
    {
      'name': 'أكل', // اسم التصنيف
      'icon': Icons.restaurant, // أيقونة التصنيف
      'color': Colors.orange, // لون الأيقونة
      'description': 'وجبات، مطاعم، مقاهي', // وصف بسيط
      'isCustom': false, // هل هو تصنيف أساسي (لا يمكن حذفه) أم مخصص؟
    },
    {
      'name': 'مواصلات',
      'icon': Icons.directions_bus,
      'color': Colors.blue,
      'description': 'باص، تاكسي، وقود',
      'isCustom': false,
    },
    {
      'name': 'دراسة',
      'icon': Icons.school,
      'color': Colors.purple,
      'description': 'كتب، قرطاسية، رسوم',
      'isCustom': false,
    },
    {
      'name': 'إنترنت',
      'icon': Icons.wifi,
      'color': Colors.teal,
      'description': 'اشتراكات إنترنت وتطبيقات',
      'isCustom': false,
    },
    {
      'name': 'سكن',
      'icon': Icons.home,
      'color': Colors.brown,
      'description': 'إيجار، فواتير، صيانة',
      'isCustom': false,
    },
    {
      'name': 'أخرى',
      'icon': Icons.more_horiz,
      'color': Colors.grey,
      'description': 'مصروفات متنوعة أخرى',
      'isCustom': false, // تصنيف عام للأشياء التي ليس لها تصنيف
    },
  ];

  // ==========================================
  // دوال القراءة (Getters)
  // ==========================================
  
  // دالة تُرجع قائمة التصنيفات كاملة (بكل تفاصيلها من أيقونات وألوان)
  // تُستخدم في شاشة CategoriesScreen لعرضها كبطاقات
  List<Map<String, dynamic>> get expenseCategories => _expenseCategories;

  // دالة ذكية تُرجع "قائمة بأسماء التصنيفات فقط" 
  // مثلاً: ['أكل', 'مواصلات', 'دراسة'...]
  // تُستخدم بشكل أساسي في شاشة إضافة مصروف لإنشاء القائمة المنسدلة (DropdownMenu)
  List<String> get expenseCategoryNames => 
      // استخدام map() للمرور على كل قاموس واستخراج قيمة الـ 'name' فقط
      _expenseCategories.map((c) => c['name'] as String).toList();

  // ==========================================
  // دوال الإضافة والحذف
  // ==========================================
  
  // دالة لإضافة تصنيف جديد (مخصص من قِبل المستخدم)
  // تُستدعى من نافذة (Dialog) إضافة التصنيف
  void addCategory(Map<String, dynamic> category) {
    _expenseCategories.add(category);
    // ⚠️ استدعاء notifyListeners سيقوم بتحديث القوائم المنسدلة في شاشة إضافة المصروف لتشمل التصنيف الجديد
    notifyListeners();
  }

  // دالة لحذف التصنيفات المخصصة
  // لا تُستخدم حالياً بشكل كبير، لكنها مجهزة للسماح للمستخدم بحذف تصنيفاته المخصصة بناءً على الفهرس (index)
  void deleteCategory(int index) {
    _expenseCategories.removeAt(index);
    notifyListeners();
  }
}
