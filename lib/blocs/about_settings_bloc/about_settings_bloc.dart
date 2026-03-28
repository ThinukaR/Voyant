import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:user_repository/user_repository.dart';

part 'about_settings_event.dart';
part 'about_settings_state.dart';

class AboutSettingsBloc extends Bloc<AboutSettingsEvent, AboutSettingsState> {
  final UserRepository userRepository;

  AboutSettingsBloc({
    required this.userRepository,
  }) : super(const AboutSettingsState.initial()) {
    on<LoadAboutSettingsEvent>(_onLoadSettings);
  }

  Future<void> _onLoadSettings(
      LoadAboutSettingsEvent event,
      Emitter<AboutSettingsState> emit,
      ) async {
    emit(state.copyWith(status: AboutSettingsStatus.loading));
    try {
      final data = await userRepository.getAboutData();
      emit(state.copyWith(
        status: AboutSettingsStatus.success,
        appName: data['appName'] ?? 'Voyant',
        appVersion: data['appVersion'] ?? '1.0.0',
        buildNumber: data['buildNumber'] ?? '1',
        releaseNotes: data['releaseNotes'] ?? [],
        developers: data['developers'] ?? [],
        thirdPartyLibraries: data['thirdPartyLibraries'] ?? [],
        aboutText: data['aboutText'] ?? '',
        mission: data['mission'] ?? '',
        vision: data['vision'] ?? '',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AboutSettingsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
