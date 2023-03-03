// ignore_for_file: curly_braces_in_flow_control_structures, sort_child_properties_last, prefer_final_fields, prefer_const_constructors_in_immutables
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../models/note.dart';
import '../providers/app_settings.dart';
import '../providers/note_task.dart';
import '../widgets/fab_button.dart';
import '../widgets/greeting_text.dart';
import '../widgets/notes_list.dart';
import '../widgets/search_bar.dart';
import 'create_note.dart';
import 'settings_page.dart';
import 'trash_page.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage>
    with SingleTickerProviderStateMixin {
  bool inSearchMode = false;
  late AnimationController animationController;

  double getRadianFromDegree(double degree) {
    double rad = 57.295779513;
    return degree / rad;
  }

  final Stream<String> listenToGreeting = Stream.periodic(
    const Duration(seconds: 1),
    ((computationCount) {
      int time = DateTime.now().hour;

      if (time >= 22 || time < 6)
        return "Beautiful Skies you see";
      else if (time >= 17)
        return "Good evening";
      else if (time >= 12)
        return "Good afternoon";
      else
        return "Good morning";
    }),
  );

  @override
  void initState() {
    super.initState();
    final task = Provider.of<NoteTask>(context, listen: false);
    task.getNotesFromStorage();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    animationController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
    animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Stream<List<Note>> allNotes =
        Stream.periodic(const Duration(milliseconds: 850), (_) {
      return Provider.of<NoteTask>(context, listen: false).notes;
    });
    //don't delete the line below
    final appset = Provider.of<AppSettings>(context, listen: false);
    final noteTask = Provider.of<NoteTask>(context, listen: false);
    appset.isAuthenticated = true;

    //you can delete these lines though🤣🤣🤣
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: StreamBuilder<List<Note>>(
                stream: allNotes,
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return const Center(child: CircularProgressIndicator());
                  final notes = snapshot.data;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      //heading consisting of the title and search
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 45,
                          horizontal: 10,
                        ),
                        child: StatefulBuilder(
                          builder: ((context, setSearchState) {
                            return LayoutBuilder(
                              builder: (_, __) {
                                if (inSearchMode)
                                  return SearchBar(
                                      notes: notes,
                                      set: () {
                                        setState(() => inSearchMode = false);
                                      });
                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    InkWell(
                                      splashColor:
                                          Theme.of(context).primaryColor,
                                      onDoubleTap: () {
                                        inSearchMode = false;
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const CreatenotePage(
                                                    note: null),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        "MY NOTES",
                                        style: TextStyle(
                                          fontSize: 55,
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.search),
                                      color: Theme.of(context).primaryColor,
                                      onPressed: () => setSearchState(() {
                                        inSearchMode = true;
                                      }),
                                    ),
                                  ],
                                );
                              },
                            );
                          }),
                        ),
                      ),
                      GreetingText(listenToGreeting),
                      InkWell(
                        onTap: () {
                          if (notes!.isEmpty) return;
                          inSearchMode = false;
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  CreatenotePage(note: noteTask.recent()),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(5, 15, 5, 35),
                          width: double.infinity,
                          height: 150,
                          padding: const EdgeInsets.all(5),
                          child: LayoutBuilder(builder: (_, __) {
                            if (notes!.isEmpty)
                              return const Text("No Recents here");
                            return Text(
                              noteTask.recent().title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 25,
                              ),
                            );
                          }),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                        ),
                      ),
                      const Text(
                        "All NOTES",
                        style: TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 25),
                      ),
                      if (notes!.isEmpty) const EmptyNotes(),
                      if (notes.isNotEmpty)
                        Flexible(child: NotesList(notes, animationController)),
                    ],
                  );
                }),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: StatefulBuilder(builder: (context, setState) {
        return SizedBox(
          height: 135,
          width: 135,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.translate(
                offset: Offset.fromDirection(
                  getRadianFromDegree(225),
                  animationController.value * 60,
                ),
                child: FabButton(
                  color: Colors.green,
                  icon: const Icon(Icons.add, color: Colors.white),
                  opacity: animationController.value,
                  fxn: () {
                    inSearchMode = false;
                    if (animationController.isCompleted)
                      animationController.reverse();
                    Navigator.of(context).pushNamed(CreatenotePage.routeName);
                  },
                ),
              ),
              Transform.translate(
                offset: Offset.fromDirection(
                  getRadianFromDegree(315),
                  animationController.value * 60,
                ),
                child: FabButton(
                  color: Colors.black,
                  icon: const Icon(Icons.settings, color: Colors.white),
                  opacity: animationController.value,
                  fxn: () {
                    inSearchMode = false;
                    if (animationController.isCompleted)
                      animationController.reverse();
                    Navigator.of(context).pushNamed(SettingsPage.routeName);
                  },
                ),
              ),
              Transform.translate(
                offset: Offset.fromDirection(
                  getRadianFromDegree(135),
                  animationController.value * 60,
                ),
                child: FabButton(
                    color: Colors.red,
                    icon: const Icon(Icons.delete, color: Colors.white),
                    opacity: animationController.value,
                    fxn: () {
                      inSearchMode = false;
                      if (animationController.isCompleted)
                        animationController.reverse();
                      Navigator.of(context).pushNamed(TrashPage.routeName);
                    }),
              ),
              Transform.translate(
                offset: Offset.fromDirection(
                  getRadianFromDegree(45),
                  animationController.value * 45,
                ),
                child: FabButton(
                  color: Theme.of(context).primaryColor,
                  width: 65,
                  height: 65,
                  icon: const Icon(Icons.menu, color: Colors.white),
                  fxn: () {
                    if (animationController.isCompleted) {
                      animationController.reverse();
                    } else {
                      animationController.forward();
                    }
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class EmptyNotes extends StatelessWidget {
  const EmptyNotes({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset("assets/images/empty-notes.jpg"),
          const Text(
            "There are no notes",
            style: TextStyle(
              color: Colors.orange,
              fontSize: 23,
            ),
          ),
        ],
      ),
    );
  }
}
