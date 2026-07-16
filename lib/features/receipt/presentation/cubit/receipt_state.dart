part of 'receipt_cubit.dart';

enum ReceiptListFilter { all, approved, pending, rejected }

abstract class ReceiptState extends Equatable {
  const ReceiptState();

  @override
  List<Object?> get props => [];
}

class ReceiptInitial extends ReceiptState {}

class ReceiptLoading extends ReceiptState {}

class ReceiptSubmitting extends ReceiptState {}

class ReceiptsLoaded extends ReceiptState {
  final List<Receipt> allReceipts;
  final ReceiptListFilter filter;
  final int total;
  final int approved;
  final int pending;
  final int rejected;

  const ReceiptsLoaded({
    required this.allReceipts,
    this.filter = ReceiptListFilter.all,
    required this.total,
    required this.approved,
    required this.pending,
    required this.rejected,
  });

  List<Receipt> get receipts {
    switch (filter) {
      case ReceiptListFilter.approved:
        return allReceipts
            .where((r) => r.status == ReceiptStatus.approved)
            .toList();
      case ReceiptListFilter.pending:
        return allReceipts
            .where((r) => r.status == ReceiptStatus.pending)
            .toList();
      case ReceiptListFilter.rejected:
        return allReceipts
            .where((r) => r.status == ReceiptStatus.rejected)
            .toList();
      case ReceiptListFilter.all:
        return allReceipts;
    }
  }

  ReceiptsLoaded copyWith({
    List<Receipt>? allReceipts,
    ReceiptListFilter? filter,
    int? total,
    int? approved,
    int? pending,
    int? rejected,
  }) {
    return ReceiptsLoaded(
      allReceipts: allReceipts ?? this.allReceipts,
      filter: filter ?? this.filter,
      total: total ?? this.total,
      approved: approved ?? this.approved,
      pending: pending ?? this.pending,
      rejected: rejected ?? this.rejected,
    );
  }

  @override
  List<Object?> get props =>
      [allReceipts, filter, total, approved, pending, rejected];
}

class ReceiptCreated extends ReceiptState {
  final Receipt receipt;

  const ReceiptCreated({required this.receipt});

  @override
  List<Object?> get props => [receipt];
}

class ReceiptStatusUpdated extends ReceiptState {
  const ReceiptStatusUpdated();

  @override
  List<Object?> get props => [];
}

class ReceiptError extends ReceiptState {
  final String message;

  const ReceiptError(this.message);

  @override
  List<Object?> get props => [message];
}
