import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/animations.dart';
import '../../../../core/widgets/styled_card.dart';
import '../../domain/entities/receipt.dart';

class ReceiptListItem extends StatelessWidget {
  final Receipt receipt;
  final int index;

  const ReceiptListItem({
    super.key,
    required this.receipt,
    required this.index,
  });

  Color _getTypeColor() {
    switch (receipt.type) {
      case ReceiptType.fuel:
        return Colors.blue;
      case ReceiptType.parking:
        return Colors.orange;
      case ReceiptType.toll:
        return Colors.green;
      case ReceiptType.other:
        return Colors.grey;
    }
  }

  String _getTypeText() {
    switch (receipt.type) {
      case ReceiptType.fuel:
        return 'Fuel';
      case ReceiptType.parking:
        return 'Parking';
      case ReceiptType.toll:
        return 'Toll';
      case ReceiptType.other:
        return 'Other';
    }
  }

  Color _getStatusColor() {
    switch (receipt.status) {
      case ReceiptStatus.approved:
        return Colors.green;
      case ReceiptStatus.pending:
        return Colors.orange;
      case ReceiptStatus.rejected:
        return Colors.red;
    }
  }

  String _getStatusText() {
    switch (receipt.status) {
      case ReceiptStatus.approved:
        return 'Approved';
      case ReceiptStatus.pending:
        return 'Pending';
      case ReceiptStatus.rejected:
        return 'Rejected';
    }
  }

  IconData _getStatusIcon() {
    switch (receipt.status) {
      case ReceiptStatus.approved:
        return Icons.check_circle;
      case ReceiptStatus.pending:
        return Icons.access_time;
      case ReceiptStatus.rejected:
        return Icons.cancel;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm');

    return FadeSlideAnimation(
      delay: Duration(milliseconds: 200 + (index * 50)),
      beginOffset: const Offset(0, 0.1),
      child: StyledCard(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getTypeColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getTypeColor().withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _getTypeText(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getTypeColor(),
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getStatusColor().withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _getStatusText(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  dateFormat.format(receipt.receiptDate),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '₹${receipt.amount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        receipt.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  _getStatusIcon(),
                  size: 16,
                  color: _getStatusColor(),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    receipt.status == ReceiptStatus.approved
                        ? 'Approved by ${receipt.approvedBy ?? "Manager"}'
                        : receipt.status == ReceiptStatus.pending
                            ? 'Under review'
                            : receipt.rejectionReason ?? 'Receipt image not clear',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                if (receipt.status == ReceiptStatus.approved && receipt.approvedAt != null)
                  Text(
                    '${dateFormat.format(receipt.approvedAt!)} ${timeFormat.format(receipt.approvedAt!)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  )
                else if (receipt.status == ReceiptStatus.pending)
                  Text(
                    'Submitted ${dateFormat.format(receipt.submittedAt)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

