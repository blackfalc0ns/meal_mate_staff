import '../../../../../core/network/failures.dart';
import '../../domain/entities/driver_home_entity.dart';

class DriverHomeState {
  const DriverHomeState({
    this.isLoading = false,
    this.isRefreshing = false,
    this.home,
    this.failure,
    this.errorMessage,
    this.isRealtimeConnected = false,
  });

  final bool isLoading;
  final bool isRefreshing;
  final DriverHomeEntity? home;
  final Failure? failure;
  final String? errorMessage;
  final bool isRealtimeConnected;

  bool get hasData => home != null;
  bool get hasError => failure != null;
  bool get isInitialLoading => isLoading && home == null;

  DriverHomeState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    DriverHomeEntity? home,
    Failure? failure,
    bool clearFailure = false,
    String? errorMessage,
    bool clearErrorMessage = false,
    bool? isRealtimeConnected,
  }) {
    return DriverHomeState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      home: home ?? this.home,
      failure: clearFailure ? null : (failure ?? this.failure),
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      isRealtimeConnected: isRealtimeConnected ?? this.isRealtimeConnected,
    );
  }
}
