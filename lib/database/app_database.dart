
import 'dart:async';
import 'package:floor/floor.dart';
import 'package:morrolingo/database/question.dart';
import 'package:morrolingo/database/question_dao.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

part 'app_database.g.dart';

@Database(version: 1, entities: [Question])
abstract class AppDatabase extends FloorDatabase {
  QuestionDao get questionDao;

  static AppDatabase? _database;

  static Future<AppDatabase> get instance async {
    _database ??= await $FloorAppDatabase
        .databaseBuilder('app_database.db')
        .build();
    return _database!;
  }
}
