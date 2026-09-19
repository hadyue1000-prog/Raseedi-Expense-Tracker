// ============================================================================
// اسم الملف: gemini_service.dart
// وظيفة الملف: الخدمة المسؤولة عن التواصل مع واجهة برمجة تطبيقات الذكاء الاصطناعي (Gemini API).
// علاقته بالمشروع: هذا هو العقل المدبر للذكاء الاصطناعي في التطبيق. يرسل الطلبات ويتلقى الردود.
// أين يتم استخدامه: يتم استخدامه حصرياً داخل AiAssistantProvider.
// ============================================================================

// استيراد مكتبة لتحويل النصوص إلى صيغة JSON والعكس
import 'dart:convert';  
// استيراد مكتبة للتعامل مع العمليات غير المتزامنة (Asynchronous) مثل التأخير الزمني والبث (Stream)
import 'dart:async';    
// استيراد مكتبة للتعامل مع أخطاء الاتصال بالإنترنت (SocketException)
import 'dart:io';       
// استيراد مكتبة لإجراء طلبات الإنترنت (HTTP Requests)
import 'package:http/http.dart' as http;
// استيراد ملف الإعدادات الذي يحتوي على مفتاح الـ API والروابط
import '../config/api_config.dart';

// ==========================================
// كلاس خدمة الذكاء الاصطناعي (GeminiService)
// ==========================================
// نوع الكلاس Service:
// هو كلاس يحتوي على دوال ثابتة (static) للتواصل مع الإنترنت فقط ولا يحتفظ بأي حالة (State).
class GeminiService {
  
