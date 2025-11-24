import 'package:flutter/foundation.dart';
import 'package:flutter_app/models/seller/item_model.dart';
import 'package:uuid/uuid.dart';

class ListingProvider with ChangeNotifier {
  final Uuid _uuid = const Uuid();
  List<ItemModel> _localItems = [];

  List<ItemModel> get localItems => _localItems;

  void addItemToDraft(ItemModel item) {
    final itemWithId = item.copyWith(
      localId: _uuid.v4(),
    );
    _localItems.add(itemWithId);
    notifyListeners();
  }

  void removeItemFromDraft(String localId) {
    _localItems.removeWhere((item) => item.localId == localId);
    notifyListeners();
  }

  void clearDraft() {
    _localItems.clear();
    notifyListeners();
  }

}