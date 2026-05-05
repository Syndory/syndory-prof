import 'package:flutter/material.dart';

class Cours extends StatelessWidget {
  const Cours({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(' Mes cours'),
      ),
      body: const Center(
        child: Text('Contenu de la page Mes cours'),
      ),
    );
  }
}