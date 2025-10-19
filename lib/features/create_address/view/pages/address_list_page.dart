import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';
import 'package:picoshop_theme2/features/create_address/viewmodel/add_notifier.dart';

class AddressListPage extends ConsumerStatefulWidget {
  const AddressListPage({super.key});

  @override
  ConsumerState<AddressListPage> createState() => _AddressListPageState();
}

class _AddressListPageState extends ConsumerState<AddressListPage> {
  int? selectedAddressId;

  @override
  void initState() {
    super.initState();
    ref.read(addressNotifierProvider.notifier).getAddresses();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    final addresses = ref.watch(addressNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Select Address')),
      body: addresses.when(
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('No addresses found'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final address = list[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  title: Text(
                    '${address.name}: ${address.firstName} ${address.lastName}',
                    style: TextStyle(fontSize: responsive.subHeading),
                  ),
                  subtitle: Text(
                    '${address.addressLine1}, ${address.addressLine2}, ${address.regionId}, ${address.townshipId}',
                    style: TextStyle(fontSize: responsive.body),
                  ),

                  trailing: Radio<int>(
                    value: address.id,
                    groupValue: selectedAddressId,
                    onChanged: (val) {
                      setState(() {
                        selectedAddressId = val;
                      });
                    },
                  ),
                  onTap: () {
                    setState(() {
                      selectedAddressId = address.id;
                    });
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text(err.toString())),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: ElevatedButton(
          onPressed: selectedAddressId == null
              ? null
              : () {
                  final selectedAddress = addresses.asData!.value.firstWhere(
                    (e) => e.id == selectedAddressId,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Address selected')),
                  );
                
                },
          child: const Text('Select Address'),
        ),
      ),
    );
  }
}
