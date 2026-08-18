import 'package:flutter/foundation.dart';

// ===========================================================================
//  EVERY USER STAT IN THE APP LIVES IN THIS FILE.
//
//  Nothing else hard-codes a number. To connect the backend:
//    1. Fill in AppData.load() below.
//    2. Delete the _mock values at the bottom.
//  Screens listen to AppData.instance, so they refresh on their own.
// ===========================================================================

class UserProfile {
  const UserProfile({
    required this.firstName,
    required this.fullName,
    required this.email,
    required this.memberSince,
  });

  final String firstName;
  final String fullName;
  final String email;
  final DateTime memberSince;

  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return (parts.first[0] + parts.last[0]).toUpperCase();
    }
    return parts.first.isEmpty ? '?' : parts.first[0].toUpperCase();
  }
}

enum ImpactRange { week, month, year }

extension ImpactRangeLabel on ImpactRange {
  String get label => switch (this) {
        ImpactRange.week => 'Week',
        ImpactRange.month => 'Month',
        ImpactRange.year => 'Year',
      };

  String get periodNoun => switch (this) {
        ImpactRange.week => 'week',
        ImpactRange.month => 'month',
        ImpactRange.year => 'year',
      };
}

/// One period of travel. Missing figures default to zero so the charts can
/// render an empty state rather than throw.
class ImpactSeries {
  const ImpactSeries({
    this.co2SavedKg = 0,
    this.goalKg = 0,
    this.values = const [],
    this.labels = const [],
    this.byMode = const {},
    this.greenKm = 0,
    this.drivenKm = 0,
    this.changeVsPrevious = 0,
    this.trips = 0,
  });

  /// CO2 avoided over the period, in kilograms.
  final double co2SavedKg;

  /// Target for the period, in kilograms. Zero means no goal set.
  final double goalKg;

  /// One bar per column. Must be the same length as [labels].
  final List<double> values;

  /// Axis labels, for example M T W T F S S.
  final List<String> labels;

  /// Saving attributed to each transport mode.
  final Map<String, double> byMode;

  final double greenKm;
  final double drivenKm;

  /// Change against the previous period, as a fraction. 0.38 means 38% more.
  final double changeVsPrevious;

  final int trips;

  static const empty = ImpactSeries();

  bool get hasData => co2SavedKg > 0 || trips > 0 || values.any((v) => v > 0);

  double get totalKm => greenKm + drivenKm;
  double get greenShare => totalKm <= 0 ? 0 : greenKm / totalKm;

  double get goalProgress => goalKg <= 0 ? 0 : (co2SavedKg / goalKg).clamp(0.0, 2.0);

  /// Target per column, for the dashed goal line.
  double? get goalPerColumn {
    if (goalKg <= 0 || values.isEmpty) return null;
    return goalKg / values.length;
  }

  /// A mature tree absorbs roughly 21 kg of CO2 a year.
  double get treeDays => co2SavedKg / 0.0575;

  /// An average petrol car emits about 0.17 kg per km.
  double get kmNotDriven => co2SavedKg / 0.17;

  /// Bounds-checked column access.
  double valueAt(int index) =>
      index >= 0 && index < values.length ? values[index] : 0;

  String labelAt(int index) =>
      index >= 0 && index < labels.length ? labels[index] : '';
}

/// Running totals since the account was created.
class LifetimeImpact {
  const LifetimeImpact({
    required this.co2SavedKg,
    required this.totalTrips,
    required this.totalKm,
  });

  /// Drives pet unlocks. See PetCatalogue.unlockCo2Kg.
  final double co2SavedKg;

  final int totalTrips;
  final double totalKm;
}

class PetStats {
  const PetStats({
    required this.coins,
    required this.happiness,
    required this.energy,
    required this.health,
    required this.daysTogether,
  });

  final int coins;

  /// All three are 0.0 to 1.0.
  final double happiness;
  final double energy;
  final double health;

  final int daysTogether;
}

/// A route offered on the home screen.
class SuggestedTrip {
  const SuggestedTrip({
    required this.label,
    required this.mode,
    required this.durationMinutes,
    required this.co2SavedKg,
    required this.leaveAt,
    required this.arriveAt,
  });

  final String label;
  final String mode;
  final int durationMinutes;
  final double co2SavedKg;
  final String leaveAt;
  final String arriveAt;
}

class Challenge {
  const Challenge({
    required this.title,
    required this.daysDone,
    required this.daysTotal,
    required this.steps,
    required this.stepGoal,
  });

  final String title;
  final int daysDone;
  final int daysTotal;
  final int steps;
  final int stepGoal;

  double get progress => stepGoal <= 0 ? 0 : (steps / stepGoal).clamp(0.0, 1.0);
}

class UserData {
  const UserData({
    required this.profile,
    required this.impact,
    required this.lifetime,
    required this.pet,
    required this.suggestions,
    required this.challenge,
  });

  final UserProfile profile;

  /// Missing ranges fall back to [ImpactSeries.empty].
  final Map<ImpactRange, ImpactSeries> impact;

