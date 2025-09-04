import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picoshop_theme2/features/cart/viewmodel/cart_notifier.dart';

class DeleteCartItemDialog extends ConsumerWidget {
  final int itemId;

  const DeleteCartItemDialog({
    super.key,
    required this.itemId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final removeState = ref.watch(removeCartItemNotifierProvider);
    final isLoading = removeState.isLoading;

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      title: Text(
        'Delete Item',
        style: GoogleFonts.poppins(
          color: Colors.red.shade700,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      content: Text(
        'Are you sure you want to delete this item from your cart?',
        style: GoogleFonts.poppins(
          color: Colors.black87,
          fontSize: 14,
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Colors.grey.shade200,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: GoogleFonts.poppins(
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Colors.red.shade600,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: isLoading
              ? null
              : () async {
                  final notifier =
                      ref.read(removeCartItemNotifierProvider.notifier);
                  await notifier.removeCartItem(itemId);

                  await ref
                      .read(getCartItemNotifierProvider.notifier)
                      .getCartItem();

                  await ref
                      .read(getTotalCartItemNotifierProvider.notifier)
                      .getTotalCartItem();

                  if (!ref.watch(removeCartItemNotifierProvider).isLoading) {
                    Navigator.pop(context);
                  }
                },
          child: isLoading
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: SpinKitCircle(
                    size: 15,
                    color: Colors.white,
                  ),
                )
              : Text(
                  'Yes',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ],
    );
  }
}
