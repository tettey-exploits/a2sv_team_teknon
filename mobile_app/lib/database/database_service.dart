import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:farmnets/database/ext_officer_db.dart';

import 'farmer_db.dart';

/// For managing a SQLite database used for storing user details.

class DatabaseService {
  Database? _database;

  /// Retrieves the database instance, initializing it if necessary.
  ///
  /// Returns a Future that completes with the database instance.
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initialize();
    return _database!;
  }

  /// Provides the complete path to the database file.
  ///
  /// Returns a Future that completes with the full path to the database file.
  Future<String> get fullPath async {
    const name = 'user_details.db';
    final path = await getDatabasesPath();
    return p.join(path, name);
  }

  /// Initializes the database by opening it and creating necessary tables.
  ///
  /// Returns a Future that completes with the initialized database instance.
  Future<Database> _initialize() async {
    final path = await fullPath;
    var database = await openDatabase(
      path,
      version: 1,
      onCreate: create,
      singleInstance: true,
    );
    return database;
  }

  /// Creates necessary tables in the database.
  ///
  /// [database]: The database instance to create tables in.
  /// [version]: The version of the database.
  Future<void> create(Database database, int version) async {
    await ExtensionOfficerDB().createTable(database);
    await FarmerDB().createTable(database);

  }
}
