import '../../../../core/utils/result.dart';
import '../entities/receipt.dart';
import '../repositories/receipt_repository.dart';

class GetReceiptsUseCase {
  final ReceiptRepository repository;

  GetReceiptsUseCase({required this.repository});

  FutureResult<List<Receipt>> call({String? driverId, String? status}) async {
    return await repository.getReceipts(driverId: driverId, status: status);
  }
}