  // ============================================================
  // الدالة الأولى: sendMessage (إرسال واستقبال دفعة واحدة)
  // ============================================================
  // تُستخدم عندما نطلب من الذكاء الاصطناعي تحليل بيانات (لا نحتاج لرؤيته وهو يكتب).
  // Future<String>: تعني أن هذه الدالة ستعيد نصاً (String) في المستقبل، ويجب انتظارها.
  static Future<String> sendMessage(String prompt) async {
    // نتحقق أولاً من وجود مفتاح الـ API
    if (!ApiConfig.isApiKeySet) {
      return 'لم يتم إعداد مفتاح API. يرجى إضافة مفتاح Gemini API في ملف .env';
    }

    try {
      // تجهيز رابط الطلب مع دمج مفتاح الـ API فيه
      final url = Uri.parse(
        '${ApiConfig.geminiBaseUrl}?key=${ApiConfig.geminiApiKey}',
      );

      // تجهيز جسم الطلب (Body) بصيغة JSON كما يطلبها خادم Gemini
      final body = jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt}, // النص الذي سنرسله
            ],
          },
        ],
        'generationConfig': {
          'temperature': 0.7,    // مستوى الإبداع (0 = رد دقيق جداً وثابت، 1 = رد إبداعي ومختلف)
          'maxOutputTokens': 1024, // الحد الأقصى لطول الرد
        },
      });

      // نظام إعادة المحاولة (Retry Mechanism)
      // إذا فشل الاتصال بسبب ضعف الإنترنت، سنحاول مرة أخرى حتى 3 مرات.
      int maxRetries = 3;
      int retryCount = 0;
      http.Response? response;

      while (retryCount < maxRetries) {
        try {
          // إرسال طلب POST إلى الخادم، وننتظر الرد.
          // نضع مهلة 30 ثانية (.timeout) حتى لا يعلق التطبيق إذا كان الإنترنت بطيئاً.
          response = await http.post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: body,
          ).timeout(const Duration(seconds: 30));
          
          break; // إذا وصلنا هنا يعني أن الاتصال نجح، نخرج من حلقة المحاولة (while loop)
        
        } on TimeoutException {
          // إذا انتهت المهلة الزمنية (30 ثانية)
          retryCount++;
          if (retryCount >= maxRetries) {
            throw Exception('انتهى وقت الاتصال. تأكد من جودة اتصالك بالإنترنت.');
          }
          // ننتظر قليلاً قبل المحاولة التالية (يزيد وقت الانتظار في كل محاولة)
          await Future.delayed(Duration(seconds: retryCount * 2));
        } on SocketException {
          // إذا لم يكن هناك إنترنت من الأساس
          retryCount++;
          if (retryCount >= maxRetries) {
            throw Exception('لا يوجد اتصال بالإنترنت أو الخادم غير متصل.');
          }
          await Future.delayed(Duration(seconds: retryCount * 2));
        }
      }

      // إذا انتهت المحاولات ولم نحصل على رد
      if (response == null) {
        throw Exception('فشل الاتصال. يرجى التحقق من الشبكة.');
      }

      // معالجة الرد الناجح من الخادم (الكود 200 يعني نجاح الطلب)
      if (response.statusCode == 200) {
        // فك تشفير استجابة JSON إلى Map
        final data = jsonDecode(response.body);
        // الغوص داخل تركيبة JSON المعقدة لاستخراج النص فقط
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
        
        if (text != null) return text;
        throw Exception('لم يتم استلام رد من Gemini.');
        
      } else if (response.statusCode == 429) {
        // الكود 429 يعني أننا استخدمنا الخدمة كثيراً بسرعة
        throw Exception('تجاوزت حد الاستخدام المجاني. يرجى المحاولة لاحقاً.');
      } else {
        // معالجة أي أكواد خطأ أخرى (مثل 400، 500)
        try {
          final errorData = jsonDecode(response.body);
          final errorMessage = errorData['error']?['message'];
          if (errorMessage != null) throw Exception(errorMessage);
        } catch (_) {}
        throw Exception('حدث خطأ. كود: ${response.statusCode}');
      }
    } catch (e) {
      // اصطياد أي أخطاء برمجية أو استثناءات أخرى وإرجاعها كنص
      if (e.toString().contains('تجاوزت حد الاستخدام')) rethrow;
      throw Exception('حدث خطأ: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  // ============================================================
  // الدالة الثانية: sendMessageStream (إرسال واستقبال بالبث/التدفق)
  // ============================================================
  // تُستخدم حصرياً في شاشة المحادثة (الدردشة) لكي يظهر النص تدريجياً.
  //
  // مفاهيم هامة جداً هنا:
  // - Stream<String>: بدلاً من أن تُعيد نصاً واحداً في المستقبل (Future)، تُعيد "سلسلة متتابعة" من النصوص.
  // - async*: النجمة تعني أن هذه الدالة ولّادة (Generator) للبيانات.
  // - yield: بدلاً من return الذي ينهي الدالة، yield يرسل قطعة بيانات للمستمع ويكمل عمله لاستقبال القطعة التالية.
  static Stream<String> sendMessageStream(String prompt) async* {
    if (!ApiConfig.isApiKeySet) {
      yield 'لم يتم إعداد مفتاح API. يرجى إضافة مفتاحك في ملف .env';
      return;
    }

    // هنا نستخدم الرابط الخاص بالبث (StreamUrl) مع إضافة alt=sse 
    // (Server-Sent Events) لتخبر الخادم أن يرسل الرد كقطع متتالية
    final url = Uri.parse(
      '${ApiConfig.geminiStreamUrl}?alt=sse&key=${ApiConfig.geminiApiKey}',
    );

    final bodyMap = {
      'contents': [
        {
          'parts': [
            {'text': prompt}
          ],
        },
      ],
      'generationConfig': {
        'temperature': 0.7,
        'maxOutputTokens': 1024,
      },
    };

    // نستخدم http.Client للتحكم في الاتصال وإبقائه مفتوحاً لاستقبال البث
    final client = http.Client();
    try {
      // بناء الطلب وإرساله
      final request = http.Request('POST', url)
        ..headers['Content-Type'] = 'application/json'
        ..body = jsonEncode(bodyMap);

      final streamedResponse = await client
          .send(request)
          .timeout(const Duration(seconds: 30));

      if (streamedResponse.statusCode == 200) {
        String buffer = '';

        // await for: هذه الحلقة تستمر طالما أن الخادم يرسل بيانات جديدة
        // نقوم بتحويل البيانات (التي تصل كبايتات Bytes) إلى نصوص (utf8)
        await for (final chunk
            in streamedResponse.stream.transform(utf8.decoder)) {
          
          buffer += chunk; // إضافة القطعة الجديدة للنص المتجمع

          // في تقنية SSE، البيانات تأتي على شكل سطور تفصلها علامة الانتقال لسطر جديد (\n)
          final lines = buffer.split('\n');

          // السطر الأخير قد يكون مقطوعاً وغير مكتمل بعد، فنحتفظ به للقطعة القادمة
          buffer = lines.last;

          // نمر على جميع الأسطر المكتملة
          for (int i = 0; i < lines.length - 1; i++) {
            final line = lines[i].trim();

            // نتجاهل أي سطر لا يحمل بيانات حقيقية
            if (!line.startsWith('data: ')) continue;

            // نزيل كلمة "data: " لنحصل على الـ JSON الصافي
            final jsonStr = line.substring(6).trim(); 
            
            // علامة "[DONE]" تعني أن الخادم انتهى من إرسال كل شيء
            if (jsonStr.isEmpty || jsonStr == '[DONE]') continue;

            try {
              // نفك تشفير القطعة (JSON) ونستخرج النص الخاص بها
              final data = jsonDecode(jsonStr);
              final text =
                  data['candidates']?[0]?['content']?['parts']?[0]?['text'];
              
              if (text is String && text.isNotEmpty) {
                // نُرسل (نقذف) هذه القطعة إلى الـ Provider الذي سيقوم بدوره بتحديث الشاشة
                yield text; 
              }
            } catch (_) {
              // نتجاهل أي خطأ في فك التشفير للقطع التالفة
            }
          }
        }
      } else {
        // معالجة الأخطاء في وضع البث (قراءة رسالة الخطأ وتحويلها لاستثناء)
        final errorBody =
            await streamedResponse.stream.transform(utf8.decoder).join();
        String errorMessage = 'حدث خطأ. كود: ${streamedResponse.statusCode}';
        try {
          final errorData = jsonDecode(errorBody);
          final msg = errorData['error']?['message'];
          if (msg != null) errorMessage = msg as String;
        } catch (_) {}

        if (streamedResponse.statusCode == 429) {
          throw Exception('تجاوزت حد الاستخدام المجاني. يرجى المحاولة لاحقاً.');
        }
        throw Exception(errorMessage);
      }
    } on TimeoutException {
      throw Exception('انتهى وقت الاتصال. تأكد من جودة اتصالك بالإنترنت.');
    } on SocketException {
      throw Exception('لا يوجد اتصال بالإنترنت أو الخادم غير متصل.');
    } finally {
      // ⚠️ مهم جداً: إغلاق الاتصال بالإنترنت عند الانتهاء أو عند حدوث خطأ
      // لتجنب استنزاف موارد الجهاز وتسريب الذاكرة (Memory Leaks).
      client.close(); 
    }
  }
}
