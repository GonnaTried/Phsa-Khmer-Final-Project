import 'package:flutter/material.dart';
import 'package:flutter_app/utils/app_colors.dart';
import 'package:flutter_app/widgets/table/table_item_data.dart';

class CustomTable extends StatelessWidget {
  final String title;
  final List<TableItemData> items;

  final int fixedRows;
  final double maxHeight;

  final Color titleBackgroundColor;
  final Color tableBackgroundColor;
  final Color titleTextColor;

  const CustomTable({
    super.key,
    required this.title,
    required this.items,
    this.fixedRows = 10,
    this.titleBackgroundColor = AppColors.backgroundColor,
    this.tableBackgroundColor = AppColors.surfaceColor,
    this.titleTextColor = AppColors.textPrimary,
  }) : maxHeight = fixedRows * 70.0 + 40;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: tableBackgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: titleBackgroundColor,
              border: const Border(
                bottom: BorderSide(color: AppColors.dividerColor),
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: titleTextColor,
              ),
            ),
          ),

          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: ListView.builder(
              shrinkWrap: true,
              physics: (items.length <= fixedRows)
                  ? const NeverScrollableScrollPhysics()
                  : const AlwaysScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return EcomTableItem(data: items[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
