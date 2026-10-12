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


/** This is an auto generated class representing the GroupScoreSnapshot type in your schema. */
class GroupScoreSnapshot extends amplify_core.Model {
  static const classType = const _GroupScoreSnapshotModelType();
  final String id;
  final String? _groupId;
  final String? _userId;
  final String? _displayName;
  final int? _totalPoints;
  final int? _weekPoints;
  final String? _weekKey;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  GroupScoreSnapshotModelIdentifier get modelIdentifier {
      return GroupScoreSnapshotModelIdentifier(
        id: id
      );
  }
  
  String get groupId {
    try {
      return _groupId!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get userId {
    try {
      return _userId!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get displayName {
    try {
      return _displayName!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  int get totalPoints {
    try {
      return _totalPoints!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  int get weekPoints {
    try {
      return _weekPoints!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String? get weekKey {
    return _weekKey;
  }
  
  amplify_core.TemporalDateTime? get createdAt {
    return _createdAt;
  }
  
  amplify_core.TemporalDateTime? get updatedAt {
    return _updatedAt;
  }
  
  const GroupScoreSnapshot._internal({required this.id, required groupId, required userId, required displayName, required totalPoints, required weekPoints, weekKey, createdAt, updatedAt}): _groupId = groupId, _userId = userId, _displayName = displayName, _totalPoints = totalPoints, _weekPoints = weekPoints, _weekKey = weekKey, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory GroupScoreSnapshot({String? id, required String groupId, required String userId, required String displayName, required int totalPoints, required int weekPoints, String? weekKey}) {
    return GroupScoreSnapshot._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      groupId: groupId,
      userId: userId,
      displayName: displayName,
      totalPoints: totalPoints,
      weekPoints: weekPoints,
      weekKey: weekKey);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GroupScoreSnapshot &&
      id == other.id &&
      _groupId == other._groupId &&
      _userId == other._userId &&
      _displayName == other._displayName &&
      _totalPoints == other._totalPoints &&
      _weekPoints == other._weekPoints &&
      _weekKey == other._weekKey;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("GroupScoreSnapshot {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("groupId=" + "$_groupId" + ", ");
    buffer.write("userId=" + "$_userId" + ", ");
    buffer.write("displayName=" + "$_displayName" + ", ");
    buffer.write("totalPoints=" + (_totalPoints != null ? _totalPoints!.toString() : "null") + ", ");
    buffer.write("weekPoints=" + (_weekPoints != null ? _weekPoints!.toString() : "null") + ", ");
    buffer.write("weekKey=" + "$_weekKey" + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  GroupScoreSnapshot copyWith({String? groupId, String? userId, String? displayName, int? totalPoints, int? weekPoints, String? weekKey}) {
    return GroupScoreSnapshot._internal(
      id: id,
      groupId: groupId ?? this.groupId,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      totalPoints: totalPoints ?? this.totalPoints,
      weekPoints: weekPoints ?? this.weekPoints,
      weekKey: weekKey ?? this.weekKey);
  }
  
  GroupScoreSnapshot copyWithModelFieldValues({
    ModelFieldValue<String>? groupId,
    ModelFieldValue<String>? userId,
    ModelFieldValue<String>? displayName,
    ModelFieldValue<int>? totalPoints,
    ModelFieldValue<int>? weekPoints,
    ModelFieldValue<String?>? weekKey
  }) {
    return GroupScoreSnapshot._internal(
      id: id,
      groupId: groupId == null ? this.groupId : groupId.value,
      userId: userId == null ? this.userId : userId.value,
      displayName: displayName == null ? this.displayName : displayName.value,
      totalPoints: totalPoints == null ? this.totalPoints : totalPoints.value,
      weekPoints: weekPoints == null ? this.weekPoints : weekPoints.value,
      weekKey: weekKey == null ? this.weekKey : weekKey.value
    );
  }
  
  GroupScoreSnapshot.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _groupId = json['groupId'],
      _userId = json['userId'],
      _displayName = json['displayName'],
      _totalPoints = (json['totalPoints'] as num?)?.toInt(),
      _weekPoints = (json['weekPoints'] as num?)?.toInt(),
      _weekKey = json['weekKey'],
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'groupId': _groupId, 'userId': _userId, 'displayName': _displayName, 'totalPoints': _totalPoints, 'weekPoints': _weekPoints, 'weekKey': _weekKey, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'groupId': _groupId,
    'userId': _userId,
    'displayName': _displayName,
    'totalPoints': _totalPoints,
    'weekPoints': _weekPoints,
    'weekKey': _weekKey,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<GroupScoreSnapshotModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<GroupScoreSnapshotModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final GROUPID = amplify_core.QueryField(fieldName: "groupId");
  static final USERID = amplify_core.QueryField(fieldName: "userId");
  static final DISPLAYNAME = amplify_core.QueryField(fieldName: "displayName");
  static final TOTALPOINTS = amplify_core.QueryField(fieldName: "totalPoints");
  static final WEEKPOINTS = amplify_core.QueryField(fieldName: "weekPoints");
  static final WEEKKEY = amplify_core.QueryField(fieldName: "weekKey");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "GroupScoreSnapshot";
    modelSchemaDefinition.pluralName = "GroupScoreSnapshots";
    
    modelSchemaDefinition.authRules = [
      amplify_core.AuthRule(
        authStrategy: amplify_core.AuthStrategy.PRIVATE,
        operations: const [
          amplify_core.ModelOperation.CREATE,
          amplify_core.ModelOperation.UPDATE,
          amplify_core.ModelOperation.DELETE,
          amplify_core.ModelOperation.READ
        ])
    ];
    
    modelSchemaDefinition.indexes = [
      amplify_core.ModelIndex(fields: const ["groupId"], name: "byGroupScores"),
      amplify_core.ModelIndex(fields: const ["userId"], name: "byUserScores")
    ];
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: GroupScoreSnapshot.GROUPID,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: GroupScoreSnapshot.USERID,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: GroupScoreSnapshot.DISPLAYNAME,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: GroupScoreSnapshot.TOTALPOINTS,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: GroupScoreSnapshot.WEEKPOINTS,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: GroupScoreSnapshot.WEEKKEY,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.nonQueryField(
      fieldName: 'createdAt',
      isRequired: false,
      isReadOnly: true,
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

class _GroupScoreSnapshotModelType extends amplify_core.ModelType<GroupScoreSnapshot> {
  const _GroupScoreSnapshotModelType();
  
  @override
  GroupScoreSnapshot fromJson(Map<String, dynamic> jsonData) {
    return GroupScoreSnapshot.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'GroupScoreSnapshot';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [GroupScoreSnapshot] in your schema.
 */
class GroupScoreSnapshotModelIdentifier implements amplify_core.ModelIdentifier<GroupScoreSnapshot> {
  final String id;

  /** Create an instance of GroupScoreSnapshotModelIdentifier using [id] the primary key. */
  const GroupScoreSnapshotModelIdentifier({
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
  String toString() => 'GroupScoreSnapshotModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is GroupScoreSnapshotModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}