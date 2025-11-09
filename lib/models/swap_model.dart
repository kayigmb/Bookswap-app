import 'package:cloud_firestore/cloud_firestore.dart';

enum SwapStatus {
  pending,
  accepted,
  rejected,
  completed,
}

class SwapModel {
  final String id;
  final String requesterId;
  final String requesterName;
  final String ownerId;
  final String ownerName;
  final String bookId;
  final String bookTitle;
  final SwapStatus status;
  final DateTime createdAt;
  final String? chatId;

  SwapModel({
    required this.id,
    required this.requesterId,
    required this.requesterName,
    required this.ownerId,
    required this.ownerName,
    required this.bookId,
    required this.bookTitle,
    required this.status,
    required this.createdAt,
    this.chatId,
  });

  factory SwapModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Handle createdAt safely
    DateTime createdAt;
    if (data['createdAt'] == null) {
      createdAt = DateTime.now();
    } else if (data['createdAt'] is Timestamp) {
      createdAt = (data['createdAt'] as Timestamp).toDate();
    } else {
      createdAt = DateTime.now();
    }

    return SwapModel(
      id: doc.id,
      requesterId: data['requesterId'] ?? '',
      requesterName: data['requesterName'] ?? '',
      ownerId: data['ownerId'] ?? '',
      ownerName: data['ownerName'] ?? '',
      bookId: data['bookId'] ?? '',
      bookTitle: data['bookTitle'] ?? '',
      status: SwapStatus.values[data['status'] ?? 0],
      createdAt: createdAt,
      chatId: data['chatId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'requesterId': requesterId,
      'requesterName': requesterName,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'bookId': bookId,
      'bookTitle': bookTitle,
      'status': status.index,
      'createdAt': Timestamp.fromDate(createdAt),
      'chatId': chatId,
    };
  }
}

