import 'package:cloud_firestore/cloud_firestore.dart';

enum BookCondition {
  brandNew,
  likeNew,
  good,
  used,
}

enum BookStatus {
  available,
  pending,
  swapped,
}

class BookModel {
  final String id;
  final String title;
  final String author;
  final BookCondition condition;
  final BookStatus status;
  final String imageUrl;
  final String ownerId;
  final String ownerName;
  final DateTime createdAt;
  final String? swapFor;

  BookModel({
    required this.id,
    required this.title,
    required this.author,
    required this.condition,
    required this.status,
    required this.imageUrl,
    required this.ownerId,
    required this.ownerName,
    required this.createdAt,
    this.swapFor,
  });

  factory BookModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Handle createdAt safely - it might be null or not yet set by server
    DateTime createdAt;
    if (data['createdAt'] == null) {
      createdAt = DateTime.now();
    } else if (data['createdAt'] is Timestamp) {
      createdAt = (data['createdAt'] as Timestamp).toDate();
    } else {
      createdAt = DateTime.now();
    }

    return BookModel(
      id: doc.id,
      title: data['title'] ?? '',
      author: data['author'] ?? '',
      condition: BookCondition.values[data['condition'] ?? 0],
      status: BookStatus.values[data['status'] ?? 0],
      imageUrl: data['imageUrl'] ?? '',
      ownerId: data['ownerId'] ?? '',
      ownerName: data['ownerName'] ?? '',
      createdAt: createdAt,
      swapFor: data['swapFor'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': author,
      'condition': condition.index,
      'status': status.index,
      'imageUrl': imageUrl,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'createdAt': Timestamp.fromDate(createdAt),
      'swapFor': swapFor,
    };
  }

  BookModel copyWith({
    String? id,
    String? title,
    String? author,
    BookCondition? condition,
    BookStatus? status,
    String? imageUrl,
    String? ownerId,
    String? ownerName,
    DateTime? createdAt,
    String? swapFor,
  }) {
    return BookModel(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      condition: condition ?? this.condition,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      createdAt: createdAt ?? this.createdAt,
      swapFor: swapFor ?? this.swapFor,
    );
  }

  String get conditionString {
    switch (condition) {
      case BookCondition.brandNew:
        return 'Brand New';
      case BookCondition.likeNew:
        return 'Like New';
      case BookCondition.good:
        return 'Good';
      case BookCondition.used:
        return 'Used';
    }
  }
}

