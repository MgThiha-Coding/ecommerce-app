class BusinessSettingResponse {
  final bool success;
  final String message;
  final List<BusinessSettingData> data;

  BusinessSettingResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory BusinessSettingResponse.fromJson(Map<String, dynamic> json) {
    return BusinessSettingResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => BusinessSettingData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}

class BusinessSettingData {
  final int id;
  final String name;
  final int currencyId;
  final int secondaryCurrencyId;
  final String lotControl;
  final StockTransferData stockTransferData;
  final int usePaymentAccount;
  final String startDate;
  final int defaultProfitPercent;
  final String finanicalYearStartMonth;
  final String salePrefix;
  final String purchasePrefix;
  final String stockTransferPrefix;
  final String stockAdjustmentPrefix;
  final String expensePrefix;
  final String purchasePaymentPrefix;
  final String expensePaymentPrefix;
  final String salePaymentPrefix;
  final String expenseReportPrefix;
  final String businessLocationPrefix;
  final int enableRow;
  final int? ownerId;
  final String timeZone;
  final int fyStartMonth;
  final String accountingMethod;
  final dynamic defaultSalesDiscount;
  final String sellPriceTax;
  final int currencyDecimalPlaces;
  final int quantityDecimalPlaces;
  final String? logo;
  final String? skuPrefix;
  final int enableProductExpiry;
  final String expiryType;
  final String onProductExpiry;
  final dynamic stopSellingBefore;
  final int enableTooltip;
  final int purchaseInDiffCurrency;
  final int? purchaseCurrencyId;
  final String pExchangeRate;
  final int transactionEditDays;
  final int stockExpiryAlertDays;
  final dynamic keyboardShortcuts;
  final dynamic posSettings;
  final dynamic essentialsSettings;
  final dynamic weighingScaleSetting;
  final int enableBrand;
  final int enableCategory;
  final int enableSubCategory;
  final int enablePriceTax;
  final int enableLineDiscountForPurchase;
  final int enableLineDiscountForSale;
  final int enablePurchaseStatus;
  final int enableLotNumber;
  final dynamic defaultUnit;
  final int enableSubUnits;
  final int enableRacks;
  final int enablePosition;
  final int enableEditingProductFromPurchase;
  final dynamic salesCmsnAgnt;
  final int itemAdditionMethod;
  final int enableInlineTax;
  final String currencySymbolPlacement;
  final dynamic enabledModules;
  final String dateFormat;
  final String timeFormat;
  final dynamic refNoPrefixes;
  final String? themeColor;
  final int? createdBy;
  final dynamic repairSettings;
  final int enableRp;
  final String? rpName;
  final String amountForUnitRp;
  final String minOrderTotalForRp;
  final dynamic maxRpPerOrder;
  final String redeemAmountPerUnitRp;
  final String minOrderTotalForRedeem;
  final dynamic minRedeemPoint;
  final dynamic maxRedeemPoint;
  final dynamic rpExpiryPeriod;
  final String rpExpiryType;
  final dynamic emailSettings;
  final dynamic smsSettings;
  final dynamic customLabels;
  final dynamic commonSettings;
  final int isActive;
  final String createdAt;
  final String updatedAt;
  final int allowOverselling;
  final int invoiceLayout;
  final String? altContactNo;
  final String? businessContactNo;
  final String? address;
  final String? zipPostalCode;
  final String? city;
  final String? state;
  final String? country;
  final int expireAlertDay;
  final String enablePaymentConfirmationInSale;
  final int usePrintPreview;
  final Prefixs prefixs;
  final String variableCost;
  final int productLocationFilter;
  final Currency currency;

  BusinessSettingData({
    required this.id,
    required this.name,
    required this.currencyId,
    required this.secondaryCurrencyId,
    required this.lotControl,
    required this.stockTransferData,
    required this.usePaymentAccount,
    required this.startDate,
    required this.defaultProfitPercent,
    required this.finanicalYearStartMonth,
    required this.salePrefix,
    required this.purchasePrefix,
    required this.stockTransferPrefix,
    required this.stockAdjustmentPrefix,
    required this.expensePrefix,
    required this.purchasePaymentPrefix,
    required this.expensePaymentPrefix,
    required this.salePaymentPrefix,
    required this.expenseReportPrefix,
    required this.businessLocationPrefix,
    required this.enableRow,
    this.ownerId,
    required this.timeZone,
    required this.fyStartMonth,
    required this.accountingMethod,
    this.defaultSalesDiscount,
    required this.sellPriceTax,
    required this.currencyDecimalPlaces,
    required this.quantityDecimalPlaces,
    this.logo,
    this.skuPrefix,
    required this.enableProductExpiry,
    required this.expiryType,
    required this.onProductExpiry,
    this.stopSellingBefore,
    required this.enableTooltip,
    required this.purchaseInDiffCurrency,
    this.purchaseCurrencyId,
    required this.pExchangeRate,
    required this.transactionEditDays,
    required this.stockExpiryAlertDays,
    this.keyboardShortcuts,
    this.posSettings,
    this.essentialsSettings,
    this.weighingScaleSetting,
    required this.enableBrand,
    required this.enableCategory,
    required this.enableSubCategory,
    required this.enablePriceTax,
    required this.enableLineDiscountForPurchase,
    required this.enableLineDiscountForSale,
    required this.enablePurchaseStatus,
    required this.enableLotNumber,
    this.defaultUnit,
    required this.enableSubUnits,
    required this.enableRacks,
    required this.enablePosition,
    required this.enableEditingProductFromPurchase,
    this.salesCmsnAgnt,
    required this.itemAdditionMethod,
    required this.enableInlineTax,
    required this.currencySymbolPlacement,
    this.enabledModules,
    required this.dateFormat,
    required this.timeFormat,
    this.refNoPrefixes,
    this.themeColor,
    this.createdBy,
    this.repairSettings,
    required this.enableRp,
    this.rpName,
    required this.amountForUnitRp,
    required this.minOrderTotalForRp,
    this.maxRpPerOrder,
    required this.redeemAmountPerUnitRp,
    required this.minOrderTotalForRedeem,
    this.minRedeemPoint,
    this.maxRedeemPoint,
    this.rpExpiryPeriod,
    required this.rpExpiryType,
    this.emailSettings,
    this.smsSettings,
    this.customLabels,
    this.commonSettings,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.allowOverselling,
    required this.invoiceLayout,
    this.altContactNo,
    this.businessContactNo,
    this.address,
    this.zipPostalCode,
    this.city,
    this.state,
    this.country,
    required this.expireAlertDay,
    required this.enablePaymentConfirmationInSale,
    required this.usePrintPreview,
    required this.prefixs,
    required this.variableCost,
    required this.productLocationFilter,
    required this.currency,
  });

  factory BusinessSettingData.fromJson(Map<String, dynamic> json) {
    return BusinessSettingData(
      id: json['id'] as int,
      name: json['name'] as String,
      currencyId: json['currency_id'] as int,
      secondaryCurrencyId: json['secondary_currency_id'] as int,
      lotControl: json['lot_control'] as String,
      stockTransferData: StockTransferData.fromJson(json['stock_transfer_data'] as Map<String, dynamic>),
      usePaymentAccount: json['use_paymentAccount'] as int,
      startDate: json['start_date'] as String,
      defaultProfitPercent: json['default_profit_percent'] as int,
      finanicalYearStartMonth: json['finanical_year_start_month'] as String,
      salePrefix: json['sale_prefix'] as String,
      purchasePrefix: json['purchase_prefix'] as String,
      stockTransferPrefix: json['stock_transfer_prefix'] as String,
      stockAdjustmentPrefix: json['stock_adjustment_prefix'] as String,
      expensePrefix: json['expense_prefix'] as String,
      purchasePaymentPrefix: json['purchase_payment_prefix'] as String,
      expensePaymentPrefix: json['expense_payment_prefix'] as String,
      salePaymentPrefix: json['sale_payment_prefix'] as String,
      expenseReportPrefix: json['expense_report_prefix'] as String,
      businessLocationPrefix: json['business_location_prefix'] as String,
      enableRow: json['enable_row'] as int,
      ownerId: json['owner_id'] as int?,
      timeZone: json['time_zone'] as String,
      fyStartMonth: json['fy_start_month'] as int,
      accountingMethod: json['accounting_method'] as String,
      defaultSalesDiscount: json['default_sales_discount'],
      sellPriceTax: json['sell_price_tax'] as String,
      currencyDecimalPlaces: json['currency_decimal_places'] as int,
      quantityDecimalPlaces: json['quantity_decimal_places'] as int,
      logo: json['logo'] as String?,
      skuPrefix: json['sku_prefix'] as String?,
      enableProductExpiry: json['enable_product_expiry'] as int,
      expiryType: json['expiry_type'] as String,
      onProductExpiry: json['on_product_expiry'] as String,
      stopSellingBefore: json['stop_selling_before'],
      enableTooltip: json['enable_tooltip'] as int,
      purchaseInDiffCurrency: json['purchase_in_diff_currency'] as int,
      purchaseCurrencyId: json['purchase_currency_id'] as int?,
      pExchangeRate: json['p_exchange_rate'] as String,
      transactionEditDays: json['transaction_edit_days'] as int,
      stockExpiryAlertDays: json['stock_expiry_alert_days'] as int,
      keyboardShortcuts: json['keyboard_shortcuts'],
      posSettings: json['pos_settings'],
      essentialsSettings: json['essentials_settings'],
      weighingScaleSetting: json['weighing_scale_setting'],
      enableBrand: json['enable_brand'] as int,
      enableCategory: json['enable_category'] as int,
      enableSubCategory: json['enable_sub_category'] as int,
      enablePriceTax: json['enable_price_tax'] as int,
      enableLineDiscountForPurchase: json['enable_line_discount_for_purchase'] as int,
      enableLineDiscountForSale: json['enable_line_discount_for_sale'] as int,
      enablePurchaseStatus: json['enable_purchase_status'] as int,
      enableLotNumber: json['enable_lot_number'] as int,
      defaultUnit: json['default_unit'],
      enableSubUnits: json['enable_sub_units'] as int,
      enableRacks: json['enable_racks'] as int,
      enablePosition: json['enable_position'] as int,
      enableEditingProductFromPurchase: json['enable_editing_product_from_purchase'] as int,
      salesCmsnAgnt: json['sales_cmsn_agnt'],
      itemAdditionMethod: json['item_addition_method'] as int,
      enableInlineTax: json['enable_inline_tax'] as int,
      currencySymbolPlacement: json['currency_symbol_placement'] as String,
      enabledModules: json['enabled_modules'],
      dateFormat: json['date_format'] as String,
      timeFormat: json['time_format'] as String,
      refNoPrefixes: json['ref_no_prefixes'],
      themeColor: json['theme_color'] as String?,
      createdBy: json['created_by'] as int?,
      repairSettings: json['repair_settings'],
      enableRp: json['enable_rp'] as int,
      rpName: json['rp_name'] as String?,
      amountForUnitRp: json['amount_for_unit_rp'] as String,
      minOrderTotalForRp: json['min_order_total_for_rp'] as String,
      maxRpPerOrder: json['max_rp_per_order'],
      redeemAmountPerUnitRp: json['redeem_amount_per_unit_rp'] as String,
      minOrderTotalForRedeem: json['min_order_total_for_redeem'] as String,
      minRedeemPoint: json['min_redeem_point'],
      maxRedeemPoint: json['max_redeem_point'],
      rpExpiryPeriod: json['rp_expiry_period'],
      rpExpiryType: json['rp_expiry_type'] as String,
      emailSettings: json['email_settings'],
      smsSettings: json['sms_settings'],
      customLabels: json['custom_labels'],
      commonSettings: json['common_settings'],
      isActive: json['is_active'] as int,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      allowOverselling: json['allow_overselling'] as int,
      invoiceLayout: json['invoice_layout'] as int,
      altContactNo: json['alt_contact_no'] as String?,
      businessContactNo: json['business_contact_no'] as String?,
      address: json['address'] as String?,
      zipPostalCode: json['zip_postal_code'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String?,
      expireAlertDay: json['expire_alert_day'] as int,
      enablePaymentConfirmationInSale: json['enable_payment_confirmation_in_sale'] as String,
      usePrintPreview: json['use_print_preview'] as int,
      prefixs: Prefixs.fromJson(json['prefixs'] as Map<String, dynamic>),
      variableCost: json['variable_cost'] as String,
      productLocationFilter: json['product_location_filter'] as int,
      currency: Currency.fromJson(json['currency'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'currency_id': currencyId,
      'secondary_currency_id': secondaryCurrencyId,
      'lot_control': lotControl,
      'stock_transfer_data': stockTransferData.toJson(),
      'use_paymentAccount': usePaymentAccount,
      'start_date': startDate,
      'default_profit_percent': defaultProfitPercent,
      'finanical_year_start_month': finanicalYearStartMonth,
      'sale_prefix': salePrefix,
      'purchase_prefix': purchasePrefix,
      'stock_transfer_prefix': stockTransferPrefix,
      'stock_adjustment_prefix': stockAdjustmentPrefix,
      'expense_prefix': expensePrefix,
      'purchase_payment_prefix': purchasePaymentPrefix,
      'expense_payment_prefix': expensePaymentPrefix,
      'sale_payment_prefix': salePaymentPrefix,
      'expense_report_prefix': expenseReportPrefix,
      'business_location_prefix': businessLocationPrefix,
      'enable_row': enableRow,
      'owner_id': ownerId,
      'time_zone': timeZone,
      'fy_start_month': fyStartMonth,
      'accounting_method': accountingMethod,
      'default_sales_discount': defaultSalesDiscount,
      'sell_price_tax': sellPriceTax,
      'currency_decimal_places': currencyDecimalPlaces,
      'quantity_decimal_places': quantityDecimalPlaces,
      'logo': logo,
      'sku_prefix': skuPrefix,
      'enable_product_expiry': enableProductExpiry,
      'expiry_type': expiryType,
      'on_product_expiry': onProductExpiry,
      'stop_selling_before': stopSellingBefore,
      'enable_tooltip': enableTooltip,
      'purchase_in_diff_currency': purchaseInDiffCurrency,
      'purchase_currency_id': purchaseCurrencyId,
      'p_exchange_rate': pExchangeRate,
      'transaction_edit_days': transactionEditDays,
      'stock_expiry_alert_days': stockExpiryAlertDays,
      'keyboard_shortcuts': keyboardShortcuts,
      'pos_settings': posSettings,
      'essentials_settings': essentialsSettings,
      'weighing_scale_setting': weighingScaleSetting,
      'enable_brand': enableBrand,
      'enable_category': enableCategory,
      'enable_sub_category': enableSubCategory,
      'enable_price_tax': enablePriceTax,
      'enable_line_discount_for_purchase': enableLineDiscountForPurchase,
      'enable_line_discount_for_sale': enableLineDiscountForSale,
      'enable_purchase_status': enablePurchaseStatus,
      'enable_lot_number': enableLotNumber,
      'default_unit': defaultUnit,
      'enable_sub_units': enableSubUnits,
      'enable_racks': enableRacks,
      'enable_position': enablePosition,
      'enable_editing_product_from_purchase': enableEditingProductFromPurchase,
      'sales_cmsn_agnt': salesCmsnAgnt,
      'item_addition_method': itemAdditionMethod,
      'enable_inline_tax': enableInlineTax,
      'currency_symbol_placement': currencySymbolPlacement,
      'enabled_modules': enabledModules,
      'date_format': dateFormat,
      'time_format': timeFormat,
      'ref_no_prefixes': refNoPrefixes,
      'theme_color': themeColor,
      'created_by': createdBy,
      'repair_settings': repairSettings,
      'enable_rp': enableRp,
      'rp_name': rpName,
      'amount_for_unit_rp': amountForUnitRp,
      'min_order_total_for_rp': minOrderTotalForRp,
      'max_rp_per_order': maxRpPerOrder,
      'redeem_amount_per_unit_rp': redeemAmountPerUnitRp,
      'min_order_total_for_redeem': minOrderTotalForRedeem,
      'min_redeem_point': minRedeemPoint,
      'max_redeem_point': maxRedeemPoint,
      'rp_expiry_period': rpExpiryPeriod,
      'rp_expiry_type': rpExpiryType,
      'email_settings': emailSettings,
      'sms_settings': smsSettings,
      'custom_labels': customLabels,
      'common_settings': commonSettings,
      'is_active': isActive,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'allow_overselling': allowOverselling,
      'invoice_layout': invoiceLayout,
      'alt_contact_no': altContactNo,
      'business_contact_no': businessContactNo,
      'address': address,
      'zip_postal_code': zipPostalCode,
      'city': city,
      'state': state,
      'country': country,
      'expire_alert_day': expireAlertDay,
      'enable_payment_confirmation_in_sale': enablePaymentConfirmationInSale,
      'use_print_preview': usePrintPreview,
      'prefixs': prefixs.toJson(),
      'variable_cost': variableCost,
      'product_location_filter': productLocationFilter,
      'currency': currency.toJson(),
    };
  }
}

class StockTransferData {
  final String stockTransferShowPurchasePrice;

  StockTransferData({
    required this.stockTransferShowPurchasePrice,
  });

  factory StockTransferData.fromJson(Map<String, dynamic> json) {
    return StockTransferData(
      stockTransferShowPurchasePrice: json['stock_transfer_show_purchase_price'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stock_transfer_show_purchase_price': stockTransferShowPurchasePrice,
    };
  }
}

class Prefixs {
  final PrefixDetail purchasePrefix;
  final PrefixDetail salePrefix;
  final PrefixDetail stockTransferPrefix;
  final PrefixDetail stockAdjustmentPrefix;
  final PrefixDetail expensePrefix;
  final PrefixDetail purchasePaymentPrefix;
  final PrefixDetail expensePaymentPrefix;
  final PrefixDetail salePaymentPrefix;
  final PrefixDetail expenseReportPrefix;
  final PrefixDetail businessLocationPrefix;
  final PrefixDetail referralPrefix;
  final PrefixDetail referralPaymentPrefix;

  Prefixs({
    required this.purchasePrefix,
    required this.salePrefix,
    required this.stockTransferPrefix,
    required this.stockAdjustmentPrefix,
    required this.expensePrefix,
    required this.purchasePaymentPrefix,
    required this.expensePaymentPrefix,
    required this.salePaymentPrefix,
    required this.expenseReportPrefix,
    required this.businessLocationPrefix,
    required this.referralPrefix,
    required this.referralPaymentPrefix,
  });

  factory Prefixs.fromJson(Map<String, dynamic> json) {
    return Prefixs(
      purchasePrefix: PrefixDetail.fromJson(json['purchase_prefix'] as Map<String, dynamic>),
      salePrefix: PrefixDetail.fromJson(json['sale_prefix'] as Map<String, dynamic>),
      stockTransferPrefix: PrefixDetail.fromJson(json['stock_transfer_prefix'] as Map<String, dynamic>),
      stockAdjustmentPrefix: PrefixDetail.fromJson(json['stock_adjustment_prefix'] as Map<String, dynamic>),
      expensePrefix: PrefixDetail.fromJson(json['expense_prefix'] as Map<String, dynamic>),
      purchasePaymentPrefix: PrefixDetail.fromJson(json['purchase_payment_prefix'] as Map<String, dynamic>),
      expensePaymentPrefix: PrefixDetail.fromJson(json['expense_payment_prefix'] as Map<String, dynamic>),
      salePaymentPrefix: PrefixDetail.fromJson(json['sale_payment_prefix'] as Map<String, dynamic>),
      expenseReportPrefix: PrefixDetail.fromJson(json['expense_report_prefix'] as Map<String, dynamic>),
      businessLocationPrefix: PrefixDetail.fromJson(json['business_location_prefix'] as Map<String, dynamic>),
      referralPrefix: PrefixDetail.fromJson(json['referral_prefix'] as Map<String, dynamic>),
      referralPaymentPrefix: PrefixDetail.fromJson(json['referral_payment_prefix'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'purchase_prefix': purchasePrefix.toJson(),
      'sale_prefix': salePrefix.toJson(),
      'stock_transfer_prefix': stockTransferPrefix.toJson(),
      'stock_adjustment_prefix': stockAdjustmentPrefix.toJson(),
      'expense_prefix': expensePrefix.toJson(),
      'purchase_payment_prefix': purchasePaymentPrefix.toJson(),
      'expense_payment_prefix': expensePaymentPrefix.toJson(),
      'sale_payment_prefix': salePaymentPrefix.toJson(),
      'expense_report_prefix': expenseReportPrefix.toJson(),
      'business_location_prefix': businessLocationPrefix.toJson(),
      'referral_prefix': referralPrefix.toJson(),
      'referral_payment_prefix': referralPaymentPrefix.toJson(),
    };
  }
}

class PrefixDetail {
  final String name;
  final bool year;
  final bool month;
  final bool day;
  final String cycle;
  final String starterCount;
  final String digit;

  PrefixDetail({
    required this.name,
    required this.year,
    required this.month,
    required this.day,
    required this.cycle,
    required this.starterCount,
    required this.digit,
  });

  factory PrefixDetail.fromJson(Map<String, dynamic> json) {
    return PrefixDetail(
      name: json['name'] as String,
      year: json['year'] as bool,
      month: json['month'] as bool,
      day: json['day'] as bool,
      cycle: json['cycle'] as String,
      starterCount: json['starter_count'] as String,
      digit: json['digit'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'year': year,
      'month': month,
      'day': day,
      'cycle': cycle,
      'starter_count': starterCount,
      'digit': digit,
    };
  }
}

class Currency {
  final int id;
  final int businessId;
  final String currencyType;
  final String name;
  final String country;
  final String code;
  final String symbol;
  final String thoundsandSeprator;
  final String? decimalSeparator;

  Currency({
    required this.id,
    required this.businessId,
    required this.currencyType,
    required this.name,
    required this.country,
    required this.code,
    required this.symbol,
    required this.thoundsandSeprator,
    this.decimalSeparator,
  });

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      id: json['id'] as int,
      businessId: json['business_id'] as int,
      currencyType: json['currency_type'] as String,
      name: json['name'] as String,
      country: json['country'] as String,
      code: json['code'] as String,
      symbol: json['symbol'] as String,
      thoundsandSeprator: json['thoundsand_seprator'] as String,
      decimalSeparator: json['decimal_separator'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_id': businessId,
      'currency_type': currencyType,
      'name': name,
      'country': country,
      'code': code,
      'symbol': symbol,
      'thoundsand_seprator': thoundsandSeprator,
      'decimal_separator': decimalSeparator,
    };
  }
}