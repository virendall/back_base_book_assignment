import 'package:back_base_assignment/core/error/exceptions.dart';
import 'package:back_base_assignment/data/models/book_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

abstract class BookLocalDataSource {
  Future<List<BookModel>> getSavedBooks();
  Future<void> saveBook(BookModel book);
  Future<void> deleteBook(String id);
  Future<List<String>> getSavedBookIds();
}

class BookLocalDataSourceImpl implements BookLocalDataSource {
  static const _databaseName = "book_finder.db";
  static const _databaseVersion = 2; // Incremented version
  static const _tableName = 'books';

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        author TEXT NOT NULL,
        coverUrl TEXT NOT NULL,
        firstPublishYear INTEGER,
        numberOfPages INTEGER
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute("DROP TABLE IF EXISTS $_tableName");
      await _onCreate(db, newVersion);
    }
  }

  @override
  Future<void> saveBook(BookModel book) async {
    try {
      final db = await database;
      await db.insert(
        _tableName,
        book.toDbMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e, st) {
      throw CacheException(
        message: 'Failed to save book: $e',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> deleteBook(String id) async {
    try {
      final db = await database;
      await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
    } catch (e, st) {
      throw CacheException(
        message: 'Failed to delete book: $e',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<List<BookModel>> getSavedBooks() async {
    try {
      final db = await database;
      final maps = await db.query(_tableName);
      return maps.map((map) => BookModel.fromDb(map)).toList();
    } catch (e, st) {
      throw CacheException(
        message: 'Failed to load saved books: $e',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<List<String>> getSavedBookIds() async {
    try {
      final db = await database;
      final maps = await db.query(_tableName, columns: ['id']);
      return maps.map((map) => map['id'] as String).toList();
    } catch (e, st) {
      throw CacheException(
        message: 'Failed to load saved book ids: $e',
        cause: e,
        stackTrace: st,
      );
    }
  }
}
