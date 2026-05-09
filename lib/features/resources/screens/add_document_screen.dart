import 'package:flutter/material.dart';
import '../models/document_model.dart';
// Importation des widgets
import '../widgets/form_components.dart';
import '../widgets/upload_zone.dart';
import '../widgets/class_selection_card.dart';
import '../widgets/custom_back_button.dart';

class AddDocumentScreen extends StatefulWidget {
  final String? subjectTitle;
  const AddDocumentScreen({super.key, this.subjectTitle});

  @override
  State<AddDocumentScreen> createState() => _AddDocumentScreenState();
}

class _AddDocumentScreenState extends State<AddDocumentScreen> {
  // Définition de la couleur principale
  final Color primaryBlue = const Color(0xFF001F3F);
  final TextEditingController _titreController = TextEditingController(); 
  String? _selectedSubject;

  @override
  void initState() {
    super.initState();
    _selectedSubject = widget.subjectTitle;
  }

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

  final List<String> listeDesMatieres = [
    "Bases de données",
    "Réseaux",
    "Microéconomie",
    "Théorie des Graphes",
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

  void _afficherMenuMatiere() {
    if (widget.subjectTitle != null) return; // Pas de changement si déjà fixé

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
                "Matière",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 10),
              const Divider(),
              ...listeDesMatieres.map(
                (matiere) => ListTile(
                  title: Text(matiere),
                  trailing: _selectedSubject == matiere
                      ? Icon(Icons.check_circle, color: primaryBlue)
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedSubject = matiere;
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
    return PopScope(
      canPop: false, // On bloque le retour automatique
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return; // Si déjà quitté, on ne fait rien
        
        final bool quitter = await _afficherDialogueAbandon();
        if (quitter && context.mounted) {
          Navigator.of(context).pop(); // On quitte manuellement si confirmé
        }
      },
      child:  Scaffold(
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
              UploadZone(
                onFileSelected: (name) {
                  setState(() {
                    String nameWithoutExtension = name.split('.').first;
                    _titreController.text = nameWithoutExtension;
                  });
                },
              ),
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
              CustomDropdownField(
                value: _selectedSubject ?? "Sélectionner une matière",
                onTap: widget.subjectTitle == null ? _afficherMenuMatiere : null,
              ),

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
              }),

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
                        _selectedSubject == null ||
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
      ),
    );
  }

  Future<bool> _afficherDialogueAbandon() async {
    // On vérifie si l'utilisateur a commencé à remplir le formulaire
    bool aRempliChamps = _titreController.text.isNotEmpty || 
                        typeSelectionne != "Sélectionner un type" ||
                        classesSelectionnees.isNotEmpty;

    if (!aRempliChamps) return true; // Si rien n'est rempli, on quitte directement

    // Sinon, on affiche la modale
    final resultat = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Abandonner la publication ?",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF1A2E5A),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Les données saisies et le fichier sélectionné seront perdus.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 24),
            // Bouton Abandonner (Rouge)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF26262), 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                onPressed: () => Navigator.pop(context, true), 
                child: const Text("Abandonner", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),
          
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE0E0E0), 
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                onPressed: () => Navigator.pop(context, false), 
                child: const Text("Continuer l'édition", style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );

    return resultat ?? false;
  }
}
