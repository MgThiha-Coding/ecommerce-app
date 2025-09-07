import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateOrderPage extends ConsumerStatefulWidget {
  final String payment;
  final String shipping;
  final int addressId;
  const CreateOrderPage(this.payment, this.shipping, this.addressId, {super.key});

  @override
  ConsumerState<CreateOrderPage> createState() => _CreateOrderPageState();
}

class _CreateOrderPageState extends ConsumerState<CreateOrderPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}