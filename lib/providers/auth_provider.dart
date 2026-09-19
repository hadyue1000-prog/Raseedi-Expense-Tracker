
import 'package:flutter/material.dart';
import '../models/user_model.dart';


class AuthProvider extends ChangeNotifier {
  
 
  UserModel? _currentUser;
  bool _isLoggedIn = false;
  String? _registeredName;
  String? _registeredEmail;
  String? _registeredPassword;

  bool get isLoggedIn => _isLoggedIn;

  UserModel? get currentUser => _currentUser;

  bool get hasRegisteredAccount => _registeredEmail != null && _registeredPassword != null;

  String get userName => _currentUser?.name ?? 'مستخدم';
  
  String get userEmail => _currentUser?.email ?? '';

 
  bool login(String email, String password) {
    email = email.trim();//used to remove the unnesesary space 

    if (!hasRegisteredAccount) {
      return false;
    }

    // نجرب تطابق بيانات تسجيل الدخول مع بيانات الحساب المسجل
    if (email == _registeredEmail && password == _registeredPassword) {
      _currentUser = UserModel(
        name: _registeredName!,
        email: _registeredEmail!,
      );
      _isLoggedIn = true;
      notifyListeners();
      return true;
    }

    return false;
  }

  // ==========================================
  // دالة إنشاء حساب جديد (Register)
  // ==========================================
  // تُستدعى من شاشة RegisterScreen
  void register(String name, String email, String password) {
    _registeredName = name.trim();
    _registeredEmail = email.trim();
    _registeredPassword = password;

    // يتم إنشاء الحساب فقط، ولا يتم تسجيل الدخول تلقائياً
    // حتى يصبح المستخدم مجبراً على تسجيل الدخول بنفس البيانات لاحقاً.
    notifyListeners();
  }

  // ==========================================
  // دالة تسجيل الخروج (Logout)
  // ==========================================
  // تُستدعى من ProfileScreen عند الضغط على زر "تسجيل الخروج"
  void logout() {
    // نحذف بيانات المستخدم
    _currentUser = null;
    
    // نغير الحالة إلى غير مسجل دخول
    _isLoggedIn = false;

    // نُحدث الواجهات، مما سيؤدي تلقائياً إلى نقل المستخدم لشاشة تسجيل الدخول
    notifyListeners();
  }
}
