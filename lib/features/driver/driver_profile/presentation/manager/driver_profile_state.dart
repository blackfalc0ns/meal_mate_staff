import '../../../../../core/network/failures.dart';
import '../../domain/entities/driver_profile_entity.dart';

class DriverProfileState {
  const DriverProfileState({
    this.profile,
    this.failure,
    this.inlineFailure,
    this.isInitialLoading = true,
    this.isRefreshing = false,
    this.localeCode,
    this.lastSuccessfulLoadAt,
  });

  final DriverProfileEntity? profile;
  final Failure? failure;
  final Failure? inlineFailure;
  final bool isInitialLoading;
  final bool isRefreshing;
  final String? localeCode;
  final DateTime? lastSuccessfulLoadAt;

  bool get hasContent => profile != null;

  DriverProfileState copyWith({
    DriverProfileEntity? profile,
    Failure? failure,
    bool clearFailure = false,
    Failure? inlineFailure,
    bool clearInlineFailure = false,
    bool? isInitialLoading,
    bool? isRefreshing,
    String? localeCode,
    DateTime? lastSuccessfulLoadAt,
  }) {
    return DriverProfileState(
      profile: profile ?? this.profile,
      failure: clearFailure ? null : (failure ?? this.failure),
      inlineFailure:
          clearInlineFailure ? null : (inlineFailure ?? this.inlineFailure),
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      localeCode: localeCode ?? this.localeCode,
      lastSuccessfulLoadAt:
          lastSuccessfulLoadAt ?? this.lastSuccessfulLoadAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DriverProfileState &&
          runtimeType == other.runtimeType &&
          profile == other.profile &&
          failure == other.failure &&
          inlineFailure == other.inlineFailure &&
          isInitialLoading == other.isInitialLoading &&
          isRefreshing == other.isRefreshing &&
          localeCode == other.localeCode &&
          lastSuccessfulLoadAt == other.lastSuccessfulLoadAt;

  @override
  int get hashCode => Object.hash(
        profile,
        failure,
        inlineFailure,
        isInitialLoading,
        isRefreshing,
        localeCode,
        lastSuccessfulLoadAt,
      );
}
