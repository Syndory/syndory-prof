
class SubjectResource {
  final String id;
  final String title;
  final int documentCount;
  final List<String> classTags;
  final String? lastUploadLabel;

  const SubjectResource({
    required this.id,
    required this.title,
    required this.documentCount,
    required this.classTags,
    this.lastUploadLabel,
  });
}


enum ResourcesUiState {
  
  loading,


  empty,

  
  loaded,
}