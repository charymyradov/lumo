import 'package:equatable/equatable.dart';

class BreathingState extends Equatable {
  final bool sessionDone;
  const BreathingState({this.sessionDone = false});

  @override
  List<Object?> get props => [sessionDone];
}
