import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../models/swap_model.dart';
import '../../services/swap_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/swap_notification_provider.dart';
import 'chat_detail_screen.dart';

class SwapsScreen extends StatelessWidget {
  const SwapsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'My Swaps',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFF6C63FF),
          foregroundColor: Colors.white,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Requests Sent'),
              Tab(text: 'Requests Received'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            SwapsSentTab(),
            SwapsReceivedTab(),
          ],
        ),
      ),
    );
  }
}

// Swaps where current user is the requester
class SwapsSentTab extends StatelessWidget {
  const SwapsSentTab({super.key});

  @override
  Widget build(BuildContext context) {
    final swapService = SwapService();
    final user = context.watch<AuthProvider>().user;

    return StreamBuilder<List<SwapModel>>(
      stream: swapService.getSwapsByRequester(user?.uid ?? ''),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final swaps = snapshot.data ?? [];

        if (swaps.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.swap_horiz,
                  size: 80,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  'No swap requests sent',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: swaps.length,
          itemBuilder: (context, index) {
            final swap = swaps[index];
            return SwapCard(
              swap: swap,
              isRequester: true,
            );
          },
        );
      },
    );
  }
}

// Swaps where current user is the owner
class SwapsReceivedTab extends StatelessWidget {
  const SwapsReceivedTab({super.key});

  @override
  Widget build(BuildContext context) {
    final swapService = SwapService();
    final user = context.watch<AuthProvider>().user;

    return StreamBuilder<List<SwapModel>>(
      stream: swapService.getSwapsByOwner(user?.uid ?? ''),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final swaps = snapshot.data ?? [];

        if (swaps.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.swap_horiz,
                  size: 80,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  'No swap requests received',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: swaps.length,
          itemBuilder: (context, index) {
            final swap = swaps[index];
            return SwapCard(
              swap: swap,
              isRequester: false,
            );
          },
        );
      },
    );
  }
}

class SwapCard extends StatelessWidget {
  final SwapModel swap;
  final bool isRequester;

  const SwapCard({
    super.key,
    required this.swap,
    required this.isRequester,
  });

  Color _getStatusColor() {
    switch (swap.status) {
      case SwapStatus.pending:
        return Colors.orange;
      case SwapStatus.accepted:
        return Colors.green;
      case SwapStatus.rejected:
        return Colors.red;
      case SwapStatus.completed:
        return Colors.blue;
    }
  }

  String _getStatusText() {
    switch (swap.status) {
      case SwapStatus.pending:
        return 'Pending';
      case SwapStatus.accepted:
        return 'Accepted';
      case SwapStatus.rejected:
        return 'Rejected';
      case SwapStatus.completed:
        return 'Completed';
    }
  }

  IconData _getStatusIcon() {
    switch (swap.status) {
      case SwapStatus.pending:
        return Icons.hourglass_empty;
      case SwapStatus.accepted:
        return Icons.check_circle;
      case SwapStatus.rejected:
        return Icons.cancel;
      case SwapStatus.completed:
        return Icons.done_all;
    }
  }

  @override
  Widget build(BuildContext context) {
    final swapService = SwapService();

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status
            Row(
              children: [
                Icon(
                  Icons.menu_book_rounded,
                  color: const Color(0xFF6C63FF),
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        swap.bookTitle,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        isRequester
                            ? 'Owner: ${swap.ownerName}'
                            : 'Requester: ${swap.requesterName}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getStatusIcon(),
                        size: 16,
                        color: _getStatusColor(),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getStatusText(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Timestamp
            Text(
              'Requested ${timeago.format(swap.createdAt)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 16),
            // Actions
            Row(
              children: [
                // Chat button (only for owner, not requester)
                if (!isRequester && swap.chatId != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatDetailScreen(
                              chatId: swap.chatId!,
                              otherUserName: swap.requesterName,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.chat),
                      label: const Text('Chat'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF6C63FF),
                      ),
                    ),
                  ),

                // Actions for owner (not requester)
                if (!isRequester && swap.status == SwapStatus.pending) ...[
                  if (swap.chatId != null) const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showAcceptDialog(context, swapService),
                      icon: const Icon(Icons.check),
                      label: const Text('Accept'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showRejectDialog(context, swapService),
                      icon: const Icon(Icons.close),
                      label: const Text('Reject'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],

                // Complete button for accepted swaps
                if (swap.status == SwapStatus.accepted && !isRequester) ...[
                  if (swap.chatId != null) const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showCompleteDialog(context, swapService),
                      icon: const Icon(Icons.done_all),
                      label: const Text('Complete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAcceptDialog(BuildContext context, SwapService swapService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Accept Swap Request'),
        content: Text(
          'Are you sure you want to accept this swap request for "${swap.bookTitle}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await swapService.acceptSwap(swap.id, swap.bookId);
                if (context.mounted) {
                  Navigator.pop(context);
                  // Show state change notification
                  context.read<SwapNotificationProvider>().showSwapStateNotification(
                    context,
                    swap.id,
                    SwapStatus.pending,
                    SwapStatus.accepted,
                    swap.bookTitle,
                  );
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
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context, SwapService swapService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Swap Request'),
        content: Text(
          'Are you sure you want to reject this swap request for "${swap.bookTitle}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await swapService.rejectSwap(swap.id, swap.bookId);
                if (context.mounted) {
                  Navigator.pop(context);
                  // Show state change notification
                  context.read<SwapNotificationProvider>().showSwapStateNotification(
                    context,
                    swap.id,
                    SwapStatus.pending,
                    SwapStatus.rejected,
                    swap.bookTitle,
                  );
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
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _showCompleteDialog(BuildContext context, SwapService swapService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Swap'),
        content: Text(
          'Mark this swap as completed for "${swap.bookTitle}"?\n\nThis means you have successfully exchanged the book.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await swapService.completeSwap(swap.id, swap.bookId);
                if (context.mounted) {
                  Navigator.pop(context);
                  // Show state change notification
                  context.read<SwapNotificationProvider>().showSwapStateNotification(
                    context,
                    swap.id,
                    SwapStatus.accepted,
                    SwapStatus.completed,
                    swap.bookTitle,
                  );
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
              foregroundColor: Colors.white,
            ),
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }
}

