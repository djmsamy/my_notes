import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;
import 'package:mynotes/services/crud/crud_exceptions.dart';
class NotesService {
  Database? _db;

  List <DataBaseNote>_notes = [];
  final _notestreamController = StreamController<List<DataBaseNote>>.broadcast();
  
  Future<DataBaseUser>getOrCreateUser({required String email})async{
    try {
      final user = await getUser(email: email); 
      return user; 
    }on CouldNotFindUser {
      final createdUser = await createUser(email: email);
      return createdUser;
    }catch(e){
      rethrow;
    }
  }

  Future<void>_cacheNotes()async{
    final allNotes = await getAllNotes();
    _notes = allNotes.toList();
    _notestreamController.add(_notes);
  }

  Future<DataBaseNote>updateNote({required DataBaseNote note,required String text})async{
    final db = getDatabaseOrThrow();

    ///make sure note exists
    await getNote(id:note.id);

    ////update db
    final updatesCount = await db.update(noteTable,{
      textColumn:text,
      isSynchedWithCloudColumn:0,
      });

    if (updatesCount == 0) {
      throw CouldNotUpdateNote();
    } else {
      final updatedNote = await getNote(id: note.id);
      _notes.removeWhere((note)=> note.id == updatedNote.id);
      _notes.add(updatedNote);
      _notestreamController.add(_notes);
      return updatedNote;
    }
  }

  Future<Iterable<DataBaseNote>>getAllNotes()async{
    final db = getDatabaseOrThrow();
    final notes = await db.query(noteTable);
   return notes.map((noteRow) => DataBaseNote.fromRow(noteRow));
    
  }

  Future<DataBaseNote>getNote({required int id})async{
    final db = getDatabaseOrThrow();
    final notes = await db.query(
      noteTable,
      limit: 1,
      where: 'id =?',
      whereArgs: [id],
      );
    if (notes.isEmpty) {
      throw CouldNotFindNote();
    }else{
      final note = DataBaseNote.fromRow(notes.first);
      _notes.removeWhere((note) => note.id == id);
      _notes.add(note);
      _notestreamController.add(_notes);
      return note;
    }
  }
  
  Future<int>deleteAllNotes()async{
    final db = getDatabaseOrThrow();
    final numberOfDeletions = await db.delete(noteTable);
    _notes = [];
    _notestreamController.add(_notes);
    return numberOfDeletions;
  }

  Future<void>deleteNote({required int id})async{
    final db = getDatabaseOrThrow();
    final deletedCount = await db.delete(
        noteTable,
        where: 'id = ?',
        whereArgs: [id],
        );
  if (deletedCount == 0) {
    throw CouldNotDeleteNote();
  }else{
    _notes.removeWhere((note)=>note.id == id);
    _notestreamController.add(_notes);
  }
  }

  Future<DataBaseNote> createNote({required DataBaseUser owner})async{
    final db = getDatabaseOrThrow();
    ////make sure owner exists in database with correct ID////
    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      throw CouldNotFindUser();
    } 
    const text = "";
    final noteId = await db.insert(noteTable,{
      userIdColumn:owner.id,
      textColumn:text,
      isSynchedWithCloudColumn:1,
    });

    final note = DataBaseNote(
          id: noteId,
          userId: owner.id,
          text: text,
          isSynchedWithCloud: true
         );
    _notes.add(note);
    _notestreamController.add(_notes);
    return note;
  }

  Future<DataBaseUser> getUser({required  String email}) async {
    final db = getDatabaseOrThrow();
    final result = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (result.isEmpty) {
      throw CouldNotFindUser();
    }else{
      return DataBaseUser.fromRow(result.first);
    }
  }

  Future<DataBaseUser> createUser({required String email}) async{
    final db = getDatabaseOrThrow();
    final result = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );

    if (result.isNotEmpty) {
      throw UserAlreadyExists();
    }
    final userId = await db.insert(userTable,{
      emailColumn: email.toLowerCase(),
    });

    return DataBaseUser(id: userId,
                        email: email
          );
  }

  Future<void> deleteUser({required String email}) async {
    final db = getDatabaseOrThrow();
    final deletedCount = await db.delete(
        userTable,
        where: 'email = ?',
        whereArgs: [email.toLowerCase()] 
        );
        if (deletedCount != 1) {
          throw CouldNotDeleteUser();
        }
  }

  Database getDatabaseOrThrow(){
  final db = _db;
  if (db == null) {
    throw DataBaseAlreadyClose();
  } else {
    return db;
  }
}

  Future<void> close() async{
    final db = _db;
    if (db == null) {
     throw DataBaseAlreadyClose();
   }else{
    await db.close();
    _db = null;
   }

  }
  
  Future<void> open() async{
   if (_db != null) {
     throw DataBaseAlreadyOpen();
   }
   try {
     final docsPath = await getApplicationDocumentsDirectory();
     final dbPath = join(docsPath.path, dbName);
     final db = await openDatabase(dbPath);
     _db = db;
     //// create user table/////
      await  db.execute(createUserTable);
       //// create note table/////
      await  db.execute(createNoteTable);
      await _cacheNotes();
   }on MissingPlatformDirectoryException{
     throw UnableToGetClassDirectory();
   }
  }

}
class DataBaseUser {
  final int id;
  final String email;

  const DataBaseUser({
    required this.id,
    required this.email
  });
  DataBaseUser.fromRow(Map<String, Object?> map) : 
    id = map[idColumn]as int ,
    email = map[emailColumn] as String;

  @override
  String toString() => "Person, ID = $id, Email = $email";

  @override bool operator == (covariant DataBaseUser other) => id == other.id ;
  
  @override int get hashCode => id.hashCode;

}

class DataBaseNote {
  final int id;
  final int userId;
  final String text;
  final bool isSynchedWithCloud;

  DataBaseNote({
    required this.id,
    required this.userId,
    required this.text,
    required this.isSynchedWithCloud
  });

  DataBaseNote.fromRow(Map<String, Object?> map) :
    id = map[idColumn] as int,
    userId = map[userIdColumn] as int,
    text = map[textColumn] as String,
    isSynchedWithCloud = (map[isSynchedWithCloudColumn] as int) == 0 ? true : false;

    @override
  String toString() => "Note, ID = $id, userId = $userId, isSynchedWithCloud = $isSynchedWithCloud , text = $text";

  @override bool operator == (covariant DataBaseNote other) => id == other.id ;
  
  @override int get hashCode => id.hashCode;
 }


const dbName = 'notes.db';
const noteTable = 'note';
const userTable = 'user';
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const textColumn = 'text';
const isSynchedWithCloudColumn = 'is_synched_with_cloud';

const createUserTable = '''CREATE TABLE IF NOT EXISTS "user" (
	                              "id"	INTEGER NOT NULL UNIQUE,
	                              "email"	TEXT NOT NULL UNIQUE,
	                              PRIMARY KEY("id")
                                );
                        ''';
     
const createNoteTable = '''CREATE TABLE IF NOT EXISTS "note" (
                                "id"	INTEGER NOT NULL,
                                "user_id"	INTEGER NOT NULL,
                                "text"	TEXT,
                                "is_synched_with_cloud"	INTEGER NOT NULL DEFAULT 0,
                                PRIMARY KEY("id"),
                                FOREIGN KEY("user_id") REFERENCES "user"("id")
                                );
                        ''';
     