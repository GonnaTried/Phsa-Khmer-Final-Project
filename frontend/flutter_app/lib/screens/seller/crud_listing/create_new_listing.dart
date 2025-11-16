import 'package:flutter/material.dart';
import 'package:flutter_app/utils/app_colors.dart';
import 'package:flutter_app/utils/app_constants.dart';
import 'package:flutter_app/utils/navigation_utils.dart';
import 'package:flutter_app/widgets/custom_app_bar.dart';
import 'package:flutter_app/widgets/custom_button.dart';
import 'package:flutter_app/widgets/custom_input_box.dart';
import 'package:flutter_app/widgets/table/custom_table.dart';
import 'package:flutter_app/widgets/table/table_item_data.dart';

class CreateNewListing extends StatefulWidget {
  const CreateNewListing({super.key});

  @override
  State<CreateNewListing> createState() => _CreateNewListingState();
}

class _CreateNewListingState extends State<CreateNewListing> {
  final TextEditingController _titleController = TextEditingController();

  String? _titleValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Title is required';
    }
    if (value.length > 128) {
      return "Title Must shorter or equal to 128 characters";
    }
    if (value.length < 10) {
      return "Title Must longer or equal to 10 characters";
    }
    final RegExp validCharacters = RegExp(r"^[a-zA-Z0-9\-\+_\$:,]+$");
    if (!validCharacters.hasMatch(value)) {
      return "Title contains invalid characters. Only A-Z, a-z, 0-9, and symbols (- + _ \$ : ,) are allowed.";
    }

    return null;
  }

  void _cancelButtton(BuildContext context) async {
    final confirmed = await NavigationUtils.showConfirmationDialog(
      context,
      title: 'Confirm Cancel',
      content:
          'This Listing will be deleted. Are you sure you want to cancel? \n If you want to exit but save this listing use Draft',
      confirmText: 'Delete',
      cancelText: 'Keep',
      confirmButtonColor: AppColors.danger,
      cancelButtonColor: AppColors.textSecondary,
    );
    if (!mounted) return;
    if (confirmed == true) {
      if (context.mounted) {
        NavigationUtils.pop(context);
      }
    } else {}
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<TableItemData> tableItems = [];

    return Scaffold(
      appBar: CustomAppBar(
        titleText: "Create New Listing",
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(AppConstants.kDefaultPadding),
            constraints: const BoxConstraints(
              maxWidth: AppConstants.kMaxContentWidth,
            ),
            child: Column(
              children: [
                InkWell(
                  onTap: () {},

                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        constraints: BoxConstraints(minHeight: 200),
                        decoration: BoxDecoration(
                          color: AppColors.dividerColor,
                          borderRadius: BorderRadius.circular(10.0),
                        ),

                        child: SizedBox(
                          child: Center(
                            child: Column(
                              children: [
                                Text(
                                  "Add Thumbnail Image",
                                  style: TextStyle(
                                    color: AppColors.primaryColor,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Icon(Icons.add_a_photo, size: 50),
                                AppSpaces.smallVertical,
                                Text("Recommended Ratio: (1:1, 4:5)"),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpaces.smallVertical,
                CustomInputBox(
                  title: "Listing Title",
                  description:
                      "Title Must only Contain A-Z, a-z, 0-9 and some symbols (- + _ \$ : ,) | Have 10 - 128 Characters",
                  validator: _titleValidator,
                ),
                AppSpaces.largeDivider,
                Align(
                  alignment: AlignmentGeometry.centerRight,
                  child: CustomButton(text: "Add Item", onPressed: () {}),
                ),
                AppSpaces.smallVertical,
                CustomTable(
                  title: "Listing Items",
                  items: tableItems,
                  titleBackgroundColor: AppColors.dividerColor,
                ),
                AppSpaces.largeDivider,
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: "Cancel",
                        onPressed: () => _cancelButtton(context),
                        icon1: Icon(Icons.close),
                        buttonColor: AppColors.danger,
                      ),
                    ),
                    AppSpaces.smallHorizontal,
                    Expanded(
                      child: CustomButton(
                        text: "Draft",
                        onPressed: () {},
                        icon1: Icon(Icons.archive),
                        buttonColor: AppColors.secondaryDark,
                      ),
                    ),
                    AppSpaces.smallHorizontal,
                    Expanded(
                      child: CustomButton(
                        text: "Post",
                        onPressed: () {},
                        icon1: Icon(Icons.publish),
                        buttonColor: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
