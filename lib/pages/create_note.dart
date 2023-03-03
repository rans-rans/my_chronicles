// ignore_for_file: curly_braces_in_flow_control_structures, prefer_final_fields

import 'dart:convert';

import "package:flutter/material.dart";
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:provider/provider.dart';

import '../models/my_text_style.dart';
import '../models/note.dart';
import '../providers/note_task.dart';

class CreatenotePage extends StatefulWidget {
  static const routeName = "/create-note";
  final Note? note;
  const CreatenotePage({required this.note, super.key});

  @override
  State<CreatenotePage> createState() => _CreatenotePageState();
}

class _CreatenotePageState extends State<CreatenotePage>
    with WidgetsBindingObserver {
  final _titleText = TextEditingController();
  final _quill = quill.QuillController.basic();
  final _titleFocus = FocusNode();
  final _contentFocus = FocusNode();
  bool _isSaving = false;
  bool _inReadingMode = false;
  Note note = Note(
    title: "",
    contents: "",
    styles: "",
    dateCreated: DateTime.now(),
    dateModified: DateTime.now(),
  );

  Future<void> saveNote(DateTime date, bool isNew) async {
    final provider = Provider.of<NoteTask>(context, listen: false);
    List<Map<String, dynamic>> noteStyles = [];
    note.title = _titleText.text.isEmpty ? "Untitled" : _titleText.text;
    note.contents = _quill.plainTextEditingValue.text;
    note.dateModified = DateTime.now();
    note.dateCreated = date;
    final allStyles =
        _quill.document.collectAllIndividualStyles(0, note.contents.length);

    for (var item in allStyles) {
      final index = item.item1;
      final styleToJson = item.item2.toJson();
      noteStyles.add(NoteFormatStyle(
        index: index,
        styleToJson: styleToJson,
      ).toJson());
    }
    note.styles = json.encode(noteStyles);
    provider.saveNote(note: note, isNew: isNew);
  }

  void applyStylesAppropriately(List<NoteFormatStyle> styles) {
    final bodyLen = _quill.plainTextEditingValue.text.length;
    late int length;
    int styleNumber = styles.length - 1;
    for (var i = 0; i <= styleNumber; i++) {
      final style = quill.Style.fromJson(styles[i].styleToJson);
      final start = styles[i].index;
      if (i == styleNumber) {
        length = bodyLen - start;
      } else {
        final end = styles[i + 1].index;
        length = end - start;
      }
      _quill.formatTextStyle(styles[i].index, length, style);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.note != null) {
      final note = widget.note!;
      _titleText.text = note.title;
      _quill.document.insert(0, note.contents);
      //
      //applying the saved formatting to the text
      final jsonData = json.decode(note.styles) as List;
      List<NoteFormatStyle> appliedStyles = [];
      for (var map in jsonData) {
        final myStyle = NoteFormatStyle.fromJson(map);
        appliedStyles.add(myStyle);
      }
      applyStylesAppropriately(appliedStyles);
      //done
      //
    } else {
      _titleText.text = "Untitled";
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) return;

    if (state == AppLifecycleState.paused) {
      if (widget.note != null) {
        saveNote(widget.note!.dateCreated, false);
      } else {
        saveNote(DateTime.now(), true);
      }
      showToast(
        "Saved",
        context: context,
        animation: StyledToastAnimation.scale,
        dismissOtherToast: true,
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _titleText.dispose();
    _quill.dispose();
    _titleFocus.dispose();
    _contentFocus.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fxn = Provider.of<NoteTask>(context, listen: false);

    return WillPopScope(
      onWillPop: () async {
        final isNew = widget.note == null ? true : false;
        if (widget.note == null && _quill.plainTextEditingValue.text.isEmpty)
          return true;
        saveNote(widget.note!.dateCreated, isNew);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Notepad"),
          actions: [
            TextButton(
              child: const Text("Save", style: TextStyle(color: Colors.white)),
              onPressed: () {
                if (widget.note == null)
                  saveNote(DateTime.now(), true);
                else
                  saveNote(widget.note!.dateCreated, false);
                showToast(
                  "Saved",
                  context: context,
                  animation: StyledToastAnimation.scale,
                  dismissOtherToast: true,
                );
                Navigator.of(context).pop();
              },
            ),
            IconButton(
              icon: Icon(
                Icons.delete,
                color: widget.note != null ? Colors.red : Colors.grey,
              ),
              onPressed: widget.note == null
                  ? null
                  : () async => await fxn
                      .addToTrash(
                        Note(
                          title: widget.note!.title,
                          styles: widget.note!.styles,
                          contents: widget.note!.contents,
                          dateCreated: widget.note!.dateCreated,
                          dateModified: DateTime.now(),
                        ),
                      )
                      .then((_) => Navigator.of(context).pop()),
            ),
          ],
        ),
        body: _isSaving
            ? const Center(child: CircularProgressIndicator.adaptive())
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Row(
                        children: [
                          const Text("Title:  "),
                          Expanded(
                            child: TextField(
                              controller: _titleText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: quill.QuillToolbar.basic(
                        controller: _quill,
                        multiRowsDisplay: false,
                        showCodeBlock: false,
                        showIndent: false,
                        showBackgroundColorButton: false,
                        showDirection: false,
                        showDividers: false,
                        showLink: false,
                        showListCheck: false,
                        showListBullets: false,
                        showAlignmentButtons: true,
                        showSmallButton: false,
                        showInlineCode: false,
                        showClearFormat: false,
                      ),
                    ),
                    //insert body here
                    Expanded(
                      child: quill.QuillEditor.basic(
                        controller: _quill,
                        readOnly: _inReadingMode,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
