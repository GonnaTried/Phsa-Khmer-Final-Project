import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/seller/item_model.dart';
import 'package:flutter_app/providers/listing_provider.dart';
import 'package:flutter_app/services/listing_service.dart';
import 'package:flutter_app/utils/app_colors.dart';
import 'package:flutter_app/utils/app_constants.dart';
import 'package:flutter_app/utils/navigation_utils.dart';
import 'package:flutter_app/widgets/custom_app_bar.dart';
import 'package:flutter_app/widgets/custom_button.dart';
import 'package:flutter_app/widgets/custom_input_box.dart';
import 'package:flutter_app/widgets/table/custom_table.dart';
import 'package:flutter_app/widgets/table/table_item_data.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class CreateNewListing extends StatefulWidget {
  const CreateNewListing({super.key});

  @override
  State<CreateNewListing> createState() => _CreateNewListingState();
}

class _CreateNewListingState extends State<CreateNewListing> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for the main listing
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  // Thumbnail image for the entire listing
  XFile? _listingThumbnailImage;
  final ImagePicker _picker = ImagePicker();

  // --- Validators ---

  String? _titleValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Title is required';
    }
    if (value.length > 128) {
      return "Title Must be shorter or equal to 128 characters";
    }
    if (value.length < 10) {
      return "Title Must be longer or equal to 10 characters";
    }
    final RegExp validCharacters = RegExp(r"^[a-zA-Z0-9\-\+_\$:, ]+$");
    if (!validCharacters.hasMatch(value)) {
      return "Title contains invalid characters. Only A-Z, a-z, 0-9, and symbols (- + _ \$ : ,) are allowed.";
    }
    return null;
  }

  // Validator for optional fields (allowing null/empty)
  String? _optionalInputValidator(String? value) {
    // Allows empty string, focuses on max length if content exists
    if (value != null && value.length > 255) {
      return "Input exceeds maximum allowed length.";
    }
    return null;
  }

  // --- Thumbnail Picker ---
  Future<void> _pickListingThumbnail() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _listingThumbnailImage = image;
      });
    }
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
        context.read<ListingProvider>().clearDraft();
        NavigationUtils.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  // FIXED: Accepts XFile for platform-agnostic display
  Widget _buildItemImage(XFile imageXFile) {
    if (kIsWeb) {
      // Use XFile.readAsBytes() for web
      return FutureBuilder<Uint8List>(
        future: imageXFile.readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.data != null) {
            return Image.memory(
              snapshot.data!,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
            );
          }
          // Placeholder while loading
          return const SizedBox(
            width: 40,
            height: 40,
            child: Center(
              child: Icon(
                Icons.refresh,
                size: 20,
                color: AppColors.primaryColor,
              ),
            ),
          );
        },
      );
    } else {
      // Use File(path) for non-web
      return Image.file(
        File(imageXFile.path),
        width: 40,
        height: 40,
        fit: BoxFit.cover,
      );
    }
  }

  // Helper for displaying the main listing thumbnail
  Widget _buildThumbnailDisplay() {
    if (_listingThumbnailImage == null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
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
      );
    }

    if (kIsWeb) {
      return FutureBuilder<Uint8List>(
        future: _listingThumbnailImage!.readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.data != null) {
            return Image.memory(
              snapshot.data!,
              fit: BoxFit.cover,
              width: double.infinity,
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      );
    } else {
      return Image.file(
        File(_listingThumbnailImage!.path),
        fit: BoxFit.cover,
        width: double.infinity,
      );
    }
  }

  void _postListing() async {
    // 1. CRITICAL: Check main form validation
    if (!_formKey.currentState!.validate()) {
      NavigationUtils.showErrorMessage(
        context,
        "Please fix errors in the Listing Title field.",
      );
      return;
    }

    // 2. Check thumbnail image
    if (_listingThumbnailImage == null) {
      NavigationUtils.showErrorMessage(
        context,
        "Listing thumbnail image is required.",
      );
      return;
    }

    final listingProvider = context.read<ListingProvider>();
    final items = listingProvider.localItems;

    // 3. Check items count constraint
    if (items.isEmpty) {
      NavigationUtils.showErrorMessage(
        context,
        "You must add at least one item to the listing.",
      );
      return;
    }

    // 4. Get the services
    final listingService = context.read<ListingService>();

    // TODO: Show loading dialog here
    const int statusId = 1;
    final success = await listingService.postFullListing(
      items: items,
      listingTitle: _titleController.text.trim(),
      listingThumbnailFile: _listingThumbnailImage, // Pass the XFile
      // category: _categoryController.text.trim(),
      // tags: _tagsController.text.trim(),
      statusId: statusId,
    );

    // 5. Handle result and clean up
    if (!mounted) return;
    // TODO: Hide loading dialog here

    if (success) {
      listingProvider.clearDraft();
      NavigationUtils.showSuccessMessage(
        context,
        "Listing posted successfully!",
      );
      NavigationUtils.pop(context);
    } else {
      NavigationUtils.showErrorMessage(
        context,
        "Failed to post listing. Please try again.",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final listingProvider = context.watch<ListingProvider>();
    final items = listingProvider.localItems;

    // Table Item Mapping
    List<TableItemData> tableItems = items.map((item) {
      final String itemName = item.name;
      final double itemPrice = item.price;

      // FIXED: Use item.imageXFile
      Widget leadingWidget = item.imageXFile != null
          ? _buildItemImage(item.imageXFile!)
          : const Icon(Icons.broken_image, color: AppColors.danger);

      return TableItemData(
        leadingWidget: leadingWidget,
        primaryText: itemName,
        rightText: '\$${itemPrice.toStringAsFixed(2)}',
      );
    }).toList();

    return Scaffold(
      appBar: const CustomAppBar(
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
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // --- Listing Thumbnail Area ---
                  InkWell(
                    onTap: _pickListingThumbnail,
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(minHeight: 200),
                      decoration: BoxDecoration(
                        color: AppColors.dividerColor,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Center(child: _buildThumbnailDisplay()),
                    ),
                  ),
                  AppSpaces.smallVertical,

                  // --- Listing Inputs ---
                  CustomInputBox(
                    controller: _titleController,
                    title: "Listing Title",
                    description:
                        "Title Must only Contain A-Z, a-z, 0-9 and some symbols (- + _ \$ : ,) | Have 10 - 128 Characters",
                    validator: _titleValidator,
                  ),
                  AppSpaces.smallVertical,
                  CustomInputBox(
                    controller: _categoryController,
                    title: "Category",
                    description:
                        "Can have up to 5 categories separated by commas Example: Toy, Kid, Clothes",
                    validator: _optionalInputValidator,
                  ),
                  AppSpaces.smallVertical,
                  CustomInputBox(
                    controller: _tagsController,
                    title: "Tags",
                    description:
                        "Create your own Tags Can have up to 10 Tags separated by commas Example: #Toy, #Kid, #Clothes",
                    validator: _optionalInputValidator,
                  ),
                  AppSpaces.largeDivider,

                  // --- Item List ---
                  Align(
                    alignment: Alignment.centerRight,
                    child: CustomButton(
                      text: "Add Item",
                      onPressed: _showAddItemPopup,
                    ),
                  ),
                  AppSpaces.smallVertical,
                  CustomTable(
                    title: "Listing Items (${items.length})",
                    items: tableItems,
                    titleBackgroundColor: AppColors.dividerColor,
                  ),
                  AppSpaces.largeDivider,

                  // --- Action Buttons ---
                  Row(
                    children: [
                      // Expanded(
                      //   child: CustomButton(
                      //     text: "Cancel",
                      //     onPressed: () => _cancelButtton(context),
                      //     icon1: const Icon(Icons.close),
                      //     buttonColor: AppColors.danger,
                      //   ),
                      // ),
                      // AppSpaces.smallHorizontal,
                      // Expanded(
                      //   child: CustomButton(
                      //     text: "Draft",
                      //     onPressed: () {
                      //       /* TODO: Implement save to draft API */
                      //     },
                      //     icon1: const Icon(Icons.archive),
                      //     buttonColor: AppColors.secondaryDark,
                      //   ),
                      // ),
                      // AppSpaces.smallHorizontal,
                      Expanded(
                        child: CustomButton(
                          text: "Post",
                          onPressed: _postListing,
                          icon1: const Icon(Icons.publish),
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
      ),
    );
  }

  void _showAddItemPopup() async {
    final result = await NavigationUtils.showCustomPopup<bool>(
      context: context,
      contentWidget: const _AddItem(),
    );

    if (!mounted) {
      return;
    }

    if (result == true) {
      NavigationUtils.showSuccessMessage(
        context,
        "Item successfully added to draft!",
      );
    }
  }
}

class _AddItem extends StatefulWidget {
  const _AddItem({super.key});

  @override
  State<_AddItem> createState() => _AddItemState();
}

class _AddItemState extends State<_AddItem> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _itemPriceController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImage;

  // --- Validators ---

  String? _itemNameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Title is required';
    }
    if (value.length > 64) {
      return "Title Must be shorter or equal to 64 characters";
    }
    if (value.length < 1) {
      return "Title Must be longer or equal to 1 characters"; // Corrected length constraint
    }
    final RegExp validCharacters = RegExp(r"^[a-zA-Z0-9\-\+_\$:, ]+$");
    if (!validCharacters.hasMatch(value)) {
      return "Title contains invalid characters. Only A-Z, a-z, 0-9, and symbols (- + _ \$ : ,) are allowed.";
    }
    return null;
  }

  String? _itemPriceValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Price is required';
    }
    final price = double.tryParse(value);
    if (price == null || price <= 0) {
      return "Please enter a valid price greater than zero.";
    }
    return null;
  }

  // --- Image Picker ---

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // NOTE: Removed non-web specific File checks here.
      // It's cleaner to handle file existence/size validation in the submit logic
      // or the service layer right before upload.

      setState(() {
        _pickedImage = image;
      });
    }
  }

  // --- Submission Logic ---

  void _submitItem() async {
    // 1. Validate form
    if (!_formKey.currentState!.validate()) return;

    // 2. Validate Image
    if (_pickedImage == null) {
      NavigationUtils.showErrorMessage(context, "Please select an image.");
      return;
    }

    // NOTE: Removed the redundant File(path) check here,
    // relying on XFile integrity and the check in the service layer.

    // 3. Create Model
    final double price = double.parse(_itemPriceController.text);

    final newItem = ItemModel(
      name: _itemNameController.text.trim(),
      price: price,
      // FIXED: Store XFile directly
      imageXFile: _pickedImage,
    );

    // 4. Store locally via Provider
    context.read<ListingProvider>().addItemToDraft(newItem);

    // 5. Close the popup,
    NavigationUtils.pop(context); // Pass result true
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _itemPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Using a Dialog wrapper around the content
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.kBorderRadius),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.kDefaultPadding),
        constraints: const BoxConstraints(
          maxWidth: AppConstants.kMaxContentWidth,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey, // Attach Form Key
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // --- Image Picker Area ---
                InkWell(
                  onTap: _pickImage,
                  child: AspectRatio(
                    aspectRatio: 1 / 1,
                    child: Container(
                      decoration: BoxDecoration(color: AppColors.disabledColor),
                      constraints: const BoxConstraints(
                        minHeight: 50,
                        maxHeight: 100,
                      ),
                      child: Center(
                        // Uses the helper function, now handling XFile
                        child: _buildImageDisplay(_pickedImage),
                      ),
                    ),
                  ),
                ),

                AppSpaces.mediumDivider,

                // --- Name Input ---
                CustomInputBox(
                  controller: _itemNameController,
                  title: "Item Name",
                  description:
                      "Item Name Can Contain A-Z, a-z, 0-9 and some symbols (- + _ \$ : ,) | Have 1 - 64 Characters",
                  validator: _itemNameValidator,
                ),

                AppSpaces.smallVertical,
                // --- Price Input ---
                CustomInputBox(
                  controller: _itemPriceController,
                  title: "Item Price",
                  description: "Item Price is in USD \$ (1.10, 1.00, 1, 2)",
                  keyboardType: TextInputType.number,
                  validator: _itemPriceValidator,
                ),

                AppSpaces.largeDivider,

                // --- Action Buttons ---
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: "Cancel",
                        buttonColor: AppColors.danger,
                        onPressed: () => NavigationUtils.pop(context),
                      ),
                    ),
                    AppSpaces.largeHorizontal,
                    Expanded(
                      child: CustomButton(text: "Add", onPressed: _submitItem),
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

// Updated helper function to only rely on XFile
Widget _buildImageDisplay(XFile? pickedXFile) {
  if (pickedXFile != null) {
    if (kIsWeb) {
      return FutureBuilder<Uint8List>(
        future: pickedXFile.readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.data != null) {
            return Image.memory(
              snapshot.data!,
              fit: BoxFit.cover,
              width: double.infinity,
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      );
    } else {
      return Image.file(
        File(pickedXFile.path),
        fit: BoxFit.cover,
        width: double.infinity,
      );
    }
  }

  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: const [
      Text(
        "Item Image",
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
  );
}
