import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../models/book_model.dart';
import '../../services/swap_service.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/swap_notification_provider.dart';
import '../../models/swap_model.dart';

class BookDetailScreen extends StatelessWidget {
  final BookModel book;

  const BookDetailScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().user;
    final isOwner = book.ownerId == user?.uid;
    final swapService = SwapService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Details'),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book Icon
            Hero(
              tag: book.id,
              child: Container(
                width: double.infinity,
                height: 350,
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF).withOpacity(0.1),
                ),
                child: Center(
                  child: Icon(
                    Icons.menu_book_rounded,
                    size: 150,
                    color: const Color(0xFF6C63FF).withOpacity(0.5),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getStatusText(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Title
                  Text(
                    book.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Author
                  Row(
                    children: [
                      Icon(Icons.person, size: 20, color: Colors.grey.shade600),
                      const SizedBox(width: 8),
                      Text(
                        book.author,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  // Condition
                  _DetailRow(
                    icon: Icons.auto_awesome,
                    label: 'Condition',
                    value: book.conditionString,
                  ),
                  const SizedBox(height: 16),
                  // Owner
                  _DetailRow(
                    icon: Icons.account_circle,
                    label: 'Owner',
                    value: book.ownerName,
                  ),
                  const SizedBox(height: 16),
                  // Posted
                  _DetailRow(
                    icon: Icons.access_time,
                    label: 'Posted',
                    value: timeago.format(book.createdAt),
                  ),
                  if (book.swapFor != null && book.swapFor!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _DetailRow(
                      icon: Icons.swap_horiz,
                      label: 'Looking for',
                      value: book.swapFor!,
                    ),
                  ],
                  const SizedBox(height: 32),
                  // Swap Button
                  if (!isOwner && book.status == BookStatus.available)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Request Swap'),
                              content: Text(
                                'Send a swap request for "${book.title}" to ${book.ownerName}?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    try {
                                      String swapId = await swapService.createSwapRequest(
                                        requesterId: user!.uid,
                                        requesterName: user.displayName ?? 'Anonymous',
                                        bookId: book.id,
                                        bookTitle: book.title,
                                        ownerId: book.ownerId,
                                        ownerName: book.ownerName,
                                      );
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                        // Show state change notification
                                        context.read<SwapNotificationProvider>().showSwapStateNotification(
                                          context,
                                          swapId,
                                          SwapStatus.pending,
                                          SwapStatus.pending,
                                          book.title,
                                        );
                                        Navigator.pop(context);
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Error: $e'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF6C63FF),
                                  ),
                                  child: const Text('Send'),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: const Icon(Icons.swap_horiz),
                        label: const Text(
                          'Request Swap',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C63FF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  if (isOwner)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'This is your listing',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (book.status != BookStatus.available && !isOwner)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.orange.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'This book is not currently available for swap',
                              style: TextStyle(color: Colors.orange.shade700),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (book.status) {
      case BookStatus.available:
        return Colors.green;
      case BookStatus.pending:
        return Colors.orange;
      case BookStatus.swapped:
        return Colors.grey;
    }
  }

  String _getStatusText() {
    switch (book.status) {
      case BookStatus.available:
        return 'Available for Swap';
      case BookStatus.pending:
        return 'Swap Pending';
      case BookStatus.swapped:
        return 'Already Swapped';
    }
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 24, color: const Color(0xFF6C63FF)),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

