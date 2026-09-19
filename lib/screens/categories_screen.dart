// ============================================================================
// اسم الملف: categories_screen.dart
// وظيفة الملف: شاشة لعرض وإدارة التصنيفات المتاحة للمصروفات.
// علاقته بالمشروع: تتيح للمستخدم رؤية التصنيفات الجاهزة، وإضافة تصنيفات جديدة بلمسته الخاصة، وحذفها.
// أين يتم استخدامه: يُنقل إليها من الإعدادات (SettingsScreen).
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';

// ==========================================
// كلاس شاشة التصنيفات (CategoriesScreen)
// ==========================================
// StatefulWidget لأننا نحتاج للتحكم باختيارات الألوان والأيقونات عند إضافة تصنيف جديد.
class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  
  // ==========================================
  // المتغيرات (لإضافة تصنيف جديد)
  // ==========================================
  
  // قائمة ببعض الألوان الجميلة التي يختار منها المستخدم لون تصنيفه الجديد
  final List<Color> _availableColors = [
    Colors.red, Colors.pink, Colors.purple, Colors.deepPurple,
    Colors.indigo, Colors.blue, Colors.teal, Colors.green,
    Colors.lime, Colors.orange, Colors.brown, Colors.grey,
  ];

  // قائمة ببعض الأيقونات التي تعبر عن مصروفات مختلفة
  final List<IconData> _availableIcons = [
    Icons.shopping_bag, Icons.sports_esports, Icons.local_hospital,
    Icons.fitness_center, Icons.music_note, Icons.movie,
    Icons.flight, Icons.coffee, Icons.pets, Icons.celebration,
    Icons.build, Icons.work, Icons.card_giftcard, Icons.phone_android,
    Icons.attach_money, Icons.star,
  ];

  // ============================================================
  // دالة إظهار نافذة منبثقة لإضافة تصنيف جديد
  // ============================================================
  void _showAddCategoryDialog() {
    // متحكمات الحقول داخل النافذة المنبثقة
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descController = TextEditingController();
    
    // قيم افتراضية مبدئية للون والأيقونة
    Color selectedColor = Colors.teal;
    IconData selectedIcon = Icons.shopping_bag;

    // showDialog تفتح صندوق حوار (AlertDialog) فوق الشاشة الحالية
    showDialog(
      context: context,
      builder: (context) {
        // StatefulBuilder: نستخدمه لكي نتمكن من تغيير شكل (اللون/الأيقونة) 
        // داخل الـ Dialog فوراً عند الضغط عليها، دون الحاجة لتحديث الشاشة الكاملة.
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('إضافة تصنيف جديد'),
                  SizedBox(width: 8),
                  Icon(Icons.add_circle, color: Color(0xFF2f8f83)),
                  
                ],
              ),
              content: SingleChildScrollView( // لتمكين التمرير لو كبرت الشاشة
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    
                    // -------- حقل اسم التصنيف --------
                    TextField(
                      textAlign: TextAlign.end,
                      controller: nameController,
                      decoration: InputDecoration(
                        //labelText: 'اسم التصنيف ',
                        label: Text(" التصنيف",textAlign: TextAlign.end,),
                        
                        

                        hintText: 'مثال: رياضة',
                         
                      ),
                      // عند الكتابة نُحدث النافذة ليظهر النص في مربع المعاينة بالأسفل
                      onChanged: (val) => setDialogState(() {}),
                    ),
                    const SizedBox(height: 12),
                    
                    // -------- حقل الوصف --------
                    TextField(
                      controller: descController,
                      decoration: const InputDecoration(
                        labelText: ' الوصف',
                        hintText: 'مثال: اشتراكات نادي رياضي',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // -------- اختيار اللون --------
                    const Text(
                      'اختر اللون',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    // Wrap: مثل الـ Row لكن ينزل للسطر الجديد تلقائياً إذا انتهت المساحة (ممتاز للشبكات)
                    Wrap(
                      spacing: 8, // المسافة الأفقية
                      runSpacing: 8, // المسافة العمودية
                      children: _availableColors.map((color) {
                        final isSelected = selectedColor == color;
                        return GestureDetector(
                          // عند الضغط نغير اللون المختار
                          onTap: () => setDialogState(() => selectedColor = color),
                          // AnimatedContainer لجعل الانتقال ناعماً عند الاختيار
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              // إذا كان اللون مختاراً نضع له إطاراً أبيض وظل خفيف
                              border: isSelected
                                  ? Border.all(color: Colors.white, width: 3)
                                  : null,
                              boxShadow: isSelected
                                  ? [BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 8)]
                                  : null,
                            ),
                            // نضع علامة "صح" صغيرة داخل اللون المختار
                            child: isSelected
                                ? const Icon(Icons.check, color: Colors.white, size: 16)
                                : null,
                          ),
                        );
                      }).toList(), // تحويل الـ map إلى List
                    ),
                    const SizedBox(height: 16),

                    // -------- اختيار الأيقونة --------
                    const Text(
                      'اختر الأيقونة',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableIcons.map((icon) {
                        final isSelected = selectedIcon == icon;
                        return GestureDetector(
                          onTap: () => setDialogState(() => selectedIcon = icon),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              // نلون خلفية الأيقونة إذا كانت مختارة
                              color: isSelected
                                  ? selectedColor.withValues(alpha: 0.2)
                                  : Colors.grey.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: isSelected
                                  ? Border.all(color: selectedColor, width: 2)
                                  : null,
                            ),
                            child: Icon(
                              icon,
                              color: isSelected ? selectedColor : Colors.grey,
                              size: 22,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // -------- معاينة حية للتصنيف --------
                    // تظهر فقط إذا كتب المستخدم شيئاً في حقل الاسم
                    if (nameController.text.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: selectedColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: selectedColor.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(selectedIcon, color: selectedColor),
                            const SizedBox(width: 10),
                            Text(
                              nameController.text,
                              style: TextStyle(
                                color: selectedColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
               actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // تحقق من أن الاسم غير فارغ
                    if (nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('يرجى إدخال اسم التصنيف')),
                      );
                      return;
                    }
                    
                    // حفظ التصنيف في Provider ليتوفر في كل التطبيق (مثل شاشة إضافة المصروف)
                    Provider.of<CategoryProvider>(context, listen: false).addCategory({
                      'name': nameController.text.trim(),
                      'icon': selectedIcon,
                      'color': selectedColor,
                      'description': descController.text.trim().isEmpty
                          ? 'تصنيف مخصص'
                          : descController.text.trim(),
                      'isCustom': true, // نضع true لنميزه عن التصنيفات الأصلية (لكي نسمح بحذفه لاحقاً)
                    });
                    
                    Navigator.pop(context); // إغلاق النافذة

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('تم إضافة تصنيف "${nameController.text.trim()}" بنجاح'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('إضافة'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.all(8),
                    backgroundColor: const Color(0xFF2f8f83),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
              // أزرار الحفظ والإلغاء للنافذة
             
            );
          },
        );
      },
    );
  }

  // ============================================================
  // دالة حذف التصنيفات المخصصة
  // ============================================================
  void _deleteCategory(int index, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف التصنيف'),
        content: Text('هل أنت متأكد من حذف تصنيف "$name"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<CategoryProvider>(context, listen: false).deleteCategory(index);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('تم حذف تصنيف "$name"')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // بناء الواجهة الرئيسية للشاشة (build)
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, child) {
        final categories = categoryProvider.expenseCategories;
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('التصنيفات'),
          ),
          
          // زر عائم بأسفل الشاشة (بجانبه نص) لفتح نافذة الإضافة
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _showAddCategoryDialog,
            backgroundColor: const Color(0xFF2f8f83),
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('تصنيف جديد'),
          ),
          
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تصنيفاتك (${categories.length})', // إظهار العدد الإجمالي
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                
                // عرض التصنيفات كشبكة (Grid) 
                Expanded(
                  child: GridView.builder(
                    // إعدادات الشبكة
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // عنصرين في كل سطر
                      crossAxisSpacing: 12, // المسافة الأفقية
                      mainAxisSpacing: 12,  // المسافة العمودية
                      childAspectRatio: 1.3, // نسبة العرض إلى الارتفاع (مستطيل عرضي)
                    ),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      // نتأكد هل التصنيف من صنع المستخدم أم أساسي؟
                      final isCustom = category['isCustom'] as bool;
                      
                      // نستخدم Stack لنتمكن من وضع عناصر فوق البطاقة (مثل زر الحذف وشارة مخصص)
                      return Stack(
                        children: [
                          
                          // بطاقة التصنيف (نستخدم الدالة المساعدة _buildCategoryCard)
                          _buildCategoryCard(
                            name: category['name'],
                            icon: category['icon'],
                            color: category['color'],
                            description: category['description'],
                          ),
                          
                          // إذا كان مخصصاً، نضع زر الحذف الأحمر أعلى اليسار
                          if (isCustom)
                            PositionedDirectional(
                              top: 4,
                              start: 4,
                              child: GestureDetector(
                                onTap: () => _deleteCategory(index, category['name']),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close, color: Colors.white, size: 14),
                                ),
                              ),
                            ),
                            
                          // إذا كان مخصصاً، نضع شارة "مخصص" أعلى الجانب الآخر
                          if (isCustom)
                            PositionedDirectional(
                              top: 4,
                              end: 4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: (category['color'] as Color).withValues(alpha: 0.8),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'مخصص',
                                  style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // دالة مساعدة لرسم بطاقة التصنيف
  // ============================================================
  Widget _buildCategoryCard({
    required String name,
    required IconData icon,
    required Color color,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      // التمدد لملء المساحة المتاحة في الـ Grid
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 36),
          const SizedBox(height: 8),
          Text(
            name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            textAlign: TextAlign.center,
            // تقليل الحجم إذا كان النص طويلاً
            style: TextStyle(
              fontSize: 10,
              color: color.withValues(alpha: 0.7),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