  final LifetimeImpact lifetime;
  final PetStats pet;
  final List<SuggestedTrip> suggestions;
  final Challenge challenge;

  ImpactSeries seriesFor(ImpactRange range) =>
      impact[range] ?? ImpactSeries.empty;

  ImpactSeries get week => seriesFor(ImpactRange.week);
}

/// Start with everything at zero:
/// flutter run --dart-define=EMPTY_DATA=true
const bool kEmptyData = bool.fromEnvironment('EMPTY_DATA');

/// Single source of truth. Wrap widgets in a ValueListenableBuilder to rebuild
/// when it changes.
class AppData extends ValueNotifier<UserData> {
  AppData._() : super(kEmptyData ? empty : _mock);

  static final AppData instance = AppData._();

  static UserData get current => instance.value;

  /// Everything at zero, for first launch and while loading.
  static final UserData empty = UserData(
    profile: UserProfile(
      firstName: 'there',
      fullName: '',
      email: '',
      memberSince: DateTime.now(),
    ),
    impact: const {},
    lifetime: const LifetimeImpact(co2SavedKg: 0, totalTrips: 0, totalKm: 0),
    pet: const PetStats(
      coins: 0,
      happiness: 0,
      energy: 0,
      health: 0,
      daysTogether: 0,
    ),
    suggestions: const [],
    challenge: const Challenge(
      title: 'No challenge yet',
      daysDone: 0,
      daysTotal: 0,
      steps: 0,
      stepGoal: 0,
    ),
  );

  /// Fetch the signed-in user's figures. See BACKEND.md.
  Future<void> load() async {
    // value = await ApiClient.fetchUserData();
  }

  void update(UserData data) => value = data;
}

// ---------------------------------------------------------------------------
//  MOCK VALUES — delete once load() is wired up.
// ---------------------------------------------------------------------------

final UserData _mock = UserData(
  profile: UserProfile(
    firstName: 'John',
    fullName: 'John Doe',
    email: 'john.doe@example.com',
    memberSince: DateTime(2026, 5, 2),
  ),
  impact: const {
    ImpactRange.week: ImpactSeries(
      co2SavedKg: 2.4,
      goalKg: 3.5,
      values: [0.2, 0.45, 0.3, 0.55, 0.4, 0.1, 0.5],
      labels: ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
      byMode: {'Transit': 1.8, 'Walking': 0.4, 'Cycling': 0.2},
      greenKm: 18.6,
      drivenKm: 4.2,
      changeVsPrevious: 0.38,
      trips: 10,
    ),
    ImpactRange.month: ImpactSeries(
      co2SavedKg: 9.8,
      goalKg: 14,
      values: [2.1, 2.4, 2.9, 2.4],
      labels: ['W1', 'W2', 'W3', 'W4'],
      byMode: {'Transit': 6.9, 'Walking': 1.9, 'Cycling': 1.0},
      greenKm: 74.2,
      drivenKm: 21.5,
      changeVsPrevious: 0.12,
      trips: 41,
    ),
    ImpactRange.year: ImpactSeries(
      co2SavedKg: 52,
      goalKg: 90,
      values: [3.1, 4.0, 4.8, 5.2, 4.4, 3.9, 4.6, 5.1, 4.2, 4.5, 4.0, 4.2],
      labels: ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'],
      byMode: {'Transit': 36.4, 'Walking': 9.8, 'Cycling': 5.8},
      greenKm: 331.0,
      drivenKm: 81.7,
      changeVsPrevious: 0.24,
      trips: 148,
    ),
  },
  lifetime: const LifetimeImpact(
    co2SavedKg: 52,
    totalTrips: 148,
    totalKm: 412.7,
  ),
  pet: const PetStats(
    coins: 200,
    happiness: 0.82,
    energy: 0.64,
    health: 0.95,
    daysTogether: 38,
  ),
  suggestions: const [
    SuggestedTrip(
      label: 'Work',
      mode: 'Bus 150',
      durationMinutes: 22,
      co2SavedKg: 0.8,
      leaveAt: '8:18am',
      arriveAt: '8:40am',
    ),
    SuggestedTrip(
      label: 'Gym',
      mode: 'Walk',
      durationMinutes: 14,
      co2SavedKg: 0.4,
      leaveAt: '5:30pm',
      arriveAt: '5:44pm',
    ),
    SuggestedTrip(
      label: 'Southbank',
      mode: 'Ferry',
      durationMinutes: 18,
      co2SavedKg: 0.6,
      leaveAt: '11:05am',
      arriveAt: '11:23am',
    ),
    SuggestedTrip(
      label: 'Home',
      mode: 'Bus 412',
      durationMinutes: 26,
      co2SavedKg: 0.9,
      leaveAt: '6:02pm',
      arriveAt: '6:28pm',
    ),
  ],
  challenge: const Challenge(
    title: 'Green Week Walk Challenge',
    daysDone: 4,
    daysTotal: 7,
    steps: 2000,
    stepGoal: 4000,
  ),
);
