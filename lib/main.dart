// ============================================================================
// اسم الملف: main.dart
// وظيفة الملف: نقطة الانطلاق الأساسية للتطبيق (Entry Point). يبدأ التشغيل من هنا.
// علاقته بالمشروع: هذا الملف هو الحاوية الرئيسية (Root) لكل التطبيق، يجمع فيه
//                 مكتبات الحالة (Providers) وإعدادات الثيمات (Themes) وشاشة البداية.
// ============================================================================

import 'package:flutter/material.dart';

// نستخدم مكتبة Provider لإدارة الحالة (State Management) في التطبيق.
// باختصار: هي الطريقة التي تجعل الشاشة تتحدث تلقائياً عندما تتغير البيانات في الخلفية.
import 'package:provider/provider.dart';

// مكتبة لقراءة المتغيرات السرية من ملف .env (مثل مفتاح الـ API)
import 'package:flutter_dotenv/flutter_dotenv.dart';

// استيراد جميع ملفات الـ Providers التي تدير البيانات في التطبيق
import 'providers/auth_provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/budget_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/ai_assistant_provider.dart';
import 'providers/category_provider.dart';

// استيراد شاشة البداية التي ستظهر أولاً عند تشغيل التطبيق
import 'screens/splash_screen.dart';

// ==========================================
// الدالة الرئيسية (main)
// ==========================================
// أول دالة يستدعيها النظام عند تشغيل التطبيق.
// كلمة async تعني أن هذه الدالة ستقوم بعمليات تأخذ وقتاً (مثل قراءة ملف) ويجب انتظارها.
void main() async {
  // هذا السطر إلزامي في Flutter إذا كنا سنستدعي كوداً يأخذ وقتاً (await) قبل تشغيل التطبيق (runApp)
  // يضمن تهيئة نظام واجهة المستخدم بشكل صحيح.
  WidgetsFlutterBinding.ensureInitialized();
  
  // نقرأ بيانات ملف .env الذي يحتوي على المتغيرات السرية (المفاتيح).
  // await: تعني "انتظر حتى تنتهي عملية القراءة قبل إكمال باقي الكود".
  await dotenv.load(fileName: ".env");
  
  // تشغيل التطبيق الفعلي واستدعاء كلاس RasidiApp
  runApp(const RasidiApp());
}

// ==========================================
// كلاس التطبيق الرئيسي (RasidiApp)
// ==========================================
// نوع الكلاس StatelessWidget:
// هذا يعني أن هذا الكلاس لا تتغير بياناته داخلياً (ليس لديه حالة متغيرة State)،
// وظيفته فقط رسم الشاشة وتقديم الـ Providers.
class RasidiApp extends StatelessWidget {
  const RasidiApp({super.key});

  // اللون الرئيسي للتطبيق (لون أرجواني)، محفوظ كمتغير ثابت لسهولة استخدامه
  static const Color _primaryColor = Color(0xFF2f8f83);

  // دالة build:
  // هذه الدالة هي المسؤولة عن بناء وعرض الواجهة. كل Widget يجب أن يحتوي على هذه الدالة.
  // تعيد شكل الواجهة الذي سيظهر للمستخدم.
  @override

  Widget build(BuildContext context) {
    
    // نستخدم MultiProvider لتوفير جميع مخازن البيانات (Providers) للتطبيق بأكمله.
    // بوضعها هنا في أعلى شجرة الـ Widgets، يمكن لأي شاشة في التطبيق الوصول للبيانات.
    return MultiProvider(
      providers: [
        // كل سطر هنا يُنشئ Provider جديد.
        // ChangeNotifierProvider يعني: راقب هذا الكلاس، وإذا تغيرت فيه قيمة استدعى notifyListeners،
        // قم بتحديث أي شاشة تستخدم هذا الكلاس.
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => BudgetProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AiAssistantProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
      ],
      
      // نستخدم Consumer<ThemeProvider> هنا لكي نستمع لتغييرات الثيم (الوضع الليلي والنهاري)
      // كلما غير المستخدم الثيم، سيعاد بناء هذا الـ Widget تلقائياً لتطبيق الثيم الجديد.
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          
          // MaterialApp:
          // هو الـ Widget الأساسي لأي تطبيق Flutter يتبع تصميم Google Material Design.
          // يوفر لنا الأساسيات مثل: الثيمات، التنقل بين الشاشات، وإعدادات اللغة.
          return MaterialApp(
            title: 'رصيدي', // اسم التطبيق 
            debugShowCheckedModeBanner: false, // إخفاء شريط كلمة "Debug" المزعج في أعلى الزاوية
            
            // تحديد وضع الثيم الحالي بناءً على قيمة المتغير الموجودة في ThemeProvider
            themeMode: themeProvider.isDarkMode
                ? ThemeMode.dark
                : ThemeMode.light,

            // ========================
            // الثيم الفاتح (Light Theme)
            // ========================
            theme: ThemeData(
              useMaterial3: true, // تفعيل تصميم Material 3 الحديث من جوجل
              fontFamily: 'Roboto', // نوع الخط المستخدم في كامل التطبيق
              
              // تحديد لوحة الألوان الأساسية بناءً على اللون البنفسجي
              colorScheme: ColorScheme.fromSeed(
                seedColor: _primaryColor,
                brightness: Brightness.light,
              ),
              
              // لون خلفية جميع الشاشات
              scaffoldBackgroundColor: const Color(0xFFF5F5F5),
              
              // تصميم شريط التطبيق العلوي (AppBar)
              appBarTheme: const AppBarTheme(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white, // لون النص والأيقونات داخل الشريط
                elevation: 0, // إلغاء الظل أسفل الشريط
              ),
              
              // تصميم البطاقات (Cards)
              cardTheme: CardThemeData(
                color: Colors.white,
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              
              // تصميم حقول إدخال النص (TextFields)
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                // شكل الحقل عند الضغط عليه للكتابة
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _primaryColor, width: 2),
                ),
              ),
              
              // تصميم الأزرار البارزة (ElevatedButton)
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
              
              // تصميم أزرار التبديل (Switch) مثل زر تشغيل الوضع الليلي
              switchTheme: SwitchThemeData(
                thumbColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.selected)
                      ? _primaryColor
                      : Colors.grey,
                ),
              ),
            ),

            // ========================
            // الثيم الداكن (Dark Theme)
            // ========================
            darkTheme: ThemeData(
              useMaterial3: true,
              fontFamily: 'Roboto',
              colorScheme: ColorScheme.fromSeed(
                seedColor: _primaryColor,
                brightness: Brightness.dark,
              ),
              scaffoldBackgroundColor: const Color.fromARGB(255, 30, 29, 29), // خلفية سوداء باهتة
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF1E1E2E),
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              cardTheme: CardThemeData(
                color: const Color(0xFF1E1E2E), // لون رمادي داكن للبطاقات
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: const Color(0xFF2A2A3E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF3A3A5A)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF3A3A5A)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _primaryColor, width: 2),
                ),
                labelStyle: const TextStyle(color: Colors.white70),
                hintStyle: const TextStyle(color: Colors.white38),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
              switchTheme: SwitchThemeData(
                thumbColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.selected)
                      ? _primaryColor
                      : Colors.grey,
                ),
              ),
              dividerColor: const Color(0xFF3A3A5A),
            ),

            // home: هي الشاشة الأولى التي تفتح عند تشغيل التطبيق
            // وضعناها SplashScreen (شاشة الترحيب القصيرة)
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
