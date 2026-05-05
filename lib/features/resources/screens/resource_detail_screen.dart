import 'package:flutter/material.dart';
import '../models/document_model.dart';
import '../widgets/subject_header_card.dart';
import '../widgets/document_tile.dart';
import '../widgets/document_tile_shimmer.dart';

enum ResourceState { loading, empty, success }

class ResourceDetailScreen extends StatefulWidget {
  const ResourceDetailScreen({super.key});

  @override
  State<ResourceDetailScreen> createState() => _ResourceDetailScreenState();
}

class _ResourceDetailScreenState extends State<ResourceDetailScreen> {
  ResourceState _state = ResourceState.loading;
  final TextEditingController _searchController = TextEditingController();
  List<DocumentModel> _documents = [];

  final List<DocumentModel> _mockDocuments = const [
    DocumentModel(id: '1', title: 'Cours 01 - Introduction SQL', date: '28 avr.', fileSize: '1.2 MB', fileType: 'pdf'),
    DocumentModel(id: '2', title: 'TD 02 - Modélisation E/R', date: '25 avr.', fileSize: '850 KB', fileType: 'pdf'),
    DocumentModel(id: '3', title: 'Projet de groupe - Consignes', date: '20 avr.', fileSize: '450 KB', fileType: 'docx'),
    DocumentModel(id: '4', title: 'Annales Exam 2023', date: '15 avr.', fileSize: '2.1 MB', fileType: 'pdf'),
  ];

  @override
  void initState() {
    super.initState();
    _loadResources();
  }

  Future<void> _loadResources() async {
    setState(() => _state = ResourceState.loading);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _documents = _mockDocuments;
        _state = _documents.isEmpty ? ResourceState.empty : ResourceState.success;
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
        title: const Text('Bases de données'),
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
                const SubjectHeaderCard(
                  category: 'SCIENCES & TECHNOLOGIES',
                  title: 'Bases de données',
                  documentCount: 7,
                  classCount: 2,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Rechercher un document...',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
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
          else if (_state == ResourceState.empty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _buildEmptyState(theme),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return DocumentTile(
                    document: _documents[index],
                    onDelete: () {},
                  );
                },
                childCount: _documents.length,
              ),
            ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _state = _state == ResourceState.success
                ? ResourceState.empty
                : (_state == ResourceState.empty ? ResourceState.loading : ResourceState.success);
            if (_state == ResourceState.loading) {
              _loadResources();
            }
          });
        },
        backgroundColor: theme.colorScheme.primary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: 'Calendrier',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            activeIcon: Icon(Icons.book),
            label: 'Mes cours',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_outlined),
            activeIcon: Icon(Icons.folder),
            label: 'Ressources',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
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
            child: const Icon(Icons.insert_drive_file_outlined, size: 48, color: Color(0xFFC7C7CC)),
          ),
          const SizedBox(height: 32),
          Text(
            'Aucun document',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50.0),
            child: Text(
              "Vous n'avez pas encore publié de document pour cette matière.",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 15,
                color: const Color(0xFF8E8E93),
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
