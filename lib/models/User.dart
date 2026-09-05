/*
* Copyright 2021 Amazon.com, Inc. or its affiliates. All Rights Reserved.
*
* Licensed under the Apache License, Version 2.0 (the "License").
* You may not use this file except in compliance with the License.
* A copy of the License is located at
*
*  http://aws.amazon.com/apache2.0
*
* or in the "license" file accompanying this file. This file is distributed
* on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
* express or implied. See the License for the specific language governing
* permissions and limitations under the License.
*/

// NOTE: This file is generated and may not follow lint rules defined in your app
// Generated files can be excluded from analysis in analysis_options.yaml
// For more info, see: https://dart.dev/guides/language/analysis-options#excluding-code-from-analysis

// ignore_for_file: public_member_api_docs, annotate_overrides, dead_code, dead_codepublic_member_api_docs, depend_on_referenced_packages, file_names, library_private_types_in_public_api, no_leading_underscores_for_library_prefixes, no_leading_underscores_for_local_identifiers, non_constant_identifier_names, null_check_on_nullable_type_parameter, override_on_non_overriding_member, prefer_adjacent_string_concatenation, prefer_const_constructors, prefer_if_null_operators, prefer_interpolation_to_compose_strings, slash_for_doc_comments, sort_child_properties_last, unnecessary_const, unnecessary_constructor_name, unnecessary_late, unnecessary_new, unnecessary_null_aware_assignments, unnecessary_nullable_for_final_variable_declarations, unnecessary_string_interpolations, use_build_context_synchronously

import 'ModelProvider.dart';
import 'package:amplify_core/amplify_core.dart' as amplify_core;


/** This is an auto generated class representing the User type in your schema. */
class User extends amplify_core.Model {
  static const classType = const _UserModelType();
  final String id;
  final String? _ageBand;
  final String? _incomeBand;
  final int? _envConcern;
  final int? _privacyWorry;
  final int? _techEfficacy;
  final String? _vehicleType;
  final int? _arm;
  final int? _phase;
  final bool? _onboardingCompleted;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  UserModelIdentifier get modelIdentifier {
      return UserModelIdentifier(
        id: id
      );
  }
  
  String? get ageBand {
    return _ageBand;
  }
  
  String? get incomeBand {
    return _incomeBand;
  }
  
  int? get envConcern {
    return _envConcern;
  }
  
  int? get privacyWorry {
    return _privacyWorry;
  }
  
  int? get techEfficacy {
    return _techEfficacy;
  }
  
  String? get vehicleType {
    return _vehicleType;
  }
  
  int? get arm {
    return _arm;
  }
  
  int? get phase {
    return _phase;
  }
  
  bool? get onboardingCompleted {
    return _onboardingCompleted;
  }
  
  amplify_core.TemporalDateTime? get createdAt {
    return _createdAt;
  }
  
  amplify_core.TemporalDateTime? get updatedAt {
    return _updatedAt;
  }
  
