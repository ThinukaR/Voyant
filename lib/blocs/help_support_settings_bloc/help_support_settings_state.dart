part of 'help_support_settings_bloc.dart';

enum HelpSupportSettingsStatus {
  initial,
  loading,
  success,
  failure,
  ticketSubmitted,
  bugReportSubmitted,
  feedbackSubmitted,
  ratingSubmitted,
}

class HelpSupportSettingsState extends Equatable {
  final HelpSupportSettingsStatus status;
  final List<Map<String, String>> faqs;
  final List<Map<String, dynamic>> supportTickets;
  final String appVersion;
  final String? errorMessage;

  const HelpSupportSettingsState({
    this.status = HelpSupportSettingsStatus.initial,
    this.faqs = const [],
    this.supportTickets = const [],
    this.appVersion = '1.0.0',
    this.errorMessage,
  });

  const HelpSupportSettingsState.initial()
      : this(status: HelpSupportSettingsStatus.initial);

  HelpSupportSettingsState copyWith({
    HelpSupportSettingsStatus? status,
    List<Map<String, String>>? faqs,
    List<Map<String, dynamic>>? supportTickets,
    String? appVersion,
    String? errorMessage,
  }) {
    return HelpSupportSettingsState(
      status: status ?? this.status,
      faqs: faqs ?? this.faqs,
      supportTickets: supportTickets ?? this.supportTickets,
      appVersion: appVersion ?? this.appVersion,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    faqs,
    supportTickets,
    appVersion,
    errorMessage,
  ];
}
