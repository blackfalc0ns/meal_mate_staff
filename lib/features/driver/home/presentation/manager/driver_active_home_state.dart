import '../../domain/entities/driver_active_home_entity.dart';

enum DriverActiveHomeStatus { initial, loading, loaded, error }

class DriverActiveHomeState {
  const DriverActiveHomeState({
    this.status = DriverActiveHomeStatus.initial,
    this.data,
    this.errorMessage,
  });

  final DriverActiveHomeStatus status;
  final DriverActiveHomeEntity? data;
  final String? errorMessage;

  DriverActiveHomeState copyWith({
    DriverActiveHomeStatus? status,
    DriverActiveHomeEntity? data,
    String? errorMessage,
  }) {
    return DriverActiveHomeState(
      status: status ?? this.status,
      data: data ?? this.data,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
