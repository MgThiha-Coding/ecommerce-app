import 'dart:async';

import 'package:hive_flutter/hive_flutter.dart';

class LazyHiveManager {
  static final Map<String, bool> _boxOpenStatus = {};

  static Future<Box<T>> getBox<T>(String boxName) async {
    if (!_boxOpenStatus.containsKey(boxName) || !_boxOpenStatus[boxName]!) {
      await Hive.openBox<T>(boxName);
      _boxOpenStatus[boxName] = true;
    }
    return Hive.box<T>(boxName);
  }

  static Future<void> preloadBox(String boxName) async {
    if (!_boxOpenStatus.containsKey(boxName)) {
      unawaited(getBox(boxName));
    }
  }
}
