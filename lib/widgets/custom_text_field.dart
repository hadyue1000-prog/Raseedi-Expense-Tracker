
import 'package:flutter/material.dart';


class CustomTextField extends StatelessWidget {
  
  final String label;                    
  
  final TextEditingController controller; 
  
  final bool obscureText;                
  
  final TextInputType keyboardType;      
  
  final String? hint;                    

  const CustomTextField({
    super.key,
    required this.label,       
    required this.controller,  
    this.obscureText = false,   
    this.keyboardType = TextInputType.text,    
    this.hint,                 
  });

  @override
  Widget build(BuildContext context) {

    return Column(

      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        
        const SizedBox(height: 6),
        
        TextField(
          textAlign: TextAlign.end,
          controller: controller, 
          obscureText: obscureText, // إخفاء النص إن كانت الكلمة السرية
          keyboardType: keyboardType, // تحديد نوع الكيبورد
          
          // تزيين الحقل (Decoration)
          decoration: InputDecoration(
            hintText: hint, // النص التلميحي الباهت
            
            // شكل الإطار العادي (مدور الحواف)
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            
            // المسافة الداخلية بين النص وإطار الحقل
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}
