part of 'screen_bloc.dart';

abstract class ScreenEvent extends Equatable {
  const ScreenEvent();

  @override
  List<Object> get props => [];
}

class ScreenPageChanged extends ScreenEvent {
  final int pageIndex;

  const ScreenPageChanged(this.pageIndex);

  @override
  List<Object> get props => [pageIndex];
}

class ScreenClassSelected extends ScreenEvent {
  final String className;

  const ScreenClassSelected(this.className);

  @override
  List<Object> get props => [className];
}

class ScreenSelectionConfirmed extends ScreenEvent {
  const ScreenSelectionConfirmed();
}