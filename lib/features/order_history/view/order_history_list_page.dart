
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picoshop_theme2/features/order_history/model/order_history_response.dart';
import 'package:picoshop_theme2/features/order_history/viewmodel/order_histories_notifier.dart';
import 'package:shimmer/shimmer.dart';
import 'package:picoshop_theme2/core/consts/app_colors.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';

class OrderHistoryListPage extends ConsumerStatefulWidget {
  const OrderHistoryListPage({super.key});

  @override
  ConsumerState<OrderHistoryListPage> createState() =>
      _OrderHistoryListPageState();
}

class _OrderHistoryListPageState extends ConsumerState<OrderHistoryListPage> {
  @override
  void initState() {
    super.initState();
    // fetch histories
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(orderHistoriesNotifierProvider.notifier).getOrderHistories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    final historiesAsync = ref.watch(orderHistoriesNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Orders',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: responsive.subHeading,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: historiesAsync.when(
        data: (response) {
          if (response == null || !response.success || response.data.isEmpty) {
            return const Center(
              child: Text(
                'No orders found.',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            );
          }

          final orders = response.data;
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final order = orders[index];
              return _OrderCard(
                order: order,
                responsive: responsive,
              );
            },
          );
        },
        loading: _buildShimmerList,
        error: (err, _) => Center(
          child: Text(
            err.toString(),
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 14, width: 180, color: Colors.white),
                const SizedBox(height: 8),
                Container(height: 12, width: 120, color: Colors.white),
                const SizedBox(height: 10),
                Container(height: 12, width: double.infinity, color: Colors.white),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _OrderCard extends StatefulWidget {
  final OrderHistory order;
  final Responsive responsive;

  const _OrderCard({required this.order, required this.responsive});

  @override
  State<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<_OrderCard> {
  bool expanded = false;

  String _formatDate(DateTime date) {
    try {
      return DateFormat('dd MMM yyyy, hh:mm a').format(date.toLocal());
    } catch (_) {
      return date.toIso8601String();
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange.shade700;
      case 'confirmed':
        return Colors.blue.shade700;
      case 'shipped':
      case 'delivered':
        return Colors.green.shade700;
      case 'cancelled':
      case 'rejected':
        return Colors.red.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    final o = widget.order;
    final responsive = widget.responsive;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        children: [
          // Header row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // left: order info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      o.orderNumber,
                      style: GoogleFonts.poppins(
                        fontSize: responsive.body,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatDate(o.createdAt),
                      style: GoogleFonts.poppins(
                        fontSize: responsive.caption,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (o.shippingAddress != null)
                      Text(
                        '${o.shippingAddress!.township ?? ''}, ${o.shippingAddress!.region ?? ''}',
                        style: GoogleFonts.poppins(
                          fontSize: responsive.caption,
                          color: Colors.black45,
                        ),
                      ),
                  ],
                ),
              ),

              // right: status and total
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      // ignore: deprecated_member_use
                      color: _statusColor(o.status).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      o.status.toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _statusColor(o.status),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${o.amountTotal} MMK',
                    style: GoogleFonts.poppins(
                      fontSize: responsive.body - 1,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Expand / collapse control
          GestureDetector(
            onTap: () => setState(() => expanded = !expanded),
            child: Row(
              children: [
                Icon(
                  expanded ? Icons.expand_less : Icons.expand_more,
                  size: 20,
                  color: Colors.grey.shade700,
                ),
                const SizedBox(width: 8),
                Text(
                  expanded ? 'Hide details' : 'View details',
                  style: GoogleFonts.poppins(
                    fontSize: responsive.caption,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),

          // Animated details
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Column(
                children: [
                  // Items list
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: o.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, idx) {
                      final it = o.items[idx];
                      return Row(
                        children: [
                          // placeholder product thumbnail
                          Container(
                            height: 56,
                            width: 56,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                it.productId.toString(),
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Product ID: ${it.productId}',
                                  style: GoogleFonts.poppins(
                                    fontSize: responsive.body - 1,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Qty: ${it.quantity} • Price: ${it.uomPrice} MMK',
                                  style: GoogleFonts.poppins(
                                    fontSize: responsive.caption,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${it.subtotal} MMK',
                            style: GoogleFonts.poppins(
                              fontSize: responsive.body - 1,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  // Shipping address block
                  if (o.shippingAddress != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade100),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Shipping Address',
                            style: GoogleFonts.poppins(
                              fontSize: responsive.caption,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            o.shippingAddress!.address ?? '-',
                            style: GoogleFonts.poppins(
                              fontSize: responsive.body - 2,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${o.shippingAddress!.township ?? ''}, ${o.shippingAddress!.region ?? ''} • ${o.shippingAddress!.country ?? ''}',
                            style: GoogleFonts.poppins(
                              fontSize: responsive.caption,
                              color: Colors.black45,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Phone: ${o.shippingAddress!.phone ?? '-'}',
                            style: GoogleFonts.poppins(
                              fontSize: responsive.caption,
                              color: Colors.black45,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 12),

                  // Summary row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Subtotal',
                        style: GoogleFonts.poppins(
                          fontSize: responsive.caption,
                          color: Colors.black54,
                        ),
                      ),
                      Text(
                        '${o.amountTotal} MMK',
                        style: GoogleFonts.poppins(
                          fontSize: responsive.body - 1,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            crossFadeState:
                expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
          ),
        ],
      ),
    );
  }
}
