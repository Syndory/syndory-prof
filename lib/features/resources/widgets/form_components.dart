import 'package:flutter/material.dart';

// 1. LE LABEL
class FormLabel extends StatelessWidget {
  final String label;
  final bool isRequired;

  const FormLabel({
    super.key, 
    required this.label, 
    this.isRequired = true,
  });

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: label,
        style: const TextStyle(
          fontWeight: FontWeight.bold, 
          fontSize: 15, 
          color: Color(0xFF001F3F), 
        ),
        children: [
          if (isRequired) 
            const TextSpan(
              text: " *", 
              style: TextStyle(color: Colors.red),
            ),
        ],
      ),
    );
  }
}

/// 2. LE CHAMP DE TEXTE 
class CustomTextField extends StatelessWidget {
  final String hint;
  final TextEditingController? controller;

  const CustomTextField({super.key, required this.hint, this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        // Bordure quand on ne clique pas dessus
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        // Bordure quand on clique pour taper
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF001F3F), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      ),
    );
  }
}

// 3. LE MENU DÉROULANT 
class CustomDropdownField extends StatelessWidget {
  final String value;
  final VoidCallback? onTap;

  const CustomDropdownField({
    super.key, 
    required this.value, 
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value, 
              style: const TextStyle(color: Colors.black87, fontSize: 15),
            ),
           
            const Icon(Icons.stop, color: Colors.grey, size: 12), 
          ],
        ),
      ),
    );
  }
}