
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  
  final String text;           
  final VoidCallback onPressed; 
  final Color? color;          

  const CustomButton({
    super.key,
    required this.text,     
    required this.onPressed, 
    this.color,              
  });


  @override
  Widget build(BuildContext context) {

    return SizedBox(
      width: double.infinity,
      height: 50,
      
      child: ElevatedButton(

        onPressed: onPressed,
        style: ElevatedButton.styleFrom(

          padding: EdgeInsets.all(10),
          backgroundColor: color ?? const Color(0xFF2f8f83), 
          foregroundColor: Colors.white, 
          shape: RoundedRectangleBorder(

            borderRadius: BorderRadius.circular(12),
            
          ),

        ),        
        child: Text(

          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),

        ),

      ),

    );

  }

}
