import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;

class DataBaseAlreadyOpenException implements Exception {
  
}
class UnableToGetClassDirectory implements Exception {
  
}
class NotesService {
  Database? _db;

  Future<void> open() async{
   if (_db != null) {
     throw DataBaseAlreadyOpenException();
   }
   try {
     final docsPath = await getApplicationDocumentsDirectory();
     final path = join(docsPath.path, dbName);
     
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