import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';

class CartListLoading extends StatelessWidget {
  const CartListLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    return Card(
      child: Column(
        children: [
          // Cart items shimmer
          Expanded(
            child: ListView.builder(
              itemCount: 5, // show 5 shimmer placeholders
              itemBuilder: (context, index) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: Card(
                    child: ListTile(
                      leading: Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(
                          height: responsive.value(
                            mobile: 20,
                            tablet: 24,
                            desktop: 28,
                          ),
                          width: responsive.value(
                            mobile: 20,
                            tablet: 24,
                            desktop: 28,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      title: Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(
                          height: responsive.value(
                            mobile: 12,
                            tablet: 14,
                            desktop: 16,
                          ),
                          width: responsive.value(
                            mobile: 80,
                            tablet: 100,
                            desktop: 120,
                          ),
                          color: Colors.grey.shade400,
                        ),
                      ),
                      subtitle: Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(
                          margin: const EdgeInsets.only(top: 4),
                          height: responsive.value(
                            mobile: 10,
                            tablet: 12,
                            desktop: 14,
                          ),
                          width: responsive.value(
                            mobile: 60,
                            tablet: 80,
                            desktop: 100,
                          ),
                          color: Colors.grey.shade400,
                        ),
                      ),
                      trailing: Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(
                          height: responsive.value(
                            mobile: 20,
                            tablet: 24,
                            desktop: 28,
                          ),
                          width: responsive.value(
                            mobile: 20,
                            tablet: 24,
                            desktop: 28,
                          ),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Cart summary shimmer
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(
                height: responsive.value(
                  mobile: 60,
                  tablet: 70,
                  desktop: 80,
                ),
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade400,
                ),
              ),
            ),
          ),

          // Button shimmer
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(
                height: responsive.value(
                  mobile: 50,
                  tablet: 55,
                  desktop: 60,
                ),
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
