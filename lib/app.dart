import 'package:flutter/material.dart';
import 'package:user_repository/user_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voyant/app_view.dart';
import 'package:voyant/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:voyant/blocs/avatar_bloc/avatar_bloc.dart';
import 'package:voyant/blocs/account_settings_bloc/account_settings_bloc.dart';
import 'package:voyant/blocs/notification_settings_bloc/notification_settings_bloc.dart';
import 'package:voyant/blocs/privacy_security_settings_bloc/privacy_security_settings_bloc.dart';
import 'package:voyant/blocs/help_support_settings_bloc/help_support_settings_bloc.dart';
import 'package:voyant/blocs/about_settings_bloc/about_settings_bloc.dart';

class MyApp extends StatelessWidget {
  final UserRepository userRepository;
  const MyApp (this.userRepository, {super.key});

  @override
  Widget build(BuildContext context) {
    // Create AvatarRepository instance using Firestore
    final avatarRepository = FirestoreAvatarRepository();

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<UserRepository>(
          create: (context) => userRepository,
        ),
        RepositoryProvider<AvatarRepository>(
          create: (context) => avatarRepository,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthenticationBloc>(
            create: (context) => AuthenticationBloc(
              userRepository: userRepository,
            ),
          ),
          BlocProvider<AvatarBloc>(
            create: (context) => AvatarBloc(
              avatarRepository: avatarRepository,
              userRepository: userRepository,
            ),
          ),
          BlocProvider<AccountSettingsBloc>(
            create: (context) => AccountSettingsBloc(
              userRepository: userRepository,
            ),
          ),
          BlocProvider<NotificationSettingsBloc>(
            create: (context) => NotificationSettingsBloc(
              userRepository: userRepository,
            ),
          ),
          BlocProvider<PrivacySecuritySettingsBloc>(
            create: (context) => PrivacySecuritySettingsBloc(
              userRepository: userRepository,
            ),
          ),
          BlocProvider<HelpSupportSettingsBloc>(
            create: (context) => HelpSupportSettingsBloc(
              userRepository: userRepository,
            ),
          ),
          BlocProvider<AboutSettingsBloc>(
            create: (context) => AboutSettingsBloc(
              userRepository: userRepository,
            ),
          ),
        ],
        child: const MyAppView(),
      ),
    );
  }

}