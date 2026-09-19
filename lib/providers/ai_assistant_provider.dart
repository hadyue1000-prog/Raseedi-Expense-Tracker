// ============================================================================
// اسم الملف: ai_assistant_provider.dart
// وظيفة الملف: يُدير كل ما يخص المساعد الذكي (إرسال الرسائل، البث، تحليل البيانات).
// علاقته بالمشروع: يشكل حلقة الوصل بين الشاشات (UI) وخدمة الذكاء الاصطناعي (GeminiService).
// أين يتم استخدامه: في AiChatScreen و AiFinancialAssistantScreen.
// ============================================================================

// استيراد مكتبة لتحويل النصوص إلى JSON والعكس
import 'dart:convert';
import 'package:flutter/material.dart';
// استيراد الخدمة التي تتواصل مع الإنترنت
import '../services/gemini_service.dart';
// استيراد قالب (Model) الرسالة
import '../models/chat_message.dart';

// ==========================================
// كلاس مزود مساعد الذكاء الاصطناعي (AiAssistantProvider)
// ==========================================
// نوع الكلاس ChangeNotifier:
// وظيفته إدارة حالة الدردشة وتحديث الشاشات المرتبطة عند حدوث تغيير (مثل وصول حرف جديد).
class AiAssistantProvider extends ChangeNotifier {
  
  // ======================================
  // المتغيرات الخاصة (Private Variables)
  // ======================================

  // لمعرفة هل ننتظر رداً من الذكاء الاصطناعي الآن؟ (لإظهار دائرة التحميل)
  bool _isLoading = false;
  
  // لتخزين رسالة الخطأ إن حدثت (مثل: لا يوجد إنترنت)
  String _errorMessage = '';
  
  // النص الوارد كاستجابة من الذكاء الاصطناعي للأسئلة العادية (ليس للدردشة)
  String _aiResponse = '';
  
  // بيانات العملية المالية المستخرجة من كلام المستخدم (مثل: أكل، 50 ريال)
  Map<String, dynamic>? _parsedTransaction;
  
  // قائمة بجميع الرسائل في شاشة الدردشة
  final List<ChatMessage> _messages = [];

  // ---- متغيرات خاصة بإعادة المحاولة (Retry) ----
  // إذا فشل الإرسال بسبب ضعف الإنترنت، نحتاج للاحتفاظ بما قاله المستخدم 
  // وبحالة حسابه وقت إرسال الرسالة، لكي نتمكن من إرسالها مرة أخرى عند ضغط زر "إعادة المحاولة".
  String _retryUserText = '';
  double _retryTotalIncome = 0;
  double _retryTotalExpense = 0;
  double _retryBalance = 0;
  double _retryMonthlyBudget = 0;

  // ======================================
  // دوال القراءة (Getters)
  // ======================================
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get aiResponse => _aiResponse;
  Map<String, dynamic>? get parsedTransaction => _parsedTransaction;
  List<ChatMessage> get messages => _messages;

  // ======================================
  // رسالة الترحيب في المحادثة
  // ======================================
  // تُستدعى أول مرة تفتح فيها شاشة المحادثة.
  void addWelcomeMessage() {
    // نتحقق إن كانت القائمة فارغة كي لا نكرر الترحيب
    if (_messages.isEmpty) {
      _messages.add(
        ChatMessage(
          text:
              'أهلاً بك! أنا مساعدك المالي الذكي. يمكنك إخباري بمصروفاتك اليومية '
              '(مثل: "اتغديت بـ 50") أو طلب تحليل لمصروفاتك أو شخصيتك المالية. '
              'كيف يمكنني مساعدتك اليوم؟',
          isUser: false, // false يعني المساعد هو من أرسلها
        ),
      );
      notifyListeners(); // تحديث الشاشة لإظهار الرسالة
    }
  }

