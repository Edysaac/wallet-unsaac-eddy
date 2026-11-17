import 'package:equatable/equatable.dart';

class PrivacyState extends Equatable {
  const PrivacyState({this.hidden = false});

  final bool hidden;

  @override
  List<Object> get props => [hidden];
}
