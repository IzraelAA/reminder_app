import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:reminder_app/core/domain/usecase/usecase.dart';
import 'package:reminder_app/core/network/failure.dart';
import 'package:reminder_app/features/sample/domain/entities/sample_entity.dart';
import 'package:reminder_app/features/sample/domain/repositories/sample_repository.dart';

@lazySingleton
class GetSampleByIdUseCase implements UseCase<SampleEntity, IdParams> {
  final SampleRepository repository;

  GetSampleByIdUseCase(this.repository);

  @override
  Future<Either<Failure, SampleEntity>> call(IdParams params) {
    return repository.getSampleById(params.id);
  }
}
