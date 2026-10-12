/*
* Copyright 2021 Amazon.com, Inc. or its affiliates. All Rights Reserved.
*
* Licensed under the Apache License, Version 2.0 (the "License").
*/

// ignore_for_file: public_member_api_docs, annotate_overrides, prefer_const_constructors

import 'package:amplify_core/amplify_core.dart' as amplify_core;
import 'User.dart';
import 'EcoGroup.dart';
import 'GroupMembership.dart';
import 'GroupScoreSnapshot.dart';
import 'GroupChallenge.dart';
import 'GroupChallengeParticipation.dart';
import 'GroupFeedItem.dart';
import 'GroupActivity.dart';
import 'GroupActivityRsvp.dart';
import 'GroupKudos.dart';
import 'CohortMembership.dart';

export 'User.dart';
export 'EcoGroup.dart';
export 'GroupMembership.dart';
export 'GroupScoreSnapshot.dart';
export 'GroupChallenge.dart';
export 'GroupChallengeParticipation.dart';
export 'GroupFeedItem.dart';
export 'GroupActivity.dart';
export 'GroupActivityRsvp.dart';
export 'GroupKudos.dart';
export 'CohortMembership.dart';

/// Provider for Amplify models, managing schemas and model types.
class ModelProvider implements amplify_core.ModelProviderInterface {
  @override
  String version = "phase3-4-social-v1";
  @override
  List<amplify_core.ModelSchema> modelSchemas = [
    User.schema,
    EcoGroup.schema,
    GroupMembership.schema,
    GroupScoreSnapshot.schema,
    GroupChallenge.schema,
    GroupChallengeParticipation.schema,
    GroupFeedItem.schema,
    GroupActivity.schema,
    GroupActivityRsvp.schema,
    GroupKudos.schema,
    CohortMembership.schema,
  ];
  
  @override
  List<amplify_core.ModelSchema> customTypeSchemas = [];
  static final ModelProvider _instance = ModelProvider();

  static ModelProvider get instance => _instance;

  amplify_core.ModelType getModelTypeByModelName(String modelName) {
    switch (modelName) {
      case "User":
        return User.classType;
      case "EcoGroup":
        return EcoGroup.classType;
      case "GroupMembership":
        return GroupMembership.classType;
      case "GroupScoreSnapshot":
        return GroupScoreSnapshot.classType;
      case "GroupChallenge":
        return GroupChallenge.classType;
      case "GroupChallengeParticipation":
        return GroupChallengeParticipation.classType;
      case "GroupFeedItem":
        return GroupFeedItem.classType;
      case "GroupActivity":
        return GroupActivity.classType;
      case "GroupActivityRsvp":
        return GroupActivityRsvp.classType;
      case "GroupKudos":
        return GroupKudos.classType;
      case "CohortMembership":
        return CohortMembership.classType;
      default:
        throw Exception(
            "Failed to find model in model provider for model name: $modelName");
    }
  }
}

/// Wrapper for model field values.
class ModelFieldValue<T> {
  const ModelFieldValue.value(this.value);
  final T value;
}
