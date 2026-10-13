import 'dart:async';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/foundation.dart';

import '../data/user_data.dart';
import '../models/pet.dart';
import 'pet_data.dart';

class UserDataSession {
  UserDataSession._();

  static String? _boundUserId;
  static bool _binding = false;
  static int _authSession = 0;

  /// Call after Cognito session is confirmed (login / SessionGate).
  static Future<void> onAuthenticated() async {
    if (_binding) return;
    _binding = true;
    final session = _authSession;
    try {
      final sub = await _resolveCognitoSub();
      if (session != _authSession) return;
      if (sub == null) {
        await onSignedOut();
        debugPrint('UserDataSession.onAuthenticated: no Cognito sub');
        return;
      }
      if (_boundUserId != sub) {
        AppData.instance.reset();
        PetController.instance.select(PetCatalogue.all.first.id);
        _boundUserId = sub;
      }
      PetData.instance.bindUser(sub);
      unawaited(PetData.instance.load());
    } finally {
      _binding = false;
    }
  }

  /// Call on logout before navigating to login.
  static Future<void> onSignedOut() async {
    _authSession++;
    _boundUserId = null;
    PetData.instance.bindUser(null);
    AppData.instance.reset();
    PetController.instance.select(PetCatalogue.all.first.id);
  }

  static Future<String?> _resolveCognitoSub() async {
    try {
      final session = await Amplify.Auth.fetchAuthSession();
      if (!session.isSignedIn) return null;
      final attrs = await Amplify.Auth.fetchUserAttributes();
      for (final a in attrs) {
        if (a.userAttributeKey == CognitoUserAttributeKey.sub) {
          return a.value;
        }
      }
      final current = await Amplify.Auth.getCurrentUser();
      return current.userId;
    } catch (e) {
      debugPrint('UserDataSession resolve sub: $e');
    }
    return null;
  }
}
