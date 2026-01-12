import '../../../../core/utils/result.dart';
import '../entities/free_slot.dart';
import '../repositories/vehicle_schedule_repository.dart';

class CreateFreeSlotUseCase {
  final VehicleScheduleRepository repository;

  CreateFreeSlotUseCase({required this.repository});

  FutureResult<FreeSlot> call(Map<String, dynamic> slotData) async {
    return await repository.createFreeSlot(slotData);
  }
}

