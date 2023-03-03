class NoteFormatStyle {
  int index;
  Map<String, dynamic>? styleToJson;
  NoteFormatStyle({
    required this.index,
    required this.styleToJson,
  });

  Map<String, dynamic> toJson() {
    return {
      "index": index,
      "styles": styleToJson,
    };
  }

  factory NoteFormatStyle.fromJson(Map<String, dynamic> json) {
    return NoteFormatStyle(index: json["index"], styleToJson: json["styles"]);
  }
}