  const User._internal({required this.id, ageBand, incomeBand, envConcern, privacyWorry, techEfficacy, vehicleType, arm, phase, onboardingCompleted, createdAt, updatedAt}): _ageBand = ageBand, _incomeBand = incomeBand, _envConcern = envConcern, _privacyWorry = privacyWorry, _techEfficacy = techEfficacy, _vehicleType = vehicleType, _arm = arm, _phase = phase, _onboardingCompleted = onboardingCompleted, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory User({String? id, String? ageBand, String? incomeBand, int? envConcern, int? privacyWorry, int? techEfficacy, String? vehicleType, int? arm, int? phase, bool? onboardingCompleted, amplify_core.TemporalDateTime? createdAt}) {
    return User._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      ageBand: ageBand,
      incomeBand: incomeBand,
      envConcern: envConcern,
      privacyWorry: privacyWorry,
      techEfficacy: techEfficacy,
      vehicleType: vehicleType,
      arm: arm,
      phase: phase,
      onboardingCompleted: onboardingCompleted,
      createdAt: createdAt);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is User &&
      id == other.id &&
      _ageBand == other._ageBand &&
      _incomeBand == other._incomeBand &&
      _envConcern == other._envConcern &&
      _privacyWorry == other._privacyWorry &&
      _techEfficacy == other._techEfficacy &&
      _vehicleType == other._vehicleType &&
      _arm == other._arm &&
      _phase == other._phase &&
      _onboardingCompleted == other._onboardingCompleted &&
      _createdAt == other._createdAt;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("User {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("ageBand=" + "$_ageBand" + ", ");
    buffer.write("incomeBand=" + "$_incomeBand" + ", ");
    buffer.write("envConcern=" + (_envConcern != null ? _envConcern!.toString() : "null") + ", ");
    buffer.write("privacyWorry=" + (_privacyWorry != null ? _privacyWorry!.toString() : "null") + ", ");
    buffer.write("techEfficacy=" + (_techEfficacy != null ? _techEfficacy!.toString() : "null") + ", ");
    buffer.write("vehicleType=" + "$_vehicleType" + ", ");
    buffer.write("arm=" + (_arm != null ? _arm!.toString() : "null") + ", ");
    buffer.write("phase=" + (_phase != null ? _phase!.toString() : "null") + ", ");
    buffer.write("onboardingCompleted=" + (_onboardingCompleted != null ? _onboardingCompleted!.toString() : "null") + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  User copyWith({String? ageBand, String? incomeBand, int? envConcern, int? privacyWorry, int? techEfficacy, String? vehicleType, int? arm, int? phase, bool? onboardingCompleted, amplify_core.TemporalDateTime? createdAt}) {
    return User._internal(
      id: id,
      ageBand: ageBand ?? this.ageBand,
      incomeBand: incomeBand ?? this.incomeBand,
      envConcern: envConcern ?? this.envConcern,
      privacyWorry: privacyWorry ?? this.privacyWorry,
      techEfficacy: techEfficacy ?? this.techEfficacy,
      vehicleType: vehicleType ?? this.vehicleType,
      arm: arm ?? this.arm,
      phase: phase ?? this.phase,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      createdAt: createdAt ?? this.createdAt);
  }
  
  User copyWithModelFieldValues({
    ModelFieldValue<String?>? ageBand,
    ModelFieldValue<String?>? incomeBand,
    ModelFieldValue<int?>? envConcern,
    ModelFieldValue<int?>? privacyWorry,
    ModelFieldValue<int?>? techEfficacy,
    ModelFieldValue<String?>? vehicleType,
    ModelFieldValue<int?>? arm,
    ModelFieldValue<int?>? phase,
    ModelFieldValue<bool?>? onboardingCompleted,
    ModelFieldValue<amplify_core.TemporalDateTime?>? createdAt
  }) {
    return User._internal(
      id: id,
      ageBand: ageBand == null ? this.ageBand : ageBand.value,
      incomeBand: incomeBand == null ? this.incomeBand : incomeBand.value,
      envConcern: envConcern == null ? this.envConcern : envConcern.value,
      privacyWorry: privacyWorry == null ? this.privacyWorry : privacyWorry.value,
      techEfficacy: techEfficacy == null ? this.techEfficacy : techEfficacy.value,
      vehicleType: vehicleType == null ? this.vehicleType : vehicleType.value,
      arm: arm == null ? this.arm : arm.value,
      phase: phase == null ? this.phase : phase.value,
      onboardingCompleted: onboardingCompleted == null ? this.onboardingCompleted : onboardingCompleted.value,
      createdAt: createdAt == null ? this.createdAt : createdAt.value
    );
  }
  
  User.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _ageBand = json['ageBand'],
      _incomeBand = json['incomeBand'],
      _envConcern = (json['envConcern'] as num?)?.toInt(),
      _privacyWorry = (json['privacyWorry'] as num?)?.toInt(),
      _techEfficacy = (json['techEfficacy'] as num?)?.toInt(),
      _vehicleType = json['vehicleType'],
      _arm = (json['arm'] as num?)?.toInt(),
      _phase = (json['phase'] as num?)?.toInt(),
      _onboardingCompleted = json['onboardingCompleted'],
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'ageBand': _ageBand, 'incomeBand': _incomeBand, 'envConcern': _envConcern, 'privacyWorry': _privacyWorry, 'techEfficacy': _techEfficacy, 'vehicleType': _vehicleType, 'arm': _arm, 'phase': _phase, 'onboardingCompleted': _onboardingCompleted, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'ageBand': _ageBand,
    'incomeBand': _incomeBand,
    'envConcern': _envConcern,
    'privacyWorry': _privacyWorry,
    'techEfficacy': _techEfficacy,
    'vehicleType': _vehicleType,
    'arm': _arm,
    'phase': _phase,
    'onboardingCompleted': _onboardingCompleted,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<UserModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<UserModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final AGEBAND = amplify_core.QueryField(fieldName: "ageBand");
  static final INCOMEBAND = amplify_core.QueryField(fieldName: "incomeBand");
  static final ENVCONCERN = amplify_core.QueryField(fieldName: "envConcern");
  static final PRIVACYWORRY = amplify_core.QueryField(fieldName: "privacyWorry");
  static final TECHEFFICACY = amplify_core.QueryField(fieldName: "techEfficacy");
  static final VEHICLETYPE = amplify_core.QueryField(fieldName: "vehicleType");
  static final ARM = amplify_core.QueryField(fieldName: "arm");
  static final PHASE = amplify_core.QueryField(fieldName: "phase");
  static final ONBOARDINGCOMPLETED = amplify_core.QueryField(fieldName: "onboardingCompleted");
  static final CREATEDAT = amplify_core.QueryField(fieldName: "createdAt");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "User";
    modelSchemaDefinition.pluralName = "Users";
    
    modelSchemaDefinition.authRules = [
      amplify_core.AuthRule(
        authStrategy: amplify_core.AuthStrategy.PRIVATE,
        operations: const [
          amplify_core.ModelOperation.CREATE,
          amplify_core.ModelOperation.READ,
          amplify_core.ModelOperation.UPDATE,
          amplify_core.ModelOperation.DELETE
        ])
    ];
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: User.AGEBAND,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: User.INCOMEBAND,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: User.ENVCONCERN,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: User.PRIVACYWORRY,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: User.TECHEFFICACY,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: User.VEHICLETYPE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: User.ARM,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: User.PHASE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: User.ONBOARDINGCOMPLETED,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.bool)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: User.CREATEDAT,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.nonQueryField(
      fieldName: 'updatedAt',
      isRequired: false,
      isReadOnly: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
  });
}

class _UserModelType extends amplify_core.ModelType<User> {
  const _UserModelType();
  
  @override
  User fromJson(Map<String, dynamic> jsonData) {
    return User.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'User';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [User] in your schema.
 */
class UserModelIdentifier implements amplify_core.ModelIdentifier<User> {
  final String id;

  /** Create an instance of UserModelIdentifier using [id] the primary key. */
  const UserModelIdentifier({
    required this.id});
  
  @override
  Map<String, dynamic> serializeAsMap() => (<String, dynamic>{
    'id': id
  });
  
  @override
  List<Map<String, dynamic>> serializeAsList() => serializeAsMap()
    .entries
    .map((entry) => (<String, dynamic>{ entry.key: entry.value }))
    .toList();
  
  @override
  String serializeAsString() => serializeAsMap().values.join('#');
  
  @override
  String toString() => 'UserModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is UserModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}