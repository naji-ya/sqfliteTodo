import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart' as sqlf;

class SQLhelper {
  ///1. create database
  static Future<sqlf.Database> myData() async {
    // a database cannot call directly,so it creates inside a function mydata
    return sqlf.openDatabase('myNotes.db', version: 1,
        onCreate: (sqlf.Database database, int version) async {
      // here database is the object created for sqlf.Database
      await createTables(database); // a function called which is defined down
    });
  }

  /// 2.create table with notes and column name as title and note
  static Future<void> createTables(
      sqlf.Database
          database) // the future function is created as void because it doesnt return a value
  async {
    await database.execute(
        """CREATE TABLE notes(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  title TEXT,
  note TEXT,
  createAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
  )""");
  }

  ///add datas to the notes table which is created inside the myNotes.db
  static Future<int> createNotes(String title, String note) async {
    // the future is created as int , it returns id,
    final db = await SQLhelper.myData();

    /// to open database
    final data = {
      'title': title,
      'note': note
    }; //the values get from  the ui bottomsheet is assigned to the columns in database title and note
    final id = await db.insert(
        "notes", data, // then insert the values to the table notes
        conflictAlgorithm: sqlf
            .ConflictAlgorithm.replace); // if a id already exist the replace it
    return id;
  }

  /// read all data from the table

  static Future<List<Map<String, dynamic>>> readNotes() async {
    // the values in the table will be in the key value pairs so we
    //create in list map string and create function readNotes
    final db = await SQLhelper.myData();

    ///to open database
    return db.query('notes', orderBy: 'id'); // to show in id order
  }

  ///to update a data
  static Future<int> updateNote(int id, String titlenew, String notenew) async {
    // create a function updatenote,and give argmts that is to store newdatas from ui
    final db = await SQLhelper.myData(); // open the database
    final newdata = {
      'title': titlenew,
      'note': notenew,
      'createAt': DateTime.now().toString(),
      // assign new datas to a variable newdata
    };
    final result = await db.update('notes', newdata,
        where: "id =?",
        whereArgs: [id]); // update the datas to the table,and provide id to where replace
    return result;
  }

  ///delete data from table
  static Future<void> deleteNote(int id) async {
    // corresponding  id to which want to delete
    final db = await SQLhelper.myData();
    try {
      await db.delete('notes', where: "id =?", whereArgs: [id]);
    } catch (error) {
      debugPrint("Something went wrong");
    }
  }
}
