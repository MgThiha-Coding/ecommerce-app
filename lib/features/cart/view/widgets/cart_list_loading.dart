import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

Widget cartListLoading() {
  return ListView.builder(
    padding: const EdgeInsets.all(6),
    itemCount: 6,
    itemBuilder: (context, index) => Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          leading: Container(
            width: 50,
            height: 50,
            color: Colors.grey.shade300,
          ),
          title: Container(
            height: 12,
            color: Colors.grey.shade300,
            margin: const EdgeInsets.symmetric(vertical: 6),
          ),
          subtitle: Container(
            height: 10,
            color: Colors.grey.shade300,
            margin: const EdgeInsets.only(top: 4),
          ),
        ),
      ),
    ),
  );
}
