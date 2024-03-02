import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;

class DataBaseAlreadyOpen implements Exception {}
class UnableToGetClassDirectory implements Exception {}
class DataBaseAlreadyClose implements Exception {}
class CouldNotDeleteUser implements Exception {}
class UserAlreadyExists implements Exception {}
class CouldNotFindUser implements Exception {}

class NotesService {
  Database? _db;

 
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
     