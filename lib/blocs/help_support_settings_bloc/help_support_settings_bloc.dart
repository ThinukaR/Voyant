import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:user_repository/user_repository.dart';

part 'help_support_settings_event.dart';
part 'help_support_settings_state.dart';

class HelpSupportSettingsBloc extends Bloc<HelpSupportSettingsEvent, HelpSupportSettingsState> {
  final UserRepository userRepository;

  HelpSupportSettingsBloc({
    required this.userRepository,
  }) : super(const HelpSupportSettingsState.initial()) {
    on<LoadHelpSupportSettingsEvent>(_onLoadSettings);
    on<SubmitSupportTicketEvent>(_onSubmitSupportTicket);
    on<SubmitBugReportEvent>(_onSubmitBugReport);
    on<SubmitFeedbackEvent>(_onSubmitFeedback);
    on<SubmitAppRatingEvent>(_onSubmitAppRating);
    on<UpdateHelpContentEvent>(_onUpdateHelpContent);
  }

  Future<void> _onLoadSettings(
      LoadHelpSupportSettingsEvent event,
      Emitter<HelpSupportSettingsState> emit,
      ) async {
    emit(state.copyWith(status: HelpSupportSettingsStatus.loading));
    try {
      final data = await userRepository.getHelpSupportData();
      emit(state.copyWith(
        status: HelpSupportSettingsStatus.success,
        faqs: data['faqs'] ?? [],
        supportTickets: data['supportTickets'] ?? [],
        appVersion: data['appVersion'] ?? '1.0.0',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HelpSupportSettingsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onSubmitSupportTicket(
      SubmitSupportTicketEvent event,
      Emitter<HelpSupportSettingsState> emit,
      ) async {
    emit(state.copyWith(status: HelpSupportSettingsStatus.loading));
    try {
      await userRepository.submitSupportTicket(
        subject: event.subject,
        description: event.description,
      );
      emit(state.copyWith(status: HelpSupportSettingsStatus.ticketSubmitted));
    } catch (e) {
      emit(state.copyWith(
        status: HelpSupportSettingsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onSubmitBugReport(
      SubmitBugReportEvent event,
      Emitter<HelpSupportSettingsState> emit,
      ) async {
    emit(state.copyWith(status: HelpSupportSettingsStatus.loading));
    try {
      await userRepository.submitBugReport(
        description: event.description,
      );
      emit(state.copyWith(status: HelpSupportSettingsStatus.bugReportSubmitted));
    } catch (e) {
      emit(state.copyWith(
        status: HelpSupportSettingsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onSubmitFeedback(
      SubmitFeedbackEvent event,
      Emitter<HelpSupportSettingsState> emit,
      ) async {
    emit(state.copyWith(status: HelpSupportSettingsStatus.loading));
    try {
      await userRepository.submitFeedback(
        feedback: event.feedback,
      );
      emit(state.copyWith(status: HelpSupportSettingsStatus.feedbackSubmitted));
    } catch (e) {
      emit(state.copyWith(
        status: HelpSupportSettingsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onSubmitAppRating(
      SubmitAppRatingEvent event,
      Emitter<HelpSupportSettingsState> emit,
      ) async {
    emit(state.copyWith(status: HelpSupportSettingsStatus.loading));
    try {
      await userRepository.submitAppRating(
        rating: event.rating,
      );
      emit(state.copyWith(status: HelpSupportSettingsStatus.ratingSubmitted));
    } catch (e) {
      emit(state.copyWith(
        status: HelpSupportSettingsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateHelpContent(
      UpdateHelpContentEvent event,
      Emitter<HelpSupportSettingsState> emit,
      ) async {
    try {
      emit(state.copyWith(
        faqs: event.faqs ?? state.faqs,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HelpSupportSettingsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
