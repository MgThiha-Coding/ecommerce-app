import 'package:flutter/material.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';
import 'package:shimmer/shimmer.dart';

ListView categoryListLoading(BuildContext context, {int itemCount = 12}) {
  final responsive = Responsive(context);
  return ListView.separated(
    itemCount: itemCount,
    separatorBuilder: (_, __) => SizedBox(height: responsive.body),
    itemBuilder: (context, index) {
      return Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(responsive.body),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: responsive.body,
            vertical: responsive.body,
          ),
          child: Row(
            children: [
              Container(
                width: responsive.body,
                height: responsive.body,
                color: Colors.grey.shade300,
              ),
              SizedBox(width: responsive.body),
              Expanded(
                child: Container(
                  width: double.infinity,
                  height: responsive.body,
                  color: Colors.grey.shade300,
                ),
              ),
              SizedBox(width: responsive.body),
              Container(
                width: responsive.body,
                height: responsive.body,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(responsive.body),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
