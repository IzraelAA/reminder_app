import 'package:injectable/injectable.dart';
import 'package:reminder_app/core/domain/usecase/usecase.dart';
import 'package:reminder_app/core/state_management/base_cubit.dart';
import 'package:reminder_app/features/sample/domain/entities/sample_entity.dart';
import 'package:reminder_app/features/sample/domain/usecases/get_sample_by_id_usecase.dart';

@injectable
class SampleDetailCubit extends BaseCubit<SampleEntity> {
  final GetSampleByIdUseCase getSampleByIdUseCase;

  SampleDetailCubit({required this.getSampleByIdUseCase});

  Future<void> loadSample(String id) async {
    emitLoading();

    final result = await getSampleByIdUseCase(IdParams(id: id));

    result.fold(
      (failure) => emitError(failure.message),
      (sample) => emitSuccess(sample),
    );
  }
}