  // ======================================
  // دالة إرسال رسالة دردشة مع نظام البث (Streaming)
  // ======================================
  // كيف تعمل؟
  // 1. تُضيف رسالة المستخدم للشاشة.
  // 2. تُضيف "فقاعة فارغة" للمساعد وتظهر علامة التحميل.
  // 3. تتصل بـ GeminiService لجلب الرد حرفاً حرفاً.
  // 4. تُحدث الفقاعة الفارغة بكل حرف جديد يصل وتطلب من الشاشة إعادة الرسم (notifyListeners).
  Future<void> sendMessage(
    String userText, {
    required double totalIncome,
    required double totalExpense,
    required double balance,
    required double monthlyBudget,
  }) async {
    // تجاهل النص الفارغ
    if (userText.trim().isEmpty) return;

    // تخزين البيانات للتمكن من إعادة الإرسال لو فشل الاتصال
    _retryUserText = userText;
    _retryTotalIncome = totalIncome;
    _retryTotalExpense = totalExpense;
    _retryBalance = balance;
    _retryMonthlyBudget = monthlyBudget;

    // 1. إضافة رسالة المستخدم للمحادثة فوراً
    _messages.add(ChatMessage(text: userText, isUser: true));
    
    // تفعيل حالة التحميل وتصفير الأخطاء
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    // بناء النص الذي سيتم إرساله للذكاء الاصطناعي (الـ Prompt)
    // نمرر له بيانات حساب المستخدم ليقدم رداً مبنياً على وضعه الحقيقي
    final budgetUsage = monthlyBudget > 0
        ? ((totalExpense / monthlyBudget) * 100).toStringAsFixed(1)
        : '0';

    final prompt = '''
أنت مساعد مالي عربي ممتع وذكي ومفيد لطلاب الجامعة. أجب على رسالة المستخدم الأخيرة بأسلوب ودي وقصير.
إليك بيانات حساب المستخدم الحالية للرجوع إليها إن طلب تحليلاً:
- الدخل: $totalIncome ريال
- المصروفات: $totalExpense ريال
- الرصيد: $balance ريال
- الميزانية: $monthlyBudget ريال (استُهلك منها $budgetUsage%)

ملاحظة هامة جداً:
إذا كانت رسالة المستخدم تعبر عن تسجيل مصروف أو دخل (مثال: "اتغديت ب 50"، "شحنت رصيد ب 200"، "أبوي أعطاني 1000"), 
يجب عليك الرد كنص ودي، ثم إضافة كود JSON في نهاية الرسالة بالضبط بهذا التنسيق وبدون أي تغييرات في المفاتيح:
```json
{
  "transaction": {
    "type": "expense",
    "amount": 50,
    "category": "أكل",
    "note": "غداء"
  }
}
```
إذا لم تكن الرسالة تسجل عملية مالية، لا تضف أي JSON، فقط أجب بشكل طبيعي.

رسالة المستخدم هي: "$userText"
''';

    // 2. إضافة فقاعة فارغة للمساعد (سنملؤها لاحقاً)
    _messages.add(ChatMessage(text: '', isUser: false));
    final int aiMsgIndex = _messages.length - 1; // نحتفظ برقم الرسالة في القائمة لنعدلها
    notifyListeners();

    try {
      String fullResponse = ''; // مجمع النص

      // 3 & 4. نستقبل النص قطعة قطعة باستخدام await for مع الـ Stream
      await for (final chunk in GeminiService.sendMessageStream(prompt)) {
        fullResponse += chunk;

        // نحدث الفقاعة في الواجهة
        // نستخدم copyWith لاستبدال النص القديم بالنص الجديد (المضاف إليه القطعة الجديدة)
        _messages[aiMsgIndex] =
            _messages[aiMsgIndex].copyWith(text: fullResponse);
        
        notifyListeners(); // إخبار الواجهة أن هناك حرفاً جديداً قد وصل
      }

      // ---- المعالجة النهائية بعد اكتمال وصول الرد ----
      Map<String, dynamic>? parsedData;
      String cleanText = fullResponse;

      // نبحث هل الذكاء الاصطناعي أرسل كود JSON يمثل عملية مالية؟
      if (fullResponse.contains('```json') && fullResponse.contains('```')) {
        try {
          // قص الجزء الذي يحتوي على JSON
          final jsonStr =
              fullResponse.split('```json').last.split('```').first.trim();
          
          // تحويله من نص إلى Map
          final data = jsonDecode(jsonStr);
          
          if (data['transaction'] != null) {
            parsedData = data['transaction'];
            
            // نحذف الـ JSON من النص المعروض للمستخدم ليكون مقروءاً
            cleanText = fullResponse
                .replaceAll(RegExp(r'```json[\s\S]*?```'), '')
                .trim();
          }
        } catch (_) {
          // تجاهل الخطأ في حالة فشل التحليل
        }
      }

      // تحديث الرسالة بشريطها النهائي وتضمين بيانات العملية ليظهر زر "حفظ" في الشاشة
      _messages[aiMsgIndex] = ChatMessage(
        text: cleanText,
        isUser: false,
        parsedTransaction: parsedData,
      );
    } catch (e) {
      // التعامل مع أخطاء الاتصال
      final errorText = e.toString().replaceAll('Exception: ', '');
      _errorMessage = errorText;

      // نحدث الرسالة لنظهر رسالة الخطأ للمستخدم، ونفعل مؤشر الفشل (hasFailed = true)
      // مما سيؤدي لظهور زر "إعادة المحاولة" في واجهة الدردشة.
      _messages[aiMsgIndex] = _messages[aiMsgIndex].copyWith(
        text: errorText,
        hasFailed: true,
      );
    } finally {
      // إيقاف مؤشر التحميل في جميع الأحوال (النجاح أو الفشل)
      _isLoading = false;
      notifyListeners();
    }
  }

