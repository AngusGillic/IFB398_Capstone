
## Structure

```text
IFB398_Capstone/
├── android/              Android app wrapper and Gradle configuration
├── assets/
│   └── gtfs/
│       └── routes.txt
├── backend/              Python pets service, deployment template, and tests
├── ios/                  iOS app wrapper and Xcode project
├── lib/                  Flutter application source
│   ├── core/
│   │   ├── pet_data.dart
│   │   └── user_data_session.dart
│   ├── data/
│   │   ├── pet_data.dart
│   │   ├── user_data.dart
│   │   └── user_db.dart
│   ├── main.dart
│   ├── models/
│   │   ├── CohortMembership.dart
│   │   ├── EcoGroup.dart
│   │   ├── GroupActivity.dart
│   │   ├── GroupActivityRsvp.dart
│   │   ├── GroupChallenge.dart
│   │   ├── GroupChallengeParticipation.dart
│   │   ├── GroupFeedItem.dart
│   │   ├── GroupKudos.dart
│   │   ├── GroupMembership.dart
│   │   ├── GroupScoreSnapshot.dart
│   │   ├── ModelProvider.dart
│   │   ├── User.dart
│   │   ├── garden_catalogue.dart
│   │   ├── gtfs_route.dart
│   │   ├── pet.dart
│   │   ├── pet_state.dart
│   │   └── pet_trip.dart
│   ├── screens/
│   │   ├── activities_page.dart
│   │   ├── appearance_page.dart
│   │   ├── bus_routes_screen.dart
│   │   ├── home_page.dart
│   │   ├── impact_page.dart
│   │   ├── login_page.dart
│   │   ├── map_page.dart
│   │   ├── past_journeys_page.dart
│   │   ├── pet_home_page.dart
│   │   ├── pet_profile_page.dart
│   │   ├── pet_selection_page.dart
│   │   ├── privacy_settings_page.dart
│   │   ├── route_options_page.dart
│   │   ├── saved_co2_page.dart
│   │   ├── settings_page.dart
│   │   ├── signup_page.dart
│   │   ├── steps_page.dart
│   │   ├── transportation_stats_page.dart
│   │   ├── trip_active_page.dart
│   │   ├── verify_email_page.dart
│   │   ├── weekly_stats_page.dart
│   │   └── welcome_page.dart
│   ├── services/
│   │   ├── api_client.dart
│   │   ├── geo_service.dart
│   │   ├── gtfs_service.dart
│   │   ├── local_pet_store.dart
│   │   ├── maps_config.dart
│   │   ├── pet_api.dart
│   │   ├── pet_repository.dart
│   │   └── username_mapper.dart
│   ├── theme/
│   │   └── app_colors.dart
│   ├── ui/
│   │   ├── app_theme.dart
│   │   ├── entrance.dart
│   │   ├── glass.dart
│   │   └── glass_widgets.dart
│   └── widgets/
│       ├── app_bottom_nav.dart
│       ├── app_scaffold.dart
│       ├── card_panels.dart
│       ├── charts.dart
│       ├── mock_painters.dart
│       ├── pet_avatar.dart
│       ├── pet_data_view.dart
│       └── phone_notch.dart
├── linux/                Linux app wrapper
├── macos/                macOS app wrapper
├── test/                 Flutter tests and shared fixtures
├── web/                  Web app entry point and manifest
├── windows/              Windows app wrapper
├── BACKEND.md
├── PETS_BACKEND.md
├── README.md
├── analysis_options.yaml
├── pubspec.yaml          Flutter dependencies and asset configuration
└── pubspec.lock
```

## Placeholder assets

Search for:

```text
PLACEHOLDER_ASSET
```

These are intentionally clear so my team can replace them with exported Figma images later.

## Run (Windows)

```bash
flutter create .
flutter pub get
flutter run -d windows
```
