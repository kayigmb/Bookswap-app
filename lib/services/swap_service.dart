import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/swap_model.dart';
import '../models/book_model.dart';
import 'book_service.dart';

class SwapService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final BookService _bookService = BookService();

  // Create a swap request
  Future<String> createSwapRequest({
    required String requesterId,
    required String requesterName,
    required String bookId,
    required String bookTitle,
    required String ownerId,
    required String ownerName,
  }) async {
    try {
      // Create swap document
      DocumentReference swapRef = await _firestore.collection('swaps').add({
        'requesterId': requesterId,
        'requesterName': requesterName,
        'ownerId': ownerId,
        'ownerName': ownerName,
        'bookId': bookId,
        'bookTitle': bookTitle,
        'status': SwapStatus.pending.index,
        'createdAt': FieldValue.serverTimestamp(),
        'chatId': null,
      });

      // Update book status to pending
      await _bookService.updateBookStatus(bookId, BookStatus.pending);

      // Create a chat for this swap
      DocumentReference chatRef = await _firestore.collection('chats').add({
        'participants': [requesterId, ownerId],
        'participantNames': {
          requesterId: requesterName,
          ownerId: ownerName,
        },
        'lastMessage': 'Swap request created',
        'lastMessageTime': FieldValue.serverTimestamp(),
      });

      // Update swap with chat ID
      await swapRef.update({'chatId': chatRef.id});

      return swapRef.id;
    } catch (e) {
      throw 'Failed to create swap request: $e';
    }
  }

  // Get swaps by requester
  Stream<List<SwapModel>> getSwapsByRequester(String requesterId) {
    return _firestore
        .collection('swaps')
        .where('requesterId', isEqualTo: requesterId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SwapModel.fromFirestore(doc))
            .toList());
  }

  // Get swaps by owner
  Stream<List<SwapModel>> getSwapsByOwner(String ownerId) {
    return _firestore
        .collection('swaps')
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SwapModel.fromFirestore(doc))
            .toList());
  }

  // Get all swaps for a user (both as requester and owner)
  Stream<List<SwapModel>> getAllSwapsForUser(String userId) {
    return _firestore
        .collection('swaps')
        .where('participants', arrayContains: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SwapModel.fromFirestore(doc))
            .toList());
  }

  // Accept swap request
  Future<void> acceptSwap(String swapId, String bookId) async {
    try {
      await _firestore.collection('swaps').doc(swapId).update({
        'status': SwapStatus.accepted.index,
      });

      await _bookService.updateBookStatus(bookId, BookStatus.swapped);
    } catch (e) {
      throw 'Failed to accept swap: $e';
    }
  }

  // Reject swap request
  Future<void> rejectSwap(String swapId, String bookId) async {
    try {
      await _firestore.collection('swaps').doc(swapId).update({
        'status': SwapStatus.rejected.index,
      });

      await _bookService.updateBookStatus(bookId, BookStatus.available);
    } catch (e) {
      throw 'Failed to reject swap: $e';
    }
  }

  // Complete swap
  Future<void> completeSwap(String swapId, String bookId) async {
    try {
      await _firestore.collection('swaps').doc(swapId).update({
        'status': SwapStatus.completed.index,
      });

      await _bookService.updateBookStatus(bookId, BookStatus.swapped);
    } catch (e) {
      throw 'Failed to complete swap: $e';
    }
  }
}

