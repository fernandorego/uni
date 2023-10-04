import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uni/controller/background_workers/notifications.dart';
import 'package:uni/controller/load_static/terms_and_conditions.dart';
import 'package:uni/controller/local_storage/app_shared_preferences.dart';
import 'package:uni/controller/networking/network_router.dart';
import 'package:uni/controller/parsers/parser_session.dart';
import 'package:uni/model/entities/login_exceptions.dart';
import 'package:uni/model/entities/profile.dart';
import 'package:uni/model/entities/session.dart';
import 'package:uni/model/providers/state_provider_notifier.dart';
import 'package:uni/model/request_status.dart';
import 'package:uni/view/locale_notifier.dart';

class SessionProvider extends StateProviderNotifier {
  SessionProvider()
      : _session = Session(
          faculties: ['feup'],
          username: '',
          cookies: '',
        ),
        super(
          dependsOnSession: false,
          cacheDuration: null,
          initialStatus: RequestStatus.none,
        );

  Session _session;

  Session get session => _session;

  @override
  Future<void> loadFromStorage() async {
    final userPersistentInfo =
        await AppSharedPreferences.getPersistentUserInfo();

    if (userPersistentInfo == null) {
      return;
    }

    final userName = userPersistentInfo.item1;
    final password = userPersistentInfo.item2;

    final faculties = await AppSharedPreferences.getUserFaculties();

    restoreSession(userName, password, faculties);
  }

  @override
  Future<void> loadFromRemote(Session session, Profile profile) async {}

  void restoreSession(
    String username,
    String password,
    List<String> faculties,
  ) {
    _session = Session(
      faculties: faculties,
      username: username,
      cookies: '',
      persistentSession: true,
    );
  }

  Future<void> postAuthentication(
    BuildContext context,
    String username,
    String password,
    List<String> faculties, {
    required bool persistentSession,
  }) async {
    Session? session;
    try {
      session = await NetworkRouter.login(
        username,
        password,
        faculties,
        persistentSession: persistentSession,
      );
    } catch (e) {
      throw InternetStatusException(
        Provider.of<LocaleNotifier>(context, listen: false).getLocale(),
      );
    }

    if (session == null) {
      final responseHtml =
          await NetworkRouter.loginInSigarra(username, password, faculties);

      if (isPasswordExpired(responseHtml) && context.mounted) {
        throw ExpiredCredentialsException();
      } else {
        throw WrongCredentialsException(
          Provider.of<LocaleNotifier>(context, listen: false).getLocale(),
        );
      }
    }

    _session = session;

    if (persistentSession) {
      await AppSharedPreferences.savePersistentUserInfo(
        session.username,
        password,
        faculties,
      );
    }

    Future.delayed(
      const Duration(seconds: 20),
      () => {NotificationManager().initializeNotifications()},
    );

    await acceptTermsAndConditions();
  }
}