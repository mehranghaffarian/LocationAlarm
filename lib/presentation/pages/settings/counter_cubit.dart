import 'package:flutter_bloc/flutter_bloc.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit(initialCount) : super(initialCount);

  void increment() => emit(state + 1);

  void decrement() => emit(state - 1);
}