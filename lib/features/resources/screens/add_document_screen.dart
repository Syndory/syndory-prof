import 'package:flutter/material.dart';
import '../models/document_model.dart';
// Importation des widgets
import '../widgets/form_components.dart';
import '../widgets/upload_zone.dart';
import '../widgets/class_selection_card.dart';
import '../widgets/custom_back_button.dart';

class AddDocumentScreen extends StatefulWidget {
  final String subjectTitle;
  const AddDocumentScreen({super.key, required this.subjectTitle});

  @override
  State<AddDocumentScreen> createState() => _AddDocumentScreenState();
}

class _AddDocumentScreenState extends State<AddDocumentScreen> {
  // Définition de la couleur principale
  final Color primaryBlue = const Color(0xFF001F3F);
  final TextEditingController _titreController = TextEditingController(); 

  // Liste des types de documents
  String typeSelectionne = "Sélectionner un type";
  final List<String> listeDesTypes = [
    "Support de cours",
    "Exercice / TP",
    "Examen / Quiz",
    "Annales",
    "Autre",
  ];

  //  Liste des classes disponibles
  final List<String> listeDesClasses = [
    "L3 Informatique",
    "M1 Ingénierie Logicielle",
    "M2 Cybersécurité",
  ];

  // Liste pour stocker les classes sélectionnées (vide au départ)
  List<String> classesSelectionnees = [];
  
  // Fonction pour gérer le clic sur une classe
  void toggleSelection(String className) {
    setState(() {
      if (classesSelectionnees.contains(className)) {
        classesSelectionnees.remove(className); // On décoche
      } else {
        classesSelectionnees.add(className); // On coche
      }
    });
  }

  // Fonction pour afficher le menu de sélection du type
  void _afficherMenuType() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Type de document",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 10),
              const Divider(),

              ...listeDesTypes.map(
                (type) => ListTile(
                  title: Text(type),
                  trailing: typeSelectionne == type
                      ? Icon(Icons.check_circle, color: primaryBlue)
                      : null,
                  onTap: () {
                    setState(() {
                      typeSelectionne = type;
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _titreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // L'EN-TÊTE
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leadingWidth: 70,
        leading: const CustomBackButton(),
        title: Text(
          "Publier un document",
          style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold),
        ),
      ),

      // LE CORPS
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ZONE FICHIER
            const FormLabel(label: "Fichier"),
            const SizedBox(height: 10),
            const UploadZone(),
            const SizedBox(height: 25),

            // TITRE
            const FormLabel(label: "Titre du document"),
            const SizedBox(height: 10),
            CustomTextField(hint: "Ex: Support de cours SQL", 
            controller: _titreController),
            

            const SizedBox(height: 25),

            // TYPE DE DOCUMENT
            const FormLabel(label: "Type de document"),
            const SizedBox(height: 10),
            CustomDropdownField(
              value: typeSelectionne,
              onTap: _afficherMenuType,
            ),

            const SizedBox(height: 25),

            // MATIÈRE
            const FormLabel(label: "Matière"),
            const SizedBox(height: 10),
            // On affiche dynamiquement le titre de la valeur reçue
            CustomDropdownField(value: widget.subjectTitle),

            const SizedBox(height: 25),

            // CLASSES DESTINATAIRES (SECTION DYNAMIQUE)
            const FormLabel(label: "Classes destinataires"),
            const SizedBox(height: 10),

            // On génère dynamiquement les cartes à partir de la liste
            ...listeDesClasses.map((nomDeLaClasse) {
              return ClassSelectionCard(
                className: nomDeLaClasse,
                isSelected: classesSelectionnees.contains(nomDeLaClasse),
                onTap: () => toggleSelection(nomDeLaClasse),
              );
            }).toList(),

            const SizedBox(height: 40),

            // BOUTON VALIDER
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  // On récupère les données
                  String titre = _titreController.text;
                  String type = typeSelectionne;
                  List<String> classes = classesSelectionnees;

                  // Vérification simple
                  if (titre.isEmpty ||
                      type == "Sélectionner un type" ||
                      classes.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("⚠️ Veuillez remplir tous les champs !"),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }

                  // 3. ON CRÉE L'OBJET DOCUMENT
                  // C'est cet objet qui sera envoyé à la page précédente
                  final nouveauDocument = DocumentModel(
                    id: DateTime.now().toString(), 
                    title: titre,
                    date: "À l'instant", 
                    fileSize: '1.5 MB', 
                    fileType: 'pdf',    
                  );

                  // 4. REDIRECTION IMMÉDIATE
                  // On ferme cet écran et on renvoie l'objet nouveauDocument
                  Navigator.of(context).pop(nouveauDocument);

                },
                child: const Text(
                  "Publier le document",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
