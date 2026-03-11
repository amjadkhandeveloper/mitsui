import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/receipt.dart';

bool _hasImage(String? s) =>
    s != null && s.trim().isNotEmpty;

/// Shows image from either a URL (http/https) or a base64 data string.
class _ReceiptImage extends StatelessWidget {
  final String source;

  const _ReceiptImage({required this.source});

  static const double _height = 200;

  @override
  Widget build(BuildContext context) {
    final isUrl = source.startsWith('http://') || source.startsWith('https://');
    Widget image;
    if (isUrl) {
      image = Image.network(
        source,
        height: _height,
        width: double.infinity,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
      );
    } else {
      String base64Data = source.trim();
      if (base64Data.contains(',')) base64Data = base64Data.split(',').last;
      try {
        final bytes = base64Decode(base64Data);
        image = Image.memory(
          bytes,
          height: _height,
          width: double.infinity,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _buildPlaceholder(),
        );
      } catch (_) {
        image = _buildPlaceholder();
      }
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: image,
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: _height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image_outlined, size: 40, color: Colors.grey.shade400),
          const SizedBox(height: 8),
          Text(
            'Unable to load image',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

class _ReceiptImageCard extends StatelessWidget {
  final String label;
  final String source;

  const _ReceiptImageCard({required this.label, required this.source});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.mitsuiDarkBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.mitsuiDarkBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _ReceiptImage(source: source),
        ],
      ),
    );
  }
}

class ReceiptDetailScreen extends StatelessWidget {
  final Receipt receipt;

  const ReceiptDetailScreen({super.key, required this.receipt});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    Color statusColor;
    String statusText;
    switch (receipt.status) {
      case ReceiptStatus.approved:
        statusColor = Colors.green;
        statusText = 'Approved';
        break;
      case ReceiptStatus.pending:
        statusColor = Colors.orange;
        statusText = 'Pending';
        break;
      case ReceiptStatus.rejected:
        statusColor = Colors.red;
        statusText = 'Rejected';
        break;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Receipt Detail'),
        backgroundColor: AppTheme.mitsuiDarkBlue,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top summary card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '₹${receipt.amount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: statusColor.withOpacity(0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              receipt.status == ReceiptStatus.approved
                                  ? Icons.check_circle
                                  : receipt.status == ReceiptStatus.pending
                                      ? Icons.access_time
                                      : Icons.cancel,
                              size: 16,
                              color: statusColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              statusText,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: statusColor,
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
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dateFormat.format(receipt.receiptDate),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  if (receipt.expLocation != null &&
                      receipt.expLocation!.trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            receipt.expLocation!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Meta information card (IDs etc. if available)
            if (receipt.expenseId != null ||
                receipt.expenseTypeId != 0 ||
                receipt.driverId != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Details',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (receipt.expenseId != null)
                      _DetailRow(
                        label: 'Expense ID',
                        value: receipt.expenseId.toString(),
                      ),
                    _DetailRow(
                      label: 'Type',
                      value: () {
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
                      }(),
                    ),
                    if (receipt.driverId != null)
                      _DetailRow(
                        label: 'Driver ID',
                        value: receipt.driverId!,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            // Receipt Images - two images with clear labels
            if (_hasImage(receipt.receiptImageUrl) || _hasImage(receipt.receiptImageUrl2)) ...[
              Row(
                children: [
                  Icon(Icons.receipt_long, size: 20, color: AppTheme.mitsuiDarkBlue),
                  const SizedBox(width: 8),
                  Text(
                    'Receipt Images',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_hasImage(receipt.receiptImageUrl))
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ReceiptImageCard(
                    label: 'Receipt 1',
                    source: receipt.receiptImageUrl!,
                  ),
                ),
              if (_hasImage(receipt.receiptImageUrl2))
                _ReceiptImageCard(
                  label: 'Receipt 2',
                  source: receipt.receiptImageUrl2!,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

