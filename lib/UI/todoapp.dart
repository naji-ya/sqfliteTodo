import 'package:flutter/material.dart';
import 'package:sqlite_project/UI/sqlhelper.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: TodoUI(),
  ));
}

class TodoUI extends StatefulWidget {
  @override
  State<TodoUI> createState() => _TodoUIState();
}

class _TodoUIState extends State<TodoUI> {
  bool isLoading = true;

  List<Map<String, dynamic>> note_from_db =
      []; // an emty list to store data from sqflite because it cannot be called directly

  @override
  void initState() {
    //refreshing ui
    refreshdata();
    super.initState();
  }

  void refreshdata() async {
    final datas = await SQLhelper.readNotes(); // read data from sqflite

    setState(() {
      note_from_db = datas; //add the datas read from sqflite into empty list
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        title: Text("Sqflite Todo App"),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: note_from_db.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    color: Colors.lightGreen[300],
                    child: ListTile(
                      title: Text(note_from_db[index]['title']),
                      subtitle: Text(note_from_db[index]['note']),
                      trailing: Wrap(
                        children: [
                          IconButton(
                              onPressed: () {
                                shoform(note_from_db[index]['id']);
                              },
                              icon: Icon(Icons.edit)),
                          IconButton(
                              onPressed: () {
                                NoteToDelete(note_from_db[index]['id']);
                              },
                              icon: Icon(
                                Icons.delete,
                              )),
                        ],
                      ),
                    ),
                  ),
                );
              }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => shoform(null),
        child: Icon(Icons.add),
        backgroundColor: Colors.lightGreen,
      ),
    );
  }

  final title = TextEditingController();
  final note = TextEditingController();

  void shoform(int? id) async {
    if (id != null) {
      final ExistingNote = note_from_db.firstWhere((note) => note["id"] == id);
      title.text = ExistingNote['title'];
      note.text = ExistingNote['note'];
    }

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => Container(
              padding: EdgeInsets.only(
                left: 10,
                right: 10,
                top: 10,
                bottom: MediaQuery.of(context).viewInsets.bottom + 120,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    controller: title,
                    decoration: InputDecoration(
                        hintText: 'Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        )),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: note,
                    decoration: InputDecoration(
                        hintText: "Job",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        )),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (id == null) {
                        await addNote();
                      }
                      if (id != null) {
                        await updateNotes(id);
                      }
                      title.text = "";
                      note.text = "";
                      Navigator.of(context).pop();
                    },
                    child: Text(id == null ? 'Add' : 'Update'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightGreen),
                  )
                ],
              ),
            ));
  }

  Future addNote() async {
    await SQLhelper.createNotes(title.text,
        note.text); // the createNotes function is created as static function so that here it call as class name . function name
    refreshdata();
  }

  Future<void> updateNotes(int id) async {
    await SQLhelper.updateNote(id, title.text, note.text);
    refreshdata();
  }

  Future<void> NoteToDelete(int id) async {
    await SQLhelper.deleteNote(id);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Note Deleted")));
    refreshdata();
  }
}
