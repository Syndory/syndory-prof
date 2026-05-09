import 'package:flutter/material.dart';
import 'package:syndory_prof/app/theme/app_theme.dart';
import '../models/document_model.dart';
import '../widgets/subject_header_card.dart';
import '../widgets/document_tile.dart';
import '../widgets/document_tile_shimmer.dart';
import '../screens/add_document_screen.dart';
import '../models/resources_models.dart';
import '../widgets/error_state.dart';

enum ResourceState { loading, empty, success, error }

class ResourceDetailScreen extends StatefulWidget {
  final SubjectResource subject;

  const ResourceDetailScreen({super.key, required this.subject});

  @override
  State<ResourceDetailScreen> createState() => _ResourceDetailScreenState();
}

class _ResourceDetailScreenState extends State<ResourceDetailScreen> {
  ResourceState _state = ResourceState.loading;
  final TextEditingController _searchController = TextEditingController();
  List<DocumentModel> _allDocuments = [];
  List<DocumentModel> _filteredDocuments = [];

  final List<DocumentModel> _mockDocuments = const [
    DocumentModel(
      id: '1',
      title: 'Cours 01 - Introduction SQL',
      date: '28 avr.',
      fileSize: '1.2 MB',
      fileType: 'pdf',
    ),
    DocumentModel(
      id: '2',
      title: 'TD 02 - Modélisation E/R',
      date: '25 avr.',
      fileSize: '850 KB',
      fileType: 'pdf',
    ),
    DocumentModel(
      id: '3',
      title: 'Projet de groupe - Consignes',
      date: '20 avr.',
      fileSize: '450 KB',
      fileType: 'docx',
    ),
    DocumentModel(
      id: '4',
      title: 'Annales Exam 2023',
      date: '15 avr.',
      fileSize: '2.1 MB',
      fileType: 'pdf',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _allDocuments = List.from(_mockDocuments);
    _filteredDocuments = _allDocuments;
    _loadResources();
  }

  Future<void> _loadResources() async {
    setState(() => _state = ResourceState.loading);
    
    try {
      // Simulation du délai réseau
      await Future.delayed(const Duration(milliseconds: 800));
      
      // throw Exception("Erreur de connexion");

      if (mounted) {
        setState(() {
          _state = _allDocuments.isEmpty
              ? ResourceState.empty
              : ResourceState.success;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _state = ResourceState.error);
      }
    }
  }

  void _onSearchChanged(String query) async {
    setState(() => _state = ResourceState.loading);

    // On simule un court délai de recherche pour voir le Shimmer
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() {
        _filteredDocuments = _allDocuments
            .where(
              (doc) => doc.title.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
        _state = _filteredDocuments.isEmpty
            ? ResourceState.empty
            : ResourceState.success;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(widget.subject.title, style: const TextStyle(color: AppTheme.primaryBlue)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                SubjectHeaderCard(
                  category: 'SCIENCES & TECHNOLOGIES',
                  title: widget.subject.title,
                  documentCount: widget.subject.documentCount,
                  classCount: widget.subject.classTags.length,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged, // Appelé à chaque modification
                    decoration: InputDecoration(
                      hintText: 'Rechercher un document...',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey.shade400,
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          if (_state == ResourceState.loading)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => const DocumentTileShimmer(),
                childCount: 4,
              ),
            )
          else if (_state == ResourceState.error)
            SliverFillRemaining(
              hasScrollBody: false,
              child: ErrorStateWidget(
                title: 'Erreur de chargement',
                message: 'Impossible de récupérer la liste des documents.', 
              ), 
            )
          else if (_state == ResourceState.empty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _buildEmptyState(theme),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                return DocumentTile(
                  document: _filteredDocuments[index],
                  onDelete: () {},
                );
              }, childCount: _filteredDocuments.length),
            ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Affichage de la page d'ajout d'un document
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              // On passe le titre récupéré de la page précédente
              builder: (context) => AddDocumentScreen(subjectTitle: widget.subject.title),
            ),
          );

          // Si on a reçu un document (le résultat n'est pas nul)
          if (result != null && result is DocumentModel) {
            setState(() {
              // On l'ajoute en haut de nos listes
              _allDocuments.insert(0, result);
              _filteredDocuments = List.from(_allDocuments);
              _state = ResourceState.success;
            });
          }

          if (!context.mounted) return;

          // Affichage du message de succès 
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(" Document publié avec succès !"),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        backgroundColor: theme.colorScheme.primary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    final bool isSearching = _searchController.text.isNotEmpty;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              isSearching ? Icons.search : Icons.insert_drive_file_outlined,
              size: 48,
              color: const Color(0xFFC7C7CC),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            isSearching ? 'Aucun résultat' : 'Aucun document',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Color(0xFF1A2E5A),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50.0),
            child: Text(
              isSearching
                ? "Aucun document ne correspond à votre recherche."
                : "Vous n'avez pas encore publié de document pour cette matière.",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF8E8E93),
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 100), // Push content up slightly
        ],
      ),
    );
  }
}
