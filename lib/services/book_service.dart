import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book_model.dart';

class BookService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a book listing
  Future<String> createBook({
    required String title,
    required String author,
    required BookCondition condition,
    required String ownerId,
    required String ownerName,
    String? swapFor,
  }) async {
    try {
      // Create book document in Firestore
      DocumentReference docRef = await _firestore.collection('books').add({
        'title': title,
        'author': author,
        'condition': condition.index,
        'status': BookStatus.available.index,
        'imageUrl': '',
        'ownerId': ownerId,
        'ownerName': ownerName,
        'createdAt': FieldValue.serverTimestamp(),
        'swapFor': swapFor,
      });

      return docRef.id;
    } catch (e) {
      throw 'Failed to create book listing: $e';
    }
  }

  // Get all available books
  Stream<List<BookModel>> getAllBooks() {
    return _firestore
        .collection('books')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookModel.fromFirestore(doc))
            .toList());
  }

  // Get books by owner
  Stream<List<BookModel>> getBooksByOwner(String ownerId) {
    return _firestore
        .collection('books')
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookModel.fromFirestore(doc))
            .toList());
  }

  // Update book
  Future<void> updateBook({
    required String bookId,
    String? title,
    String? author,
    BookCondition? condition,
    String? swapFor,
    BookStatus? status,
  }) async {
    try {
      Map<String, dynamic> updates = {};

      if (title != null) updates['title'] = title;
      if (author != null) updates['author'] = author;
      if (condition != null) updates['condition'] = condition.index;
      if (swapFor != null) updates['swapFor'] = swapFor;
      if (status != null) updates['status'] = status.index;

      await _firestore.collection('books').doc(bookId).update(updates);
    } catch (e) {
      throw 'Failed to update book: $e';
    }
  }

  // Delete book
  Future<void> deleteBook(String bookId) async {
    try {

      // Delete book document
      await _firestore.collection('books').doc(bookId).delete();
    } catch (e) {
      throw 'Failed to delete book: $e';
    }
  }

  // Update book status
  Future<void> updateBookStatus(String bookId, BookStatus status) async {
    try {
      await _firestore.collection('books').doc(bookId).update({
        'status': status.index,
      });
    } catch (e) {
      throw 'Failed to update book status: $e';
    }
  }
}