  // ======================================
  // دالة إعادة المحاولة (Retry)
  // ======================================
  // تُستدعى من زر إعادة المحاولة في رسالة المساعد الفاشلة
  Future<void> retryLastMessage() async {
    if (_retryUserText.isEmpty) return;

    // حذف رسالة المساعد الفاشلة
    if (_messages.isNotEmpty && !_messages.last.isUser) {
      _messages.removeLast();
    }
    // حذف رسالة المستخدم المعلقة لكي نرسلها من جديد بشكل صحيح
    if (_messages.isNotEmpty && _messages.last.isUser) {
      _messages.removeLast();
    }

    // إرسال البيانات المخزنة من جديد
    await sendMessage(
      _retryUserText,
      totalIncome: _retryTotalIncome,
      totalExpense: _retryTotalExpense,
      balance: _retryBalance,
      monthlyBudget: _retryMonthlyBudget,
    );
  }

  // دالة لمسح محتوى المحادثة بالكامل (زر المكنسة)
  void clearChat() {
    _messages.clear();
    _retryUserText = '';
    addWelcomeMessage();
    notifyListeners();
  }

  // دالة لتحديث حالة العملية إلى "تم الحفظ" لمنع تكرار الإدخال
  void markMessageAsSaved(DateTime timestamp) {
    // نبحث عن الرسالة عن طريق الوقت (لأنه مميز لكل رسالة)
    final index = _messages.indexWhere((m) => m.timestamp == timestamp);
    if (index != -1) {
      _messages[index] = _messages[index].copyWith(isSaved: true);
      notifyListeners();
    }
  }

  // ======================================
  // دوال شاشة الأدوات الإضافية للذكاء الاصطناعي
  // ======================================

