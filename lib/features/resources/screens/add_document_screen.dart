import 'package:flutter/material.dart';

class AddDocumentScreen extends StatefulWidget {
  const AddDocumentScreen({super.key});

  @override
  State<AddDocumentScreen> createState() => _AddDocumentScreenState();
}

class _AddDocumentScreenState extends State<AddDocumentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // 1. L'en-tête (Header)
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text(
          "Publier un document",
          style: TextStyle(color: Color(0xFF001F3F), fontWeight: FontWeight.bold),
        ),
      ),
      
      // 2. Le corps du formulaire
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel("Fichier"),
            const SizedBox(height: 10),
            _buildUploadZone(),
            
            const SizedBox(height: 20),
            _buildLabel("Titre du document"),
            const SizedBox(height: 10),
            _buildTextField("Ex: Support de cours SQL"),

            const SizedBox(height: 20),
            _buildLabel("Type de document"),
            const SizedBox(height: 10),
            _buildDropdownField("Sélectionner un type"),

            const SizedBox(height: 20),
            _buildLabel("Matière"),
            const SizedBox(height: 10),
            _buildDropdownField("Bases de données"),

            const SizedBox(height: 20),
            _buildLabel("Classes destinataires"),
            const SizedBox(height: 10),
            _buildClassCard("L3 Informatique", true),
            _buildClassCard("M1 Ingénierie Logicielle", true),

            const SizedBox(height: 40),
            _buildSubmitButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  //  WIDGETS DE COMPOSANTS 

  Widget _buildLabel(String text) {
    return Text.rich(
      TextSpan(
        text: text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF001F3F)),
        children: const [
          TextSpan(text: " *", style: TextStyle(color: Colors.red)),
        ],
      ),
    );
  }

  Widget _buildUploadZone() {
    return Container(
      width: double.infinity,
      height: 150,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid), // On remplacera par DottedBorder plus tard
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.upload_outlined, size: 40, color: Colors.grey.shade400),
          const Text("Choisir un fichier", style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 5),
          Text("PDF, DOCX, PPTX, JPG, PNG (Max 20 Mo)", 
               style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  Widget _buildTextField(String hint) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
      ),
    );
  }

  Widget _buildDropdownField(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(value, style: const TextStyle(color: Colors.black54)),
          const Icon(Icons.stop, color: Colors.grey, size: 15), // Carré gris comme sur la maquette
        ],
      ),
    );
  }

  Widget _buildClassCard(String className, bool isChecked) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.check_box, color: const Color(0xFF001F3F)),
          const SizedBox(width: 10),
          Text(className, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF001F3F))),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF001F3F),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        onPressed: () {},
        child: const Text("Publier le document", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}