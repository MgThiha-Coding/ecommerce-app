import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picoshop_theme2/features/product/model/response/product_list_response.dart';


final pageProvider = StateProvider<int>((ref) {
  return 0;
});

final isNoMoreProvider = StateProvider.autoDispose<bool>((ref) {
  return false;
});


final productListProvider =
    StateProvider.autoDispose<List<ChildData?>>((ref) {
  return [];
});



/*
final productListProvider =
    StateProvider.autoDispose<List<ProductListResponse?>>((ref) {
  return [];
});


final transactionListProvider =
    StateProvider.autoDispose<List<TransactionModel>>((ref) {
  return [];
});

*/
