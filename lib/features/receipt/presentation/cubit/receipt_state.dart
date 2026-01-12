part of 'receipt_cubit.dart';

abstract class ReceiptState extends Equatable {
  const ReceiptState();

  @override
  List<Object?> get props => [];
}

class ReceiptInitial extends ReceiptState {}

class ReceiptLoading extends ReceiptState {}

class ReceiptSubmitting extends ReceiptState {}

class ReceiptsLoaded extends ReceiptState {
  final List<Receipt> receipts;
  final int total;
  final int approved;
  final int pending;

  const ReceiptsLoaded({
    required this.receipts,
    required this.total,
    required this.approved,
    required this.pending,
  });

  @override
  List<Object?> get props => [receipts, total, approved, pending];
}

class ReceiptCreated extends ReceiptState {
  final Receipt receipt;

  const ReceiptCreated({required this.receipt});

  @override
  List<Object?> get props => [receipt];
}

class ReceiptError extends ReceiptState {
  final String message;

  const ReceiptError(this.message);

  @override
  List<Object?> get props => [message];
}

