// ============================================================================
// اسم الملف: ai_chat_screen.dart
// وظيفة الملف: شاشة المساعد المالي التفاعلية (واجهة الدردشة مع الذكاء الاصطناعي).
// علاقته بالمشروع: هي الشاشة التي تتيح للمستخدم التحدث مع الروبوت، وطلب تحليل أو حفظ عمليات بمجرد كتابتها نصياً.
// أين يتم استخدامه: يُنقل إليها من الزر العائم في الرئيسية، أو من صفحة الملف الشخصي.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/ai_assistant_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/budget_provider.dart';
import '../models/transaction_model.dart';
import '../models/chat_message.dart';
import '../config/api_config.dart';

// ==========================================
// كلاس شاشة الدردشة الذكية (AiChatScreen)
// ==========================================
// StatefulWidget لأننا نحتاج للتحكم بحقل الكتابة، وحركة التمرير (النزول للأسفل تلقائياً).
class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  
  // ==========================================
  // المتغيرات
  // ==========================================
  
  // متحكم حقل كتابة الرسالة
  final TextEditingController _messageController = TextEditingController();
  
  // متحكم التمرير (لكي ننزل لأسفل الدردشة مع كل رسالة جديدة)
  final ScrollController _scrollController = ScrollController();

  // نحتفظ بمرجع للـ Provider هنا، لكي نتمكن من الوصول إليه في دالة dispose() بأمان
  AiAssistantProvider? _aiProvider;

  // ==========================================
  // دالة التهيئة (initState)
  // ==========================================
  @override
  void initState() {
    super.initState();
    
    // addPostFrameCallback: تجعل الكود ينتظر حتى تُبنى الشاشة بالكامل لأول مرة
    // قبل أن يحاول الوصول إلى Providers وإرسال الرسالة الترحيبية.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return; // تأكد أن المستخدم لم يغلق الشاشة بسرعة

      // 1. استخراج الـ Provider وحفظه
      _aiProvider = Provider.of<AiAssistantProvider>(context, listen: false);

      // 2. إرسال الرسالة الترحيبية من الروبوت (تلقائياً عند الفتح)
      _aiProvider!.addWelcomeMessage();

      // 3. نُضيف مستمعاً: كلما ظهرت رسالة جديدة أو تغيرت البيانات، 
      // سنستدعي دالة _scrollToBottom للنزول لآخر الدردشة.
      _aiProvider!.addListener(_scrollToBottom);
    });
  }

  // ==========================================
  // دالة التنظيف والإغلاق (dispose)
  // ==========================================
  @override
  void dispose() {
    // إزالة المستمع حتى لا يعمل في الخلفية ويستهلك الذاكرة
    _aiProvider?.removeListener(_scrollToBottom);
    
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ==========================================
  // دالة التمرير التلقائي لأسفل الشاشة
  // ==========================================
  void _scrollToBottom() {
    // نتحقق أولاً أن الشاشة موجودة ولها ScrollController
    if (_scrollController.hasClients) {
      // نؤخر التمرير قليلاً (50 ملي ثانية) لنعطي الواجهة وقتاً لرسم الرسالة الجديدة
      Future.delayed(const Duration(milliseconds: 50), () {
        if (_scrollController.hasClients) {
          // التمرير إلى أقصى حد متاح في الأسفل بحركة ناعمة
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  // ==========================================
  // دالة إرسال رسالة من المستخدم للروبوت
  // ==========================================
  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return; // منع إرسال نص فارغ

    // تفريغ الحقل فوراً بعد الإرسال
    _messageController.clear();

    // جلب معلومات الرصيد والميزانية لإرسالها للروبوت كسياق (لكي يعرف وضع المستخدم المالي)
    final transProvider = Provider.of<TransactionProvider>(context, listen: false);
    final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);

    // إرسال الطلب إلى AiAssistantProvider
    await Provider.of<AiAssistantProvider>(context, listen: false).sendMessage(
      text,
      totalIncome: transProvider.getTotalIncome(),
      totalExpense: transProvider.getTotalExpense(),
      balance: transProvider.getBalance(),
      monthlyBudget: budgetProvider.monthlyBudget,
    );
  }

  // ==========================================
  // دالة حفظ العملية التي اكتشفها الذكاء الاصطناعي من النص
  // ==========================================
  void _saveParsedTransaction(
    Map<String, dynamic> data, // البيانات المستخرجة
    DateTime messageTimestamp, // توقيت الرسالة لمعرفة أي رسالة تم ضغطها
  ) {
    // تحديد النوع (دخل أم مصروف)
    final type = data['type'] == 'income'
        ? TransactionType.income
        : TransactionType.expense;

    // التعامل الآمن مع الأرقام (قد تصل كـ int أو double من الـ API)
    final amount = (data['amount'] is int)
        ? (data['amount'] as int).toDouble()
        : (data['amount'] as num).toDouble();

    // بناء العملية
    final newTransaction = TransactionModel(
      id: DateTime.now().toString(),
      title: data['note'] ?? data['category'] ?? 'عملية',
      amount: amount,
      category: data['category'] ?? 'أخرى',
      note: data['note'] ?? '',
      type: type,
      date: DateTime.now(),
    );

    // إضافة العملية لمزود العمليات (سيتم خصمها من الرصيد تلقائياً)
    Provider.of<TransactionProvider>(context, listen: false)
        .addTransaction(newTransaction);

    // نخبر مزود الذكاء الاصطناعي أننا "حفظنا" هذه العملية، 
    // لكي يغير شكل الزر في المحادثة إلى "تم الحفظ" ويمنع الحفظ المكرر.
    Provider.of<AiAssistantProvider>(context, listen: false)
        .markMessageAsSaved(messageTimestamp);

    // رسالة نجاح منبثقة
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✓ تم حفظ العملية بنجاح!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  // ==========================================
  // بناء الواجهة (build)
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      // -------- الشريط العلوي --------
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'مسح المحادثة',
            onPressed: () {
              Provider.of<AiAssistantProvider>(context, listen: false)
                  .clearChat();
            },
          ),
            const Row(

              children: [
                 // أيقونة روبوت

                Text('المساعد الذكي'),
                SizedBox(width: 8),
                Icon(Icons.smart_toy),
              ],
            ),
          ],
        ),
        actions: [
          // زر سلة مهملات لمسح سجل الدردشة
          
        ],
      ),
      
      body: Column(
        children: [
          
          // -------- شريط تحذير إذا لم يتم وضع مفتاح API --------
          // (سيختفي إذا كان المفتاح موجوداً)
          if (!ApiConfig.isApiKeySet)
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.orange.withValues(alpha: 0.2),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'لم يتم إعداد مفتاح API. المحادثة لن تعمل.',
                      style: TextStyle(color: Colors.orange, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

          // -------- منطقة الدردشة (الرسائل) --------
          // Expanded لتأخذ كل المساحة المتبقية فوق حقل الكتابة
          Expanded(
            child: Consumer<AiAssistantProvider>(
              builder: (context, aiProvider, child) {
                // عرض الرسائل باستخدام ListView.builder لأداء عالي
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: aiProvider.messages.length,
                  itemBuilder: (context, index) {
                    final message = aiProvider.messages[index];
                    
                    // نتحقق إذا كانت هذه هي الرسالة الأخيرة
                    final isLastMsg = index == aiProvider.messages.length - 1;

                    // منطق إظهار "النقاط المتحركة" (يعني الروبوت يفكر/يكتب)
                    // متى تظهر؟ إذا كانت رسالة روبوت، ولم يصل أي حرف بعد، وهو في حالة تحميل، وهي آخر رسالة.
                    final showLoadingDots = !message.isUser &&
                        message.text.isEmpty &&
                        aiProvider.isLoading &&
                        isLastMsg;

                    // رسم فقاعة الرسالة
                    return _buildMessageBubble(
                      message,
                      showLoadingDots,
                      aiProvider,
                    );
                  },
                );
              },
            ),
          ),

          // -------- أزرار التلميحات السريعة (Quick Prompts) --------
          // صف يمرر أفقياً يعرض أفكاراً للمستخدم
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildQuickChip('اتغديت ب 300 ريال'),
                _buildQuickChip('حلل مصروفاتي'),
                _buildQuickChip('شخصيتي المالية'),
                _buildQuickChip('هل انا بخيل'),
                _buildQuickChip('  هل انا مبذر '),
                _buildQuickChip('هل استطيع الزواج'),
              ],
            ),
          ),

          // -------- حقل إدخال النص وزر الإرسال (أسفل الشاشة) --------
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              // ظل خفيف فوق حقل الكتابة
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                // حقل الكتابة
                 Consumer<AiAssistantProvider>(
                  builder: (context, aiProvider, child) {
                    return CircleAvatar(
                      backgroundColor: const Color(0xFF2f8f83),
                      child: RotatedBox(
                        quarterTurns: 2,
                        child: IconButton(
                          icon: const Icon(Icons.send, color: Colors.white),
                          // تعطيل الزر (null) إذا كان الروبوت يقوم بمعالجة حالياً لمنع السبام
                          onPressed: aiProvider.isLoading
                              ? null
                              : () => _sendMessage(_messageController.text),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),

                Expanded(
                  child: TextField(
                    textAlign: TextAlign.right,
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'اكتب رسالتك أو عمليتك هنا ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.withValues(alpha: 0.1),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    // عند ضغط "Enter" من الكيبورد يتم الإرسال
                    onSubmitted: _sendMessage,
                  ),
                ),
                
                // زر الإرسال
               
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // دالة بناء فقاعة الرسالة الواحدة
  // ============================================================
  Widget _buildMessageBubble(
    ChatMessage message,
    bool showLoadingDots,
    AiAssistantProvider aiProvider,
  ) {
    // معرفة هل الرسالة من المستخدم أم من الروبوت
    final isUser = message.isUser;

    return Align(
      // المحاذاة: رسالة المستخدم لليمين، والروبوت لليسار
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        alignment: Alignment.topRight,
        
        margin: const EdgeInsets.only(bottom: 16),
        // الحد الأقصى للعرض هو 80% من الشاشة لكي لا تلتصق بالطرف الآخر
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        // تصميم الفقاعة (اللون وتدوير الزوايا)
        decoration: BoxDecoration(
          // المستخدم لونه بنفسجي، الروبوت يأخذ لون البطاقة الافتراضي (أبيض أو رمادي غامق)
          color: isUser
              ? const Color(0xFF2f8f83) 
              : Theme.of(context).cardTheme.color,
          // تدوير كل الزوايا عدا زاوية واحدة حسب المرسل (لتشبه ذيل الفقاعة)
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            
            // 1. إذا كان ينتظر النص، نعرض النقاط المتحركة
            if (showLoadingDots)
              const _TypingDots()
              
            // 2. إذا فشلت الرسالة (خطأ انترنت)
            else if (message.hasFailed)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // رسالة الخطأ باللون الأحمر
                  Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          message.text,
                          style: const TextStyle(color: Colors.red, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  
                  // زر إعادة المحاولة
                  GestureDetector(
                    // نمنع الضغط إذا كان أصلاً يعيد المحاولة الآن
                    onTap: aiProvider.isLoading
                        ? null 
                        : () => aiProvider.retryLastMessage(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2f8f83).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF2f8f83).withValues(alpha: 0.4)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.refresh, size: 16, color: Color(0xFF2f8f83)),
                          SizedBox(width: 6),
                          Text(
                            'إعادة المحاولة',
                            style: TextStyle(
                              color: Color(0xFF2f8f83),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
              
            // 3. الحالة الطبيعية: عرض النص
            else
              // SelectableText يسمح للمستخدم بنسخ أجزاء من النص
              SelectableText(
                message.text,
                style: TextStyle(
                  // لون النص أبيض للمستخدم، وأسود/أبيض للروبوت (حسب الثيم)
                  color: isUser ? Colors.white : null,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),

            // ==========================================
            // بطاقة عرض العملية (إذا اكتشفها الروبوت)
            // ==========================================
            // إذا كان parsedTransaction يحتوي على بيانات، سنرسم صندوقاً خاصاً
            if (message.parsedTransaction != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  // لون إطار البطاقة (أخضر للدخل، أحمر للمصروف)
                  border: Border.all(
                    color: (message.parsedTransaction!['type'] == 'income'
                            ? Colors.green
                            : Colors.red)
                        .withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تم التعرف على: '
                      '${message.parsedTransaction!['note'] ?? message.parsedTransaction!['category']}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isUser ? Colors.white : null,
                      ),
                    ),
                    Text(
                      'المبلغ: ${message.parsedTransaction!['amount']} ريال',
                      style: TextStyle(
                        color: isUser ? Colors.white70 : Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // هل تم الحفظ من قبل؟
                    if (message.isSaved)
                      // نعم: عرض شارة "تم الحفظ" الخضراء بدلاً من الزر
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.withValues(alpha: 0.4)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle, color: Colors.green, size: 18),
                            SizedBox(width: 6),
                            Text(
                              'تم الحفظ بالفعل',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      // لا: عرض زر "حفظ العملية"
                      ElevatedButton.icon(
                        // استدعاء دالة الحفظ مع تمرير الـ Timestamp للتمييز
                        onPressed: () => _saveParsedTransaction(
                          message.parsedTransaction!,
                          message.timestamp, 
                        ),
                        icon: const Icon(Icons.save, size: 18),
                        label: const Text('حفظ العملية'),
                        style: ElevatedButton.styleFrom(
                          // اللون حسب النوع
                          backgroundColor:
                              message.parsedTransaction!['type'] == 'income'
                                  ? Colors.green
                                  : Colors.red,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 36),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // دالة مساعدة لرسم زر سريع (التلميحات)
  // ============================================================
  Widget _buildQuickChip(String text) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 8, bottom: 8),
      child: ActionChip(
        label: Text(text),
        backgroundColor: const Color(0xFF2f8f83).withValues(alpha: 0.1),
        labelStyle: const TextStyle(color: Color(0xFF2f8f83), fontSize: 13),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onPressed: () {
          // عند الضغط ينسخ النص لحقل الكتابة ويرسله فوراً
          _messageController.text = text;
          _sendMessage(text);
        },
      ),
    );
  }
}

// ============================================================================
// كلاس خاص بالنقاط المتحركة (_TypingDots)
// وظيفته: إظهار ثلاث نقاط تقفز لتشعر المستخدم أن الروبوت يكتب الآن
// ============================================================================
class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
      
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // إعداد الحركة لتستغرق 800 ملي ثانية للذهاب والعودة، وتتكرر باستمرار
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      // توليد 3 نقاط (دوائر)
      children: List.generate(3, (index) {
        
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            // نجعل كل نقطة تتأخر قليلاً عن سابقتها لتعطي تأثير "الموجة"
            final delay = index * 0.3;
            // حساب قيمة الشفافية بحيث تصعد وتنزل
            final value = (_controller.value - delay).clamp(0.0, 1.0);
            final opacity = (value < 0.5 ? value * 2 : (1 - value) * 2)
                .clamp(0.3, 1.0);

            // رسم النقطة بالشفافية المحسوبة
            return Opacity(
              opacity: opacity,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.grey, // نقطة رمادية
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
