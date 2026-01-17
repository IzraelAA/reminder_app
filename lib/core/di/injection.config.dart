// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../features/reminder/data/datasources/reminder_local_datasource.dart'
    as _i874;
import '../../features/reminder/data/repositories/reminder_repository_impl.dart'
    as _i819;
import '../../features/reminder/domain/repositories/reminder_repository.dart'
    as _i731;
import '../../features/reminder/presentation/bloc/reminder/reminder_bloc.dart'
    as _i104;
import '../../features/reminder/services/location_permission_service.dart'
    as _i489;
import '../../features/reminder/services/location_reminder_service.dart'
    as _i1030;
import '../../features/reminder/services/notification_service.dart' as _i133;
import '../../features/sample/data/datasources/sample_local_datasource.dart'
    as _i470;
import '../../features/sample/data/datasources/sample_remote_datasource.dart'
    as _i103;
import '../../features/sample/data/repositories/sample_repository_impl.dart'
    as _i647;
import '../../features/sample/domain/repositories/sample_repository.dart'
    as _i672;
import '../../features/sample/domain/usecases/get_sample_by_id_usecase.dart'
    as _i908;
import '../../features/sample/domain/usecases/get_samples_usecase.dart'
    as _i1043;
import '../../features/sample/presentation/cubit/sample_cubit.dart' as _i686;
import '../../features/sample/presentation/cubit/sample_detail_cubit.dart'
    as _i1036;
import '../local_storage/hive_storage.dart' as _i1023;
import 'register_module.dart' as _i291;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final registerModule = _$RegisterModule();
    await gh.factoryAsync<_i1023.HiveStorage>(
      () => registerModule.hiveStorage,
      preResolve: true,
    );
    gh.lazySingleton<_i361.Dio>(() => registerModule.dio);
    gh.lazySingleton<_i489.LocationPermissionService>(
        () => _i489.LocationPermissionService());
    gh.lazySingleton<_i1030.LocationReminderService>(
        () => _i1030.LocationReminderService());
    gh.lazySingleton<_i133.NotificationService>(
        () => _i133.NotificationService());
    gh.lazySingleton<_i103.SampleRemoteDataSource>(
        () => _i103.SampleRemoteDataSourceImpl(gh<_i361.Dio>()));
    gh.lazySingleton<_i874.ReminderLocalDataSource>(
        () => _i874.ReminderLocalDataSourceImpl());
    gh.lazySingleton<_i731.ReminderRepository>(() =>
        _i819.ReminderRepositoryImpl(gh<_i874.ReminderLocalDataSource>()));
    gh.lazySingleton<_i470.SampleLocalDataSource>(
        () => _i470.SampleLocalDataSourceImpl(gh<_i1023.HiveStorage>()));
    gh.lazySingleton<_i672.SampleRepository>(() => _i647.SampleRepositoryImpl(
          remoteDataSource: gh<_i103.SampleRemoteDataSource>(),
          localDataSource: gh<_i470.SampleLocalDataSource>(),
        ));
    gh.lazySingleton<_i1043.GetSamplesUseCase>(
        () => _i1043.GetSamplesUseCase(gh<_i672.SampleRepository>()));
    gh.lazySingleton<_i908.GetSampleByIdUseCase>(
        () => _i908.GetSampleByIdUseCase(gh<_i672.SampleRepository>()));
    gh.factory<_i1036.SampleDetailCubit>(() => _i1036.SampleDetailCubit(
        getSampleByIdUseCase: gh<_i908.GetSampleByIdUseCase>()));
    gh.factory<_i104.ReminderBloc>(() => _i104.ReminderBloc(
          gh<_i731.ReminderRepository>(),
          gh<_i133.NotificationService>(),
        ));
    gh.factory<_i686.SampleCubit>(() => _i686.SampleCubit(
          getSamplesUseCase: gh<_i1043.GetSamplesUseCase>(),
          getSampleByIdUseCase: gh<_i908.GetSampleByIdUseCase>(),
        ));
    return this;
  }
}

class _$RegisterModule extends _i291.RegisterModule {}
