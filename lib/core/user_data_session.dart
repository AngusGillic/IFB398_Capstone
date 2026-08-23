import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/foundation.dart';

// import '../gamification/badge_service.dart';
// import '../gamification/challenge_service.dart';
// import '../gamification/cohort_service.dart';
// import '../gamification/datastore_sync.dart';
// import '../gamification/group_challenge_service.dart';
// import '../gamification/group_service.dart';
// import '../gamification/group_social_service.dart';
// import '../gamification/points_service.dart';
// import '../database/local_trip_db.dart';
// import '../study/study_assignment_service.dart';
// import 'user_local_scope.dart';

/// Coordinates binding Cognito identity to local personal data and
/// wiping in-memory / DataStore state when the account changes.
class UserDataSession {
  UserDataSession._();

  static String? _boundUserId;
  static bool _binding = false;

  /// Call after Cognito session is confirmed (login / SessionGate).
  static Future<void> onAuthenticated() async {
    if (_binding) return;
    _binding = true;
    try {
      final sub = await _resolveCognitoSub();

      // For Debugging only:
      // final currentUser = await Amplify.Auth.getCurrentUser();
      // safePrint(currentUser);


      if (sub == null) {
        debugPrint('UserDataSession.onAuthenticated: no Cognito sub');
        return;
      }
      // await _applyUser(sub, signedIn: true);
      // await StudyAssignmentService.instance.ensureEnrolled();
    } finally {
      _binding = false;
    }
  }

  /// Call on logout before navigating to login.
  static Future<void> onSignedOut() async {
    if (_binding) return;
    _binding = true;
    try {
      // await _resetInMemoryServices();
      // StudyAssignmentService.instance.resetForUserSwitch();
      // await _clearDataStoreLocal();
      // await LocalTripDb().closeForUserSwitch();
      // await UserLocalScope.bindUser(null);
      _boundUserId = null;
      debugPrint('UserDataSession: signed out — local personal scope cleared');
    } finally {
      _binding = false;
    }
  }

  // static Future<void> _applyUser(String userId, {required bool signedIn}) async {
  //   final result = await UserLocalScope.bindUser(userId);
  //   // Only treat as account switch when Cognito identity actually changed
  //   // (or process memory was bound to a different user). Cold start same user
  //   // must NOT wipe DataStore.
  //   final processSwitch =
  //       _boundUserId != null && _boundUserId != userId;
  //   final accountSwitch = result.changed || processSwitch;

  //   await LocalTripDb().switchUser(userId);

  //   // Reinstall / clear-data: prefs active-user key is gone so bindUser reports
  //   // changed=true even though Cognito sub is the same. Only wipe DataStore
  //   // when we actually switch between two known Cognito identities — wiping on
  //   // every fresh install races with cloud rehydrate and is unnecessary
  //   // (local DS is already empty after reinstall).
  //   final realAccountSwitch = processSwitch ||
  //       (result.changed &&
  //           result.previousUserId != null &&
  //           result.previousUserId != 'anon_local' &&
  //           result.previousUserId != userId);

  //   if (realAccountSwitch) {
  //     debugPrint(
  //       'UserDataSession: account switch → isolate personal data '
  //       '(${userId.substring(0, 8)}…)',
  //     );
  //     // Previous user's cloud replica must not stay on device.
  //     await _clearDataStoreLocal();
  //     await _resetInMemoryServices();
  //     if (signedIn) {
  //       await _reloadAllForCurrentUser();
  //       try {
  //         await Amplify.DataStore.start();
  //       } catch (e) {
  //         debugPrint('UserDataSession DataStore.start: $e');
  //       }
  //     }
  //   } else {
  //     // Same user: cold start, reboot, or reinstall + same Cognito sub.
  //     if (result.changed) {
  //       debugPrint(
  //         'UserDataSession: first bind / reinstall for '
  //         '${userId.substring(0, 8)}… — load + cloud restore (no DS wipe)',
  //       );
  //     }
  //     await _reloadAllForCurrentUser();
  //     try {
  //       await Amplify.DataStore.start();
  //     } catch (e) {
  //       debugPrint('UserDataSession DataStore.start: $e');
  //     }
  //   }
  //   _boundUserId = userId;
  // }

