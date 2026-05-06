import 'package:flutter/material.dart';

class ClassSelectionCard extends StatelessWidget {
  final String className;
  final bool isSelected;
  final VoidCallback onTap; 

  const ClassSelectionCard({
    super.key,
    required this.className,
    required this.isSelected,
    required this.onTap, 
  });

  @override
  Widget build(BuildContext context) {
    // Palette de couleurs adaptée
    final Color bleuMarine = const Color(0xFF001F3F);
    final Color bleuSelection = const Color(0xFFF0F4F8);
    
    // Couleurs "Gris Formulaire" (quand non sélectionné)
    final Color grisFond = Colors.grey[50]!; 
    final Color grisBordure = Colors.grey.shade300;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200), // Animation fluide pour le changement de couleur
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          // Si pas cliqué, on utilise le gris du formulaire
          color: isSelected ? bleuSelection : grisFond,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? bleuMarine : grisBordure,
            width: isSelected ? 2 : 1, 
          ),
        ),
        child: Row(
          children: [
            // L'icône change de style et de couleur selon l'état
            Icon(
              isSelected ? Icons.check_box : Icons.check_box_outline_blank,
              color: isSelected ? bleuMarine : Colors.grey,
            ),
            const SizedBox(width: 12),
            // Le nom de la classe
            Text(
              className,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? bleuMarine : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}