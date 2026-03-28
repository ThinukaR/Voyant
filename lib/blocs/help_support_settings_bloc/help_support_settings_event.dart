part of 'help_support_settings_bloc.dart';

abstract class HelpSupportSettingsEvent extends Equatable {
  const HelpSupportSettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadHelpSupportSettingsEvent extends HelpSupportSettingsEvent {
  const LoadHelpSupportSettingsEvent();
}

class SubmitSupportTicketEvent extends HelpSupportSettingsEvent {
  final String subject;
  final String description;

  const SubmitSupportTicketEvent({
    required this.subject,
    required this.description,
  });

  @override
  List<Object?> get props => [subject, description];
}

class SubmitBugReportEvent extends HelpSupportSettingsEvent {
  final String description;

  const SubmitBugReportEvent(this.description);

  @override
  List<Object?> get props => [description];
}

class SubmitFeedbackEvent extends HelpSupportSettingsEvent {
  final String feedback;

  const SubmitFeedbackEvent(this.feedback);

  @override
  List<Object?> get props => [feedback];
}

class SubmitAppRatingEvent extends HelpSupportSettingsEvent {
  final int rating;

  const SubmitAppRatingEvent(this.rating);

  @override
  List<Object?> get props => [rating];
}

class UpdateHelpContentEvent extends HelpSupportSettingsEvent {
  final List<Map<String, String>>? faqs;

  const UpdateHelpContentEvent({this.faqs});

  @override
  List<Object?> get props => [faqs];
}
