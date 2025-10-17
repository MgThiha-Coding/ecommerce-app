import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picoshop_theme2/core/config/app_config.dart';

final orderNotifierProvider =
    StateNotifierProvider<OrderNotifier, AsyncValue<Map<String, dynamic>?>>(
        (ref) => OrderNotifier());

class CreateOrderPage extends ConsumerWidget {
  const CreateOrderPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(orderNotifierProvider);

    void createOrder() async {
      final notifier = ref.read(orderNotifierProvider.notifier);
      await notifier.createOrder();
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Create Order (Pickup)")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: createOrder,
              child: const Text("Create Pickup Order"),
            ),
            const SizedBox(height: 20),
            state.when(
              data: (data) => data != null
                  ? Text("✅ Response: ${jsonEncode(data)}")
                  : Container(),
              loading: () => const CircularProgressIndicator(),
              error: (err, _) {
                debugPrint("❌ Order Error: $err");
                return Text("❌ Error: $err");
              },
            ),
          ],
        ),
      ),
    );
  }
}

class OrderNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  final Dio _dio;

  OrderNotifier([Dio? dio])
      : _dio = dio ?? Dio(),
        super(const AsyncValue.data(null));

  Future<void> createOrder() async {
    try {
      state = const AsyncValue.loading();

      final formData = FormData();

      // Pickup order with placeholders for shipping fields
      formData.fields.addAll([
        const MapEntry("order_type", "pickup"),
        const MapEntry("shipping_method_id", ""), // null
        const MapEntry("payment_account_id", ""), // null
        const MapEntry("shipping[address]", "-"),
        const MapEntry("shipping[township]", "-"),
        const MapEntry("shipping[region]", "-"),
        const MapEntry("shipping[country]", "-"),
        const MapEntry("shipping[phone]", "-"),
      ]);

      // Add cart items
      final cartItemIds = [63,66];
      for (var id in cartItemIds) {
        formData.fields.add(MapEntry("cart_item_ids[]", id.toString()));
      }

      final response = await _dio.post(
        "${AppConfig.baseUrl}/v1/ecommerce/order",
        data: formData,
        options: Options(
          headers: {
            "Accept": "application/json",
            "X-API-Token": AppConfig.xApiToken,
            "Authorization":
                "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIxIiwianRpIjoiNmNkNzM5MDU5ZGMyODRkNmNiNTU3ODgyMjdjMmYyNDI0ZDIyM2RlNzI4ZmIxYjU0YmFiNTQxNTYwMjdjM2UxNWM4YWEwN2I2NWZlNmE1ZmQiLCJpYXQiOjE3NTc2OTE4MTMuNDg2NTE5LCJuYmYiOjE3NTc2OTE4MTMuNDg2NTI0LCJleHAiOjE3NzMzMzAyMTMuNDc3NDY3LCJzdWIiOiIyMyIsInNjb3BlcyI6W119.lCCsC6qtvx591xu-RzBYCvlWIBbOM0-5bx-arVQVWD0UjiQxEDgEmH6HemaeV7ZY74B3Y2IedGD6BaNilKp1HUKTwn8QIRq72lPOJFlzmHphExSW-FoUvmARY8VJF2V9tiBfUr_bD7JpU2LlMfhTNXVr4BmBHvW73ZUd1o3KgeYi6MR5QoTA9-FplxjiX6SOokLSqhQF8snnxilIqibE-Tqdfwq4VmgDCy2-7qtBSIJifqDE7QnE_AVHdWP2EggfnnVjUcmHSlHRAk_u60zcF1u5OSLyXyBLHHnDZzqiQ-fjao7bz0BNA4Aj7W0DnoA1NmxE04Un6e8jgEDr6LF26HnLb_jRAGoES7dTQYeXvEpjJ-Yuk9sDf0i487FwL_SOS6o0CkXszBqwQMHoRXEFa8UAlsjWRh_ynAXTdWMnliuorXMS6ORShwYd4AbByvVWTX9frJQa58xEKu5vsMZcfxMSWFMYhZVyHXRfAcNUszqrvHjg1-9Hp1vh0k3ZpUbnKW6ZvjaaTFwXct-fKY2s3KxfqnhQNS2j4xCVf1HBFCU_NUSeUEa4RwsfDR6AU7YoGvriqVdhgQMxE36VaJwzZ3SqpfD0Vub-Qlkc1LFkoNInjw4n3PMs7Tj67WxZRphDVzB8qfTSAg4Cca4mk92jxN8uvJLahjeyyf-0xs4HUAc",
          },
          contentType: 'multipart/form-data',
        ),
      );
    
      state = AsyncValue.data(response.data);
    } on DioException catch (e, st) {
      final errorData = e.response?.data ?? e.message;
      debugPrint("❌ Dio Error: $errorData");
      state = AsyncValue.error(errorData.toString(), st);
    } catch (e, st) {
      debugPrint("❌ Unexpected Error: $e");
      state = AsyncValue.error(e.toString(), st);
    }
  }
}
