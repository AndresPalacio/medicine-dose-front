import 'package:freezed_annotation/freezed_annotation.dart';

part 'data_state.freezed.dart';

@freezed
class DataState<T> with _$DataState<T> {
  const factory DataState.initial() = DataStateInitial<T>;

  const factory DataState.loading() = DataStateLoading<T>;

  const factory DataState.failure(Object error) = DataStateFailure<T>;

  const factory DataState.success({
    required T value,
    @Default(DataStateInitial<void>()) DataState<void> updateStatus,
  }) = DataStateSuccess<T>;
}

extension DataStateExtensions<T> on DataState<T> {
  bool get isInitial {
    return maybeWhen(
      initial: () => true,
      orElse: () => false,
    );
  }

  bool get isInitialOrLoading {
    return maybeWhen(
      initial: () => true,
      loading: () => true,
      orElse: () => false,
    );
  }

  bool get isLoading {
    return maybeWhen(
      loading: () => true,
      orElse: () => false,
    );
  }

  bool get isSuccess {
    return maybeMap(
      success: (_) => true,
      orElse: () => false,
    );
  }

  bool get hasFailure {
    return maybeWhen(
      failure: (_) => true,
      orElse: () => false,
    );
  }

  T? get value {
    return maybeMap(
      success: (state) => state.value,
      orElse: () => null,
    );
  }

  Object? get error {
    return maybeWhen(
      failure: (Object? error) => error,
      orElse: () => null,
    );
  }
}
