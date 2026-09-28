import '../../domain/entities/driver_start_work_entity.dart';

enum DriverStartWorkStatus { initial, loading, loaded, error }

class DriverStartWorkState {
  const DriverStartWorkState({
    this.status = DriverStartWorkStatus.initial,
    this.data,
    this.errorMessage,
  });

  final DriverStartWorkStatus status;
  final DriverStartWorkEntity? data;
  final String? errorMessage;

  DriverStartWorkState copyWith({
    DriverStartWorkStatus? status,
    DriverStartWorkEntity? data,
    String? errorMessage,
  }) {
    return DriverStartWorkState(
      status: status ?? this.status,
      data: data ?? this.data,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
