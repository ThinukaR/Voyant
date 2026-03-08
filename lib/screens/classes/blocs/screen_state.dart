part of 'screen_bloc.dart';

enum ScreenStatus { initial, selected, confirmed }

class SkillClassModel extends Equatable {
  final String name;
  final String subtitle;
  final String description;
  final String perkLabel;
  final IconData icon;

  const SkillClassModel({
    required this.name,
    required this.subtitle,
    required this.description,
    required this.perkLabel,
    required this.icon,
  });

  @override
  List<Object> get props => [name];
}

class ScreenState extends Equatable {
  final List<SkillClassModel> availableClasses;
  final int currentPageIndex;
  final String? selectedClassName;
  final ScreenStatus status;

  const ScreenState({
    required this.availableClasses,
    this.currentPageIndex = 0,
    this.selectedClassName,
    this.status = ScreenStatus.initial,
  });

  SkillClassModel? get currentClass =>
      availableClasses.isNotEmpty ? availableClasses[currentPageIndex] : null;

  ScreenState copyWith({
    int? currentPageIndex,
    String? selectedClassName,
    ScreenStatus? status,
  }) {
    return ScreenState(
      availableClasses: availableClasses,
      currentPageIndex: currentPageIndex ?? this.currentPageIndex,
      selectedClassName: selectedClassName ?? this.selectedClassName,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props =>
      [availableClasses, currentPageIndex, selectedClassName, status];
}