import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:picoshop_theme2/features/brands/local/brand_data_hive.dart';
import 'package:picoshop_theme2/features/brands/local/brand_data_hive_adapatar.dart';
import 'package:picoshop_theme2/features/business_setting/local/business_setting_hive_adapter.dart';
import 'package:picoshop_theme2/features/business_setting/local/business_setting_hive_model.dart';
import 'package:picoshop_theme2/features/category/local/category_data_hive.dart';
import 'package:picoshop_theme2/features/category/local/category_data_hive_adapatar.dart';
import 'package:picoshop_theme2/features/product/local/product_data_hive.dart';
import 'package:picoshop_theme2/features/product/local/product_data_hive_adapater.dart';

class HiveConfig {
  static Future<void> init() async {
    await Hive.initFlutter();
    _registerAdapters();
  }

  static void _registerAdapters() {
    Hive.registerAdapter(ProductDataHiveAdapter());
    Hive.registerAdapter(BrandDataHiveAdapter());
    Hive.registerAdapter(CategoryDataHiveAdapter());
    Hive.registerAdapter(BusinessSettingHiveAdapter());
  }

  /// Open critical boxes first (blocking)
  static Future<void> openCriticalBoxes() async {
    await _openBoxSafe<BusinessSettingHiveModel>('business_settings');
  }

  /// Open non-critical boxes in background
  static Future<void> openNonCriticalBoxes() async {
    unawaited(_openBoxSafe<ProductHiveModel>('products'));
    unawaited(_openBoxSafe<BrandHiveModel>('brands'));
    unawaited(_openBoxSafe<CategoryHiveModel>('category'));
  }

  static Future<void> _openBoxSafe<T>(String boxName) async {
    try {
      await Hive.openBox<T>(boxName);
    } catch (e) {
      debugPrint('Box $boxName error: $e');
      try {
        await Hive.deleteBoxFromDisk(boxName);
        await Hive.openBox<T>(boxName);
      } catch (e2) {
        debugPrint('Failed to recover box $boxName: $e2');
      }
    }
  }
}
