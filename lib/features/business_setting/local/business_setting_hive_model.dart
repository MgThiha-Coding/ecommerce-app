// business_setting_hive_model.dart
import 'package:picoshop_theme2/features/business_setting/model/business_setting_response.dart';

class BusinessSettingHiveModel {
  final int id;
  final String name;
  final int currencyId;
  final String salePrefix;
  final String purchasePrefix;
  final String currencyCode;
  final String currencySymbol;
  final int currencyDecimalPlaces;
  final String dateFormat;
  final String timeFormat;
  final String timeZone;
  final String? logo;
  final String? businessContactNo;
  final String? address;

  BusinessSettingHiveModel({
    required this.id,
    required this.name,
    required this.currencyId,
    required this.salePrefix,
    required this.purchasePrefix,
    required this.currencyCode,
    required this.currencySymbol,
    required this.currencyDecimalPlaces,
    required this.dateFormat,
    required this.timeFormat,
    required this.timeZone,
    this.logo,
    this.businessContactNo,
    this.address,
  });

  factory BusinessSettingHiveModel.fromDataModel(BusinessSettingData data) {
    return BusinessSettingHiveModel(
      id: data.id,
      name: data.name,
      currencyId: data.currencyId,
      salePrefix: data.salePrefix,
      purchasePrefix: data.purchasePrefix,
      currencyCode: data.currency.code,
      currencySymbol: data.currency.symbol,
      currencyDecimalPlaces: data.currencyDecimalPlaces,
      dateFormat: data.dateFormat,
      timeFormat: data.timeFormat,
      timeZone: data.timeZone,
      logo: data.logo,
      businessContactNo: data.businessContactNo,
      address: data.address,
    );
  }

  BusinessSettingData toDataModel() {
    return BusinessSettingData(
      id: id,
      name: name,
      currencyId: currencyId,
      secondaryCurrencyId: currencyId,
      lotControl: 'on',
      stockTransferData: StockTransferData(stockTransferShowPurchasePrice: '0'),
      usePaymentAccount: 1,
      startDate: DateTime.now().toString(),
      defaultProfitPercent: 0,
      finanicalYearStartMonth: 'january',
      salePrefix: salePrefix,
      purchasePrefix: purchasePrefix,
      stockTransferPrefix: 'ST',
      stockAdjustmentPrefix: 'SA',
      expensePrefix: 'EP',
      purchasePaymentPrefix: 'PCP',
      expensePaymentPrefix: 'EPP',
      salePaymentPrefix: 'SLP',
      expenseReportPrefix: 'EPR',
      businessLocationPrefix: 'LOC',
      enableRow: 1,
      ownerId: null,
      timeZone: timeZone,
      fyStartMonth: 1,
      accountingMethod: 'fifo',
      defaultSalesDiscount: null,
      sellPriceTax: 'includes',
      currencyDecimalPlaces: currencyDecimalPlaces,
      quantityDecimalPlaces: 2,
      logo: logo,
      skuPrefix: null,
      enableProductExpiry: 0,
      expiryType: 'add_expiry',
      onProductExpiry: 'keep_selling',
      stopSellingBefore: null,
      enableTooltip: 1,
      purchaseInDiffCurrency: 0,
      purchaseCurrencyId: null,
      pExchangeRate: '1.000',
      transactionEditDays: 30,
      stockExpiryAlertDays: 30,
      keyboardShortcuts: null,
      posSettings: null,
      essentialsSettings: null,
      weighingScaleSetting: null,
      enableBrand: 1,
      enableCategory: 1,
      enableSubCategory: 1,
      enablePriceTax: 1,
      enableLineDiscountForPurchase: 1,
      enableLineDiscountForSale: 1,
      enablePurchaseStatus: 1,
      enableLotNumber: 0,
      defaultUnit: null,
      enableSubUnits: 0,
      enableRacks: 0,
      enablePosition: 0,
      enableEditingProductFromPurchase: 1,
      salesCmsnAgnt: null,
      itemAdditionMethod: 1,
      enableInlineTax: 1,
      currencySymbolPlacement: 'after',
      enabledModules: null,
      dateFormat: dateFormat,
      timeFormat: timeFormat,
      refNoPrefixes: null,
      themeColor: null,
      createdBy: null,
      repairSettings: null,
      enableRp: 0,
      rpName: null,
      amountForUnitRp: '1.0000',
      minOrderTotalForRp: '1.0000',
      maxRpPerOrder: null,
      redeemAmountPerUnitRp: '1.0000',
      minOrderTotalForRedeem: '1.0000',
      minRedeemPoint: null,
      maxRedeemPoint: null,
      rpExpiryPeriod: null,
      rpExpiryType: 'year',
      emailSettings: null,
      smsSettings: null,
      customLabels: null,
      commonSettings: null,
      isActive: 1,
      createdAt: DateTime.now().toString(),
      updatedAt: DateTime.now().toString(),
      allowOverselling: 1,
      invoiceLayout: 2,
      altContactNo: null,
      businessContactNo: businessContactNo,
      address: address,
      zipPostalCode: null,
      city: null,
      state: null,
      country: null,
      expireAlertDay: 30,
      enablePaymentConfirmationInSale: '0',
      usePrintPreview: 0,
      prefixs: Prefixs(
        purchasePrefix: PrefixDetail(
          name: 'PU', year: false, month: false, day: false,
          cycle: 'continue', starterCount: '5', digit: '',
        ),
        salePrefix: PrefixDetail(
          name: 'SA', year: false, month: false, day: false,
          cycle: 'continue', starterCount: '5', digit: '',
        ),
        stockTransferPrefix: PrefixDetail(
          name: 'ST', year: false, month: false, day: false,
          cycle: 'continue', starterCount: '5', digit: '',
        ),
        stockAdjustmentPrefix: PrefixDetail(
          name: 'ST', year: false, month: false, day: false,
          cycle: 'continue', starterCount: '5', digit: '',
        ),
        expensePrefix: PrefixDetail(
          name: 'EX', year: false, month: false, day: false,
          cycle: 'continue', starterCount: '5', digit: '',
        ),
        purchasePaymentPrefix: PrefixDetail(
          name: 'PU', year: false, month: false, day: false,
          cycle: 'continue', starterCount: '5', digit: '',
        ),
        expensePaymentPrefix: PrefixDetail(
          name: 'EX', year: false, month: false, day: false,
          cycle: 'continue', starterCount: '5', digit: '',
        ),
        salePaymentPrefix: PrefixDetail(
          name: 'SA', year: false, month: false, day: false,
          cycle: 'continue', starterCount: '5', digit: '',
        ),
        expenseReportPrefix: PrefixDetail(
          name: 'EX', year: false, month: false, day: false,
          cycle: 'continue', starterCount: '5', digit: '',
        ),
        businessLocationPrefix: PrefixDetail(
          name: 'BU', year: false, month: false, day: false,
          cycle: 'continue', starterCount: '5', digit: '',
        ),
        referralPrefix: PrefixDetail(
          name: 'RE', year: false, month: false, day: false,
          cycle: 'continue', starterCount: '5', digit: '',
        ),
        referralPaymentPrefix: PrefixDetail(
          name: 'RE', year: false, month: false, day: false,
          cycle: 'continue', starterCount: '5', digit: '',
        ),
      ),
      variableCost: 'default',
      productLocationFilter: 1,
      currency: Currency(
        id: currencyId,
        businessId: 1,
        currencyType: 'fiat',
        name: currencyCode,
        country: '',
        code: currencyCode,
        symbol: currencySymbol,
        thoundsandSeprator: ',',
        decimalSeparator: '.',
      ),
    );
  }
}