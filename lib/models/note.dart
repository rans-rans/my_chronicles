class Note {
  String title;
  String contents;
  String styles;
  DateTime dateCreated;
  DateTime dateModified;

  Note({
    required this.title,
    required this.contents,
    required this.dateCreated,
    required this.dateModified,
    required this.styles,
  });
}
