import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picoshop_theme2/features/cart/view/widgets/cart_list_widget.dart';
import 'package:picoshop_theme2/features/cart/viewmodel/cart_notifier.dart';
import 'package:picoshop_theme2/features/shipping/view/shipping_method_page.dart';

class CartPage extends ConsumerStatefulWidget {
  const CartPage({super.key});

  @override
  ConsumerState<CartPage> createState() => _CartPageState();
}

class _CartPageState extends ConsumerState<CartPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(getTotalCartItemNotifierProvider.notifier).getTotalCartItem();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.blue.shade900,
                Colors.blue.shade500,
                Colors.blue.shade100,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [const AppBarWidget(), const CartListWidget()],
            ),
          ),
        ),
      ),
    );
  }
}
