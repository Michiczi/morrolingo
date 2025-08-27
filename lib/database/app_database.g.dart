// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $AppDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $AppDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<AppDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder implements $AppDatabaseBuilderContract {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $AppDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  QuestionDao? _questionDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `questions` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `subject` TEXT NOT NULL, `question` TEXT NOT NULL, `answer` TEXT NOT NULL)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  QuestionDao get questionDao {
    return _questionDaoInstance ??= _$QuestionDao(database, changeListener);
  }
}

class _$QuestionDao extends QuestionDao {
  _$QuestionDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _questionInsertionAdapter = InsertionAdapter(
            database,
            'questions',
            (Question item) => <String, Object?>{
                  'id': item.id,
                  'subject': item.subject,
                  'question': item.question,
                  'answer': item.answer
                }),
        _questionUpdateAdapter = UpdateAdapter(
            database,
            'questions',
            ['id'],
            (Question item) => <String, Object?>{
                  'id': item.id,
                  'subject': item.subject,
                  'question': item.question,
                  'answer': item.answer
                }),
        _questionDeletionAdapter = DeletionAdapter(
            database,
            'questions',
            ['id'],
            (Question item) => <String, Object?>{
                  'id': item.id,
                  'subject': item.subject,
                  'question': item.question,
                  'answer': item.answer
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Question> _questionInsertionAdapter;

  final UpdateAdapter<Question> _questionUpdateAdapter;

  final DeletionAdapter<Question> _questionDeletionAdapter;

  @override
  Future<List<Question>> getQuestionsBySubject(String subject) async {
    return _queryAdapter.queryList('SELECT * FROM questions WHERE subject = ?1',
        mapper: (Map<String, Object?> row) => Question(
            id: row['id'] as int?,
            subject: row['subject'] as String,
            question: row['question'] as String,
            answer: row['answer'] as String),
        arguments: [subject]);
  }

  @override
  Future<void> deleteQuestionsBySubject(String subjectName) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM questions WHERE subject = ?1',
        arguments: [subjectName]);
  }

  @override
  Future<void> updateSubjectName(
    String oldName,
    String newName,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE questions SET subject = ?2 WHERE subject = ?1',
        arguments: [oldName, newName]);
  }

  @override
  Future<List<String>> getSubjectList() async {
    return _queryAdapter.queryList('SELECT DISTINCT subject FROM questions',
        mapper: (Map<String, Object?> row) => row.values.first as String);
  }

  @override
  Future<void> insertQuestion(Question question) async {
    await _questionInsertionAdapter.insert(question, OnConflictStrategy.abort);
  }

  @override
  Future<void> insertMultipleQuestions(List<Question> questions) async {
    await _questionInsertionAdapter.insertList(
        questions, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateQuestion(Question question) async {
    await _questionUpdateAdapter.update(question, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateMultipleQuestions(List<Question> questions) async {
    await _questionUpdateAdapter.updateList(
        questions, OnConflictStrategy.replace);
  }

  @override
  Future<void> deleteQuestion(Question question) async {
    await _questionDeletionAdapter.delete(question);
  }

  @override
  Future<void> deleteMultipleQuestions(List<Question> questions) async {
    await _questionDeletionAdapter.deleteList(questions);
  }
}
