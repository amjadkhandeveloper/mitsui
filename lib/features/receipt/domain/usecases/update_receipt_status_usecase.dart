import '../../../../core/utils/result.dart';
import '../repositories/receipt_repository.dart';

class UpdateReceiptStatusUseCase {
  final ReceiptRepository repository;

  UpdateReceiptStatusUseCase({required this.repository});

  FutureResult<void> call({
    required int expenseId,
    required int expenseStatusId,
    required int approvedByUserId,
    String? remark,
  }) async {
    return await repository.updateReceiptStatus(
      expenseId: expenseId,
      expenseStatusId: expenseStatusId,
      approvedByUserId: approvedByUserId,
      remark: remark,
    );
  }
}