  // دالة لتحليل بيانات المستخدم وإعطاء نصائح
  Future<void> analyzeExpenses({
    required double totalIncome,
    required double totalExpense,
    required double balance,
    required double monthlyBudget,
    required String topCategory,
    required int transactionCount,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    _aiResponse = '';
    notifyListeners();

    // هنا نطلب الرد دفعة واحدة (ليس بالبث) 
    final prompt = '''
أنت مستشار مالي ذكي لطلاب الجامعة. قدّم تحليلاً مالياً مفيداً ومشجعاً للمستخدم باللغة العربية.

بيانات المستخدم:
- إجمالي الدخل: $totalIncome ريال
- إجمالي المصروفات: $totalExpense ريال
- الرصيد المتبقي: $balance ريال
- الميزانية الشهرية: $monthlyBudget ريال
- أكثر فئة إنفاقاً: $topCategory
- عدد العمليات المسجّلة: $transactionCount عملية

اكتب تحليلاً قصيراً ومفيداً يشمل:
1. تقييم الوضع المالي الحالي
2. ملاحظة إيجابية عن نقطة قوة
3. نصيحة عملية واحدة للتحسين
4. تشجيع ختامي

الرد يجب أن يكون باللغة العربية وبأسلوب ودي ومشجع.
''';

    try {
      _aiResponse = await GeminiService.sendMessage(prompt);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // دالة لتحليل شخصية المستخدم المالية بناءً على نسبة إنفاقه
  Future<void> analyzeFinancialPersonality({
    required double totalIncome,
    required double totalExpense,
    required double monthlyBudget,
    required double balance,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    _aiResponse = '';
    notifyListeners();

    // حساب نسبة الصرف إلى الدخل
    final spendingRate = totalIncome > 0
        ? ((totalExpense / totalIncome) * 100).toStringAsFixed(0)
        : '0';

    final prompt = '''
أنت خبير في علم النفس المالي. حلّل شخصية المستخدم المالية بناءً على بياناته.

بيانات المستخدم:
- الدخل: $totalIncome ريال
- المصروفات: $totalExpense ريال
- نسبة الإنفاق: $spendingRate%
- الرصيد: $balance ريال
- الميزانية المحددة: $monthlyBudget ريال

قدّم تحليلاً للشخصية المالية يشمل:
1. نوع الشخصية المالية
2. أبرز صفاتك المالية
3. نقاط القوة
4. مجالات التطوير
5. نصيحة مخصصة

الرد يجب أن يكون باللغة العربية وممتعاً ومشجعاً.
''';

    try {
      _aiResponse = await GeminiService.sendMessage(prompt);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // دالة لتحويل نص مباشر لعملية مسجلة في شاشة الأدوات
  Future<void> convertTextToTransaction(String text) async {
    _isLoading = true;
    _errorMessage = '';
    _aiResponse = '';
    _parsedTransaction = null;
    notifyListeners();

    final prompt = '''
أنت مساعد ذكي لتسجيل العمليات المالية. حوّل الجملة التالية إلى عملية مالية.

الجملة: "$text"

إذا كانت الجملة تعبّر عن مصروف أو دخل:
- أجب بجملة قصيرة ثم أضف JSON بهذا التنسيق الدقيق:
```json
{
  "transaction": {
    "type": "expense",
    "amount": 25,
    "category": "أكل",
    "note": "غداء"
  }
}
```
- النوع: "expense" للمصروف، "income" للدخل
- التصنيف: اختر من (أكل، مواصلات، دراسة، إنترنت، سكن، أخرى، دخل)

إذا لم تكن الجملة تعبّر عن عملية مالية، اشرح ذلك بودٍّ بدون JSON.
''';

    try {
      final response = await GeminiService.sendMessage(prompt);
      _aiResponse = response;

      if (response.contains('```json') && response.contains('```')) {
        try {
          final jsonStr =
              response.split('```json').last.split('```').first.trim();
          final data = jsonDecode(jsonStr);
          if (data['transaction'] != null) {
            _parsedTransaction = data['transaction'];
          }
        } catch (_) {}
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // تنظيف الرد المؤقت للأدوات
  void clearResponse() {
    _aiResponse = '';
    _parsedTransaction = null;
    _errorMessage = '';
    notifyListeners();
  }
}
