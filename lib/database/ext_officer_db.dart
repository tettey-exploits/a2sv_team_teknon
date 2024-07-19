import 'package:sqflite/sqflite.dart';
import 'package:farmnets/database/database_service.dart';
import 'package:farmnets/models/ext_officer.dart';

class ExtensionOfficerDB {
  final tableName = 'officer_details';

  Future<void> createTable(Database database) async {
    await database.execute("""CREATE TABLE IF NOT EXISTS $tableName(
      "id" INTEGER NOT NULL,
      "name" TEXT NOT NULL,
      "email" TEXT NOT NULL,
      "location" TEXT NOT NULL,
      "imagePath" TEXT,
      "createdAt" INTEGER NOT NULL DEFAULT (cast(strftime('%s','now') as int)),
      "updatedAt" INTEGER,
      PRIMARY KEY("id" AUTOINCREMENT)
    );""");
  }

  Future<int> create({
    required String name,
    required String email,
    required String location,
    String? imagePath,
  }) async {
    final database = await DatabaseService().database;
    return await database.rawInsert(
        '''INSERT INTO $tableName (name,email,location,imagePath,createdAt)
        VALUES (?,?,?,?,?)''',
        [
          name,
          email,
          location,
          imagePath,
          DateTime.now().millisecondsSinceEpoch
        ]);
  }

  Future<List<ExtensionOfficer>> fetchAll() async {
    final database = await DatabaseService().database;
    final fetchedOfficers = await database.rawQuery(
        '''SELECT * from $tableName ORDER BY COALESCE(updatedAt,createdAt)''');
    return fetchedOfficers
        .map((officer) => ExtensionOfficer.fromSqfliteDatabase(officer))
        .toList();
  }

  Future<ExtensionOfficer> fetchById(int id) async {
    final database = await DatabaseService().database;
    final fetchedOfficer = await database
        .rawQuery('''SELECT * from $tableName WHERE id = ? ''', [id]);

    /* if (ExtensionOfficer.isNotEmpty) {
      return ExtensionOfficer.fromSqfliteDatabase(ExtensionOfficer.first);
    } else {
      throw Exception('ExtensionOfficer with id $id not found');
    } */
    return ExtensionOfficer.fromSqfliteDatabase(fetchedOfficer.first);
  }

  Future<ExtensionOfficer> fetchByName(String name) async {
    final database = await DatabaseService().database;
    final List<Map<String, dynamic>> result = await database
        .rawQuery('''SELECT * FROM $tableName WHERE name = ?''', [name]);

    if (result.isNotEmpty) {
      return ExtensionOfficer.fromSqfliteDatabase(result.first);
    } else {
      throw Exception('ExtensionOfficer with name $name not found');
    }
  }

  Future<ExtensionOfficer> fetchByEmail(String email) async {
    final database = await DatabaseService().database;
    final List<Map<String, dynamic>> result = await database
        .rawQuery('''SELECT * FROM $tableName WHERE email = ?''', [email]);

    if (result.isNotEmpty) {
      return ExtensionOfficer.fromSqfliteDatabase(result.first);
    } else {
      throw Exception('ExtensionOfficer with email $email not found');
    }
  }

  Future<void> deleteByName(String name) async {
    final database = await DatabaseService().database;
    await database
        .rawDelete('''DELETE FROM $tableName WHERE name = ?''', [name]);
  }

  Future<void> deleteAll() async {
    final database = await DatabaseService().database;
    await database.delete(tableName);
  }
}
