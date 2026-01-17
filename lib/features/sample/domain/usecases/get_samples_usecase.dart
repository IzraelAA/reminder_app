import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:reminder_app/core/domain/usecase/usecase.dart';
import 'package:reminder_app/core/network/failure.dart';
import 'package:reminder_app/features/sample/domain/entities/sample_entity.dart';
import 'package:reminder_app/features/sample/domain/repositories/sample_repository.dart';

@lazySingleton
class GetSamplesUseCase implements UseCase<List<SampleEntity>, NoParams> {
  final SampleRepository repository;

  GetSamplesUseCase(this.repository);

  @override
  Future<Either<Failure, List<SampleEntity>>> call(NoParams params) {
    return repository.getSamples();
  }
}