  static Future<String?> _resolveCognitoSub() async {
    try {
      final session = await Amplify.Auth.fetchAuthSession();
      if (!session.isSignedIn) return null;
      final attrs = await Amplify.Auth.fetchUserAttributes();
      safePrint(attrs);
      for (final a in attrs) {
        if (a.userAttributeKey == CognitoUserAttributeKey.sub) {
          return a.value;
        }
      }
    } catch (e) {
      debugPrint('UserDataSession resolve sub: $e');
    }
    return null;
  }

  // static Future<void> _clearDataStoreLocal() async {
  //   if (!Amplify.isConfigured) return;
  //   try {
  //     DataStoreSync.resetReadyFlag();
  //     await Amplify.DataStore.clear();
  //     debugPrint('UserDataSession: DataStore.clear() for account isolation');
  //   } catch (e) {
  //     debugPrint('UserDataSession DataStore.clear: $e');
  //   }
  // }

  // static Future<void> _resetInMemoryServices() async {
  //   PointsService.instance.resetForUserSwitch();
  //   BadgeService.instance.resetForUserSwitch();
  //   ChallengeService.instance.resetForUserSwitch();
  //   GroupService.instance.resetForUserSwitch();
  //   try {
  //     CohortService.instance.resetForUserSwitch();
  //   } catch (_) {}
  //   try {
  //     GroupChallengeService.instance.resetForUserSwitch();
  //   } catch (_) {}
  //   try {
  //     GroupSocialService.instance.resetForUserSwitch();
  //   } catch (_) {}
  // }

  // static Future<void> _reloadAllForCurrentUser() async {
  //   // Order matters for reinstall: restore cloud profile BEFORE inventing
  //   // Traveller #### / leaving points at 0. PointsService.load seeds prefs
  //   // (empty after reinstall); restore overwrites from AppSync.
  //   await PointsService.instance.load(force: true);
  //   await BadgeService.instance.load(force: true);
  //   await ChallengeService.instance.load(force: true);
  //   await GroupService.instance.load(force: true);

  //   // Retry restore: first GraphQL after cold start can race Cognito session.
  //   for (var attempt = 1; attempt <= 3; attempt++) {
  //     try {
  //       await GroupService.instance.restoreDurableProfileFromCloud();
  //       final pts = PointsService.instance.totalPoints;
  //       final name = GroupService.instance.displayName;
  //       final autoName = name == 'You' ||
  //           name == 'Traveller' ||
  //           RegExp(r'^Traveller [0-9A-F]{4}$', caseSensitive: false)
  //               .hasMatch(name);
  //       debugPrint(
  //         'UserDataSession restore attempt $attempt: pts=$pts name="$name"',
  //       );
  //       if (pts > 0 || !autoName) break;
  //       if (attempt < 3) {
  //         await Future<void>.delayed(Duration(milliseconds: 400 * attempt));
  //       }
  //     } catch (e) {
  //       debugPrint('UserDataSession durable profile restore $attempt: $e');
  //       if (attempt < 3) {
  //         await Future<void>.delayed(Duration(milliseconds: 400 * attempt));
  //       }
  //     }
  //   }

  //   // Push only after restore so we never write local 0 over cloud totals.
  //   try {
  //     await GroupService.instance.syncDurableProfileToCloud();
  //   } catch (e) {
  //     debugPrint('UserDataSession durable profile sync: $e');
  //   }
  //   try {
  //     await CohortService.instance.load(force: true);
  //   } catch (_) {}
  //   try {
  //     await GroupChallengeService.instance.load(force: true);
  //   } catch (_) {}
  //   try {
  //     await GroupSocialService.instance.load(force: true);
  //   } catch (_) {}
  // }
}
