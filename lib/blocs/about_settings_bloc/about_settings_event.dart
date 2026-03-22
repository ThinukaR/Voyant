part of 'about_settings_bloc.dart';

abstract class AboutSettingsEvent extends Equatable {
  const AboutSettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadAboutSettingsEvent extends AboutSettingsEvent {
  const LoadAboutSettingsEvent();
}

