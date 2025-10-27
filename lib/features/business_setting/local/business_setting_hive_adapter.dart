
import 'package:hive_flutter/hive_flutter.dart';
import 'business_setting_hive_model.dart';

class BusinessSettingHiveAdapter extends TypeAdapter<BusinessSettingHiveModel> {
  @override
  final int typeId = 3;

  @override
  BusinessSettingHiveModel read(BinaryReader reader) {
    return BusinessSettingHiveModel(
      id: reader.readInt(),
      name: reader.readString(),
      currencyId: reader.readInt(),
      salePrefix: reader.readString(),
      purchasePrefix: reader.readString(),
      currencyCode: reader.readString(),
      currencySymbol: reader.readString(),
      currencyDecimalPlaces: reader.readInt(),
      dateFormat: reader.readString(),
      timeFormat: reader.readString(),
      timeZone: reader.readString(),
      logo: reader.readString(),
      businessContactNo: reader.readString(),
      address: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, BusinessSettingHiveModel obj) {
    writer.writeInt(obj.id);
    writer.writeString(obj.name);
    writer.writeInt(obj.currencyId);
    writer.writeString(obj.salePrefix);
    writer.writeString(obj.purchasePrefix);
    writer.writeString(obj.currencyCode);
    writer.writeString(obj.currencySymbol);
    writer.writeInt(obj.currencyDecimalPlaces);
    writer.writeString(obj.dateFormat);
    writer.writeString(obj.timeFormat);
    writer.writeString(obj.timeZone);
    writer.writeString(obj.logo ?? '');
    writer.writeString(obj.businessContactNo ?? '');
    writer.writeString(obj.address ?? '');
  }
}