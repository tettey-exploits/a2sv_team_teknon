import 'package:sqflite/sqflite.dart';
import 'package:farmnets/database/database_service.dart';
import 'package:farmnets/models/farmer.dart';

/// Managing the SQLite database operations related to farmers' details.

class FarmerDB {
  final tableName = 'farmer_details';

  /// Creates the necessary table in the provided database for storing farmer details.
  ///
  /// [database]: The database instance to create the table in.
  Future<void> createTable(Database database) async {
    await database.execute("""CREATE TABLE IF NOT EXISTS $tableName(
      "id" INTEGER NOT NULL,
      "name" TEXT NOT NULL,
      "contact" TEXT NOT NULL,
      "location" TEXT NOT NULL,
      "createdAt" INTEGER NOT NULL DEFAULT (cast(strftime('%s','now') as int)),
      "updatedAt" INTEGER,
      PRIMARY KEY("id" AUTOINCREMENT)
    );""");
  }

  /// Inserts a new farmer record into the database.
  ///
  /// [name]: The name of the farmer.
  /// [contact]: The contact information of the farmer.
  /// [location]: The location of the farmer.
  ///
  /// Returns the ID of the newly inserted record.
  Future<int> create({
    required String name,
    required String contact,
    required String location,
  }) async {
    final database = await DatabaseService().database;
    return await database.rawInsert(
        '''INSERT INTO $tableName (name,contact,location,createdAt)
        VALUES (?,?,?,?)''',
        [name, contact, location, DateTime.now().millisecondsSinceEpoch]);
  }

  /// Fetches all farmers' details from the database.
  ///
  /// Returns a list of Farmer objects representing all farmers in the database.
  Future<List<Farmer>> fetchAll() async {
    final database = await DatabaseService().database;
    final fetchedFarmers = await database.rawQuery(
        '''SELECT * from $tableName ORDER BY COALESCE(updatedAt,createdAt)''');
    return fetchedFarmers
        .map((farmer) => Farmer.fromSqfliteDatabase(farmer))
        .toList();
  }

  /// Fetches a farmer's details by their ID from the database.
  ///
  /// [id]: The ID of the farmer to fetch.
  ///
  /// Returns a Farmer object representing the fetched farmer's details.
  Future<Farmer> fetchById(int id) async {
    final database = await DatabaseService().database;
    final fetchedFarmer = await database
        .rawQuery('''SELECT * from $tableName WHERE id = ? ''', [id]);
    return Farmer.fromSqfliteDatabase(fetchedFarmer.first);
  }

  /// Fetches a farmer's details by their name from the database.
  ///
  /// [name]: The name of the farmer to fetch.
  ///
  /// Returns a Farmer object representing the fetched farmer's details.
  ///
  /// Throws an Exception if the farmer with the given name is not found.
  Future<Farmer> fetchByName(String name) async {
    final database = await DatabaseService().database;
    final List<Map<String, dynamic>> result = await database
        .rawQuery('''SELECT * FROM $tableName WHERE name = ?''', [name]);

    if (result.isNotEmpty) {
      return Farmer.fromSqfliteDatabase(result.first);
    } else {
      throw Exception('Farmer with name $name not found');
    }
  }

  /// Deletes a farmer's record from the database by their name.
  ///
  /// [name]: The name of the farmer to delete.
  Future<void> deleteByName(String name) async {
    final database = await DatabaseService().database;
    await database
        .rawDelete('''DELETE FROM $tableName WHERE name = ?''', [name]);
  }

  /// Deletes all farmer records from the database.
  Future<void> deleteAll() async {
    final database = await DatabaseService().database;
    await database.delete(tableName);
  }
}
