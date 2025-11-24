// import 'package:flutter/material.dart';
// import 'package:flutter_app/utils/app_constants.dart';
// import 'package:flutter_app/widgets/custom_input_box.dart';


// class SearchFieldWidget extends StatefulWidget {
//   final Function(List<Listing> results) onSearchResults;

//   const SearchFieldWidget({
//     Key? key,
//     required this.onSearchResults,
//   }) : super(key: key);

//   @override
//   State<SearchFieldWidget> createState() => _SearchFieldWidgetState();
// }

// class _SearchFieldWidgetState extends State<SearchFieldWidget> {
//   final TextEditingController _searchController = TextEditingController();
//   final ListingService _listingService = ListingService(); // Initialize your service

//   bool _isLoading = false;

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   // --- Search Implementation Function ---
//   Future<void> _performSearch(String query) async {
//     if (query.trim().isEmpty) {
//       // Handle case where query is empty (maybe show all listings or clear results)
//       widget.onSearchResults([]); // Clear results or fetch all
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final results = await _listingService.searchListings(query);
//       widget.onSearchResults(results); // Pass results back to the parent widget
//     } catch (e) {
//       // Handle API error (e.g., show a snackbar or an error message)
//       print("Search failed: $e");
//       widget.onSearchResults([]); // Clear results on error
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     const String backgroundImagePath = 'assets/images/bg.jpg';

//     return Container(
//       decoration: const BoxDecoration(
//         image: DecorationImage(
//           image: AssetImage(backgroundImagePath),
//           fit: BoxFit.cover,
//         ),
//       ),
//       child: Center(
//         child: Container(
//           constraints: const BoxConstraints(
//             maxWidth: AppConstants.kMaxContentWidth,
//           ),
//           color: Colors.white.withOpacity(0.95),
//           padding: const EdgeInsets.all(AppConstants.kDefaultPadding),
          
//           // --- CustomInputBox Integration ---
//           child: CustomInputBox(
//             controller: _searchController,
//             placeholder: "Search for products, brands, and more",
//             suffixIcon: _isLoading 
//                 ? const Padding(
//                     padding: EdgeInsets.all(8.0),
//                     child: CircularProgressIndicator(strokeWidth: 2),
//                   )
//                 : IconButton(
//                     icon: const Icon(Icons.search),
//                     onPressed: () {
//                       _performSearch(_searchController.text);
//                     },
//                   ),
//             onSubmitted: _performSearch, 
//           ),
//         ),
//       ),
//     );
//   }
// }