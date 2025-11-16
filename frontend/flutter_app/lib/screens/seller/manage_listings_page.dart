import 'package:flutter/material.dart';
import 'package:flutter_app/screens/seller/crud_listing/create_new_listing.dart';
import 'package:flutter_app/utils/app_colors.dart';
import 'package:flutter_app/utils/app_constants.dart';
import 'package:flutter_app/widgets/custom_app_bar.dart';
import 'package:flutter_app/widgets/custom_button.dart';
import 'package:flutter_app/widgets/table/custom_table.dart';
import 'package:flutter_app/widgets/table/table_item_data.dart';
import 'package:flutter_app/utils/navigation_utils.dart';

enum ButtonSelection { activeItems, archivedItems, banItems, reviewingItems }

class ManageListingsPage extends StatefulWidget {
  const ManageListingsPage({super.key});
  @override
  State<ManageListingsPage> createState() => _ManageListingsPageState();
}

bool _isWebLayout(BuildContext context) {
  return MediaQuery.of(context).size.width >= AppConstants.kTabletBreakpoint;
}

class _ManageListingsPageState extends State<ManageListingsPage> {
  @override
  void initState() {
    super.initState();
    _selectedButton = ButtonSelection.activeItems;
    _selectButton(ButtonSelection.activeItems);
  }

  String tableTitle = "Active Listing Items";
  Color titleBackgroundColor = AppColors.success;
  List<TableItemData> tableItems = [];
  List<TableItemData> activeItems = [];
  List<TableItemData> archivedItems = [];
  List<TableItemData> banItems = [];
  List<TableItemData> reviewingItems = [];
  ButtonSelection? _selectedButton;
  final Color _selectionHighlightColor = AppColors.surfaceColor;
  Color _getBorderButtonColor(ButtonSelection currentButton, Color baseColor) {
    if (_selectedButton == currentButton) {
      return _selectionHighlightColor;
    }
    return baseColor;
  }

  void _selectButton(ButtonSelection button) {
    setState(() {
      _selectedButton = (_selectedButton == button) ? null : button;
    });
    switch (_selectedButton) {
      case ButtonSelection.activeItems:
        tableTitle = "Active Listing Items";
        titleBackgroundColor = AppColors.success;
        tableItems = activeItems;

        break;
      case ButtonSelection.archivedItems:
        tableTitle = "Archived List Items";
        titleBackgroundColor = AppColors.primaryColor;
        tableItems = archivedItems;
        break;
      case ButtonSelection.reviewingItems:
        tableTitle = "Reviewing Items";
        titleBackgroundColor = AppColors.secondaryDark;
        tableItems = reviewingItems;
        break;
      case ButtonSelection.banItems:
        tableTitle = "Banned List Items";
        titleBackgroundColor = AppColors.danger;
        tableItems = banItems;
        break;
      default:
        tableTitle = "Active Listing Items";
        titleBackgroundColor = AppColors.success;
        tableItems = activeItems;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isWeb = _isWebLayout(context);
    // tableitems

    return Scaffold(
      appBar: CustomAppBar(
        titleText: "Manage Listings",
        automaticallyImplyLeading: true,
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(AppConstants.kDefaultPadding),
          constraints: const BoxConstraints(
            maxWidth: AppConstants.kMaxContentWidth,
          ),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,

                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: AppConstants.kMaxContentWidth,
                  ),
                  child: CustomButton(
                    text: "Create New Listing",
                    icon1: Icon(Icons.add),
                    onPressed: () {
                      NavigationUtils.push(context, CreateNewListing());
                    },
                  ),
                ),
              ),
              AppSpaces.largeDivider,

              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(
                          width: 2.0,
                          color: _getBorderButtonColor(
                            ButtonSelection.activeItems,
                            AppColors.transparent,
                          ),
                        ),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.checklist, size: 35),
                        color: AppColors.surfaceColor,
                        onPressed: () {
                          _selectButton(ButtonSelection.activeItems);
                        },
                      ),
                    ),
                  ),
                  AppSpaces.smallHorizontal,
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(
                          width: 2.0,
                          color: _getBorderButtonColor(
                            ButtonSelection.archivedItems,
                            AppColors.transparent,
                          ),
                        ),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.archive, size: 35),
                        color: AppColors.surfaceColor,
                        onPressed: () {
                          _selectButton(ButtonSelection.archivedItems);
                        },
                      ),
                    ),
                  ),
                  AppSpaces.smallHorizontal,

                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.secondaryDark,
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(
                          width: 2.0,
                          color: _getBorderButtonColor(
                            ButtonSelection.reviewingItems,
                            AppColors.transparent,
                          ),
                        ),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.reviews, size: 35),
                        color: AppColors.surfaceColor,
                        onPressed: () {
                          _selectButton(ButtonSelection.reviewingItems);
                        },
                      ),
                    ),
                  ),
                  AppSpaces.smallHorizontal,

                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.danger,
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(
                          width: 2.0,
                          color: _getBorderButtonColor(
                            ButtonSelection.banItems,
                            AppColors.transparent,
                          ),
                        ),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.dangerous, size: 35),
                        color: AppColors.surfaceColor,
                        onPressed: () {
                          _selectButton(ButtonSelection.banItems);
                        },
                      ),
                    ),
                  ),
                ],
              ),
              AppSpaces.smallVertical,
              CustomTable(
                title: tableTitle,
                items: tableItems,
                titleBackgroundColor: titleBackgroundColor,
                titleTextColor: AppColors.surfaceColor,
                fixedRows: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
