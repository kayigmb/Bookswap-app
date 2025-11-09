import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/swap_model.dart';

class SwapNotificationProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int _pendingSwapsCount = 0;
  Map<String, SwapStatus> _swapStates = {};

  int get pendingSwapsCount => _pendingSwapsCount;

  SwapStatus? getSwapStatus(String swapId) => _swapStates[swapId];

  // Listen to pending swap requests for owner
  void listenToPendingSwaps(String userId) {
    // Listen to swaps where user is owner and status is pending
    _firestore
        .collection('swaps')
        .where('ownerId', isEqualTo: userId)
        .where('status', isEqualTo: SwapStatus.pending.index)
        .snapshots()
        .listen((snapshot) {
      _pendingSwapsCount = snapshot.docs.length;
      notifyListeners();
    });

    // Listen to all swaps involving the user to track state changes
    _firestore
        .collection('swaps')
        .where('ownerId', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) {
      _updateSwapStates(snapshot.docs);
    });

    _firestore
        .collection('swaps')
        .where('requesterId', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) {
      _updateSwapStates(snapshot.docs);
    });
  }

  void _updateSwapStates(List<QueryDocumentSnapshot> docs) {
    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final status = SwapStatus.values[data['status'] ?? 0];
      _swapStates[doc.id] = status;
    }
    notifyListeners();
  }

  // Show notification when swap state changes
  void showSwapStateNotification(
    BuildContext context,
    String swapId,
    SwapStatus oldStatus,
    SwapStatus newStatus,
    String bookTitle,
  ) {
    String message = '';
    Color backgroundColor = Colors.blue;
    IconData icon = Icons.info;

    switch (newStatus) {
      case SwapStatus.pending:
        message = 'Swap request sent for "$bookTitle"';
        backgroundColor = Colors.orange;
        icon = Icons.hourglass_empty;
        break;
      case SwapStatus.accepted:
        message = 'Swap accepted for "$bookTitle"! 🎉';
        backgroundColor = Colors.green;
        icon = Icons.check_circle;
        break;
      case SwapStatus.rejected:
        message = 'Swap rejected for "$bookTitle"';
        backgroundColor = Colors.red;
        icon = Icons.cancel;
        break;
      case SwapStatus.completed:
        message = 'Swap completed for "$bookTitle"! ✨';
        backgroundColor = Colors.blue;
        icon = Icons.done_all;
        break;
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: backgroundColor,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  // Clear pending count
  void clearPendingCount() {
    _pendingSwapsCount = 0;
    notifyListeners();
  }
}

