part of 'about_settings_bloc.dart';

enum AboutSettingsStatus {
  initial,
  loading,
  success,
  failure,
}

class AboutSettingsState extends Equatable {
  final AboutSettingsStatus status;
  final String appName;
  final String appVersion;
  final String buildNumber;
  final List<Map<String, String>> releaseNotes;
  final List<Map<String, String>> developers;
  final List<Map<String, String>> thirdPartyLibraries;
  final String aboutText;
  final String mission;
  final String vision;
  final String? errorMessage;

  const AboutSettingsState({
    this.status = AboutSettingsStatus.initial,
    this.appName = 'Voyant',
    this.appVersion = '1.0.0',
    this.buildNumber = '1',
    this.releaseNotes = const [],
    this.developers = const [],
    this.thirdPartyLibraries = const [],
    this.aboutText = '',
    this.mission = '',
    this.vision = '',
    this.errorMessage,
  });

  const AboutSettingsState.initial()
      : this(status: AboutSettingsStatus.initial);

  AboutSettingsState copyWith({
    AboutSettingsStatus? status,
    String? appName,
    String? appVersion,
    String? buildNumber,
    List<Map<String, String>>? releaseNotes,
    List<Map<String, String>>? developers,
    List<Map<String, String>>? thirdPartyLibraries,
    String? aboutText,
    String? mission,
    String? vision,
    String? errorMessage,
  }) {
    return AboutSettingsState(
      status: status ?? this.status,
      appName: appName ?? this.appName,
      appVersion: appVersion ?? this.appVersion,
      buildNumber: buildNumber ?? this.buildNumber,
      releaseNotes: releaseNotes ?? this.releaseNotes,
      developers: developers ?? this.developers,
      thirdPartyLibraries: thirdPartyLibraries ?? this.thirdPartyLibraries,
      aboutText: aboutText ?? this.aboutText,
      mission: mission ?? this.mission,
      vision: vision ?? this.vision,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    appName,
    appVersion,
    buildNumber,
    releaseNotes,
    developers,
    thirdPartyLibraries,
    aboutText,
    mission,
    vision,
    errorMessage,
  ];
}

