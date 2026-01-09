import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Example Cubit State
class ExampleState extends Equatable {
  final bool isLoading;
  final String? error;
  final String? data;

  const ExampleState({
    this.isLoading = false,
    this.error,
    this.data,
  });

  ExampleState copyWith({
    bool? isLoading,
    String? error,
    String? data,
  }) {
    return ExampleState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      data: data ?? this.data,
    );
  }

  @override
  List<Object?> get props => [isLoading, error, data];
}

// Example Cubit
class ExampleCubit extends Cubit<ExampleState> {
  ExampleCubit() : super(const ExampleState());

  // Example method to fetch data
  Future<void> fetchData() async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Replace with actual use case call
      // final result = await getDataUseCase(NoParams());
      // result.fold(
      //   (failure) => emit(state.copyWith(
      //     isLoading: false,
      //     error: failure.message,
      //   )),
      //   (data) => emit(state.copyWith(
      //     isLoading: false,
      //     data: data,
      //   )),
      // );

      emit(state.copyWith(
        isLoading: false,
        data: 'Example data loaded successfully',
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }
}
