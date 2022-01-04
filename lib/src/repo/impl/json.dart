import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../interface.dart';

class JsonRepo implements RepoInterface {
  final String _name;

  JsonRepo({
    /// the name of the repo
    required String name,
  }) : _name = name;

  Future<File> get _getDbFile async {
    Directory dirDB = await getApplicationDocumentsDirectory();
    File f = File(join(dirDB.path, "$_name.json"));
    if (!f.existsSync()) {
      f.writeAsStringSync(jsonEncode({}));
    }
    return f;
  }

  Future<Map<String, dynamic>> get _connection async {
    File f = await _getDbFile;
    Map<String, dynamic> data = jsonDecode(f.readAsStringSync());
    return data;
  }

  @override
  Future delete(String key) async {
    var db = await _connection;
    if (db.remove(key) != null) {
      var f = await _getDbFile;
      f.writeAsStringSync(jsonEncode(db));
    }
  }

  @override
  Future<Map<String, dynamic>> get(String key) async {
    var db = await _connection;
    return db[key];
  }

  @override
  Future insert(Map<String, dynamic> json) async {
    var db = await _connection;
    if (!db.containsKey(json['url'])) {
      var f = await _getDbFile;
      db.addAll({json['url']: json});
      f.writeAsStringSync(jsonEncode(db));
    }
  }

  @override
  Future update(Map<String, dynamic> json) async {
    var db = await _connection;
    if (db.containsKey(json['url'])) {
      var f = await _getDbFile;
      db[json['url']] = json;
      f.writeAsStringSync(jsonEncode(db));
    }
  }

  @override
  Future write(Map<String, dynamic> json) async {
    var db = await _connection;
    var f = await _getDbFile;
    if (!db.containsKey(json['url'])) {
      db.addAll({json['url']: json});
      f.writeAsStringSync(jsonEncode(db));
    } else {
      if (!mapEquals(db[json['url']], json)) {
        db.addAll({json['url']: json});
        f.writeAsStringSync(jsonEncode(db));
      }
    }
  }
}
