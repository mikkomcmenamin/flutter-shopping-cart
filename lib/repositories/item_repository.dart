import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shopping_cart_firebase/custom_exception.dart';
import 'package:shopping_cart_firebase/general_providers.dart';

import '../models/item_model.dart';

abstract class BaseItemRepository {
  Future<List<Item>> retrieveItems({required String userId});

  Future<String> createItem({required String userId, required Item item});

  Future<void> updateItem({required String userId, required Item item});

  Future<void> deleteItem({required String userId, required String itemId});
}

final itemRepositoryProvider =
    Provider<ItemRepository>((ref) => ItemRepository(ref.read));

class ItemRepository implements BaseItemRepository {
  final Reader _read;

  const ItemRepository(this._read);

  @override
  Future<List<Item>> retrieveItems({required String userId}) async {
    try {
      final snap = await _read(firebaseFirestoreProvider)
          .collection('lists')
          .doc(userId)
          .collection('userList')
          .get();
      return snap.docs.map((doc) => Item.fromDocument(doc)).toList();
    } on FirebaseException catch (e) {
      throw CustomException(message: e.message);
    }
  }

  @override
  Future<String> createItem(
      {required String userId, required Item item}) async {
    try {
      final docRef = await _read(firebaseFirestoreProvider)
          .collection('lists')
          .doc(userId)
          .collection('userList')
          .add(item.toDocument());
      return docRef.id;
    } on FirebaseException catch (e) {
      throw CustomException(message: e.message);
    }
  }

  @override
  Future<void> updateItem({required String userId, required Item item}) async {
    try {
      await _read(firebaseFirestoreProvider)
          .collection('lists')
          .doc(userId)
          .collection('userList')
          .doc(item.id)
          .update(item.toDocument());
    } on FirebaseException catch (e) {
      throw CustomException(message: e.message);
    }
  }

  @override
  Future<void> deleteItem(
      {required String userId, required String itemId}) async {
    try {
      await _read(firebaseFirestoreProvider)
          .collection('lists')
          .doc(userId)
          .collection('userList')
          .doc(itemId)
          .delete();
    } on FirebaseException catch (e) {
      throw CustomException(message: e.message);
    }
  }
}
