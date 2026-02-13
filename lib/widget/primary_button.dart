import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool isLoading; 

  const PrimaryButton({
    super.key, 
    required this.text, 
    required this.onTap,
    this.isLoading = false, 
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      
      onTap: isLoading ? null : onTap, 
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isLoading 
              ? [Colors.grey, Colors.grey.shade400] 
              : [const Color.fromARGB(255, 126, 140, 253), const Color(0xFFB599FF)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          
          child: isLoading 
            ? const SizedBox(
                height: 24, 
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2, 
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
        ),
      ),
    );
  }
}