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


/** This is an auto generated class representing the GroupMembership type in your schema. */
class GroupMembership extends amplify_core.Model {
  static const classType = const _GroupMembershipModelType();
  final String id;
  final String? _groupId;
  final String? _userId;
  final String? _role;
  final String? _displayName;
  final String? _status;
  final amplify_core.TemporalDateTime? _joinedAt;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  GroupMembershipModelIdentifier get modelIdentifier {
      return GroupMembershipModelIdentifier(
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
  
  String get role {
    try {
      return _role!;
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
  
  String get status {
    try {
      return _status!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  amplify_core.TemporalDateTime? get joinedAt {
    return _joinedAt;
  }
  
  amplify_core.TemporalDateTime? get createdAt {
    return _createdAt;
  }
  
  amplify_core.TemporalDateTime? get updatedAt {
    return _updatedAt;
  }
  
  const GroupMembership._internal({required this.id, required groupId, required userId, required role, required displayName, required status, joinedAt, createdAt, updatedAt}): _groupId = groupId, _userId = userId, _role = role, _displayName = displayName, _status = status, _joinedAt = joinedAt, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory GroupMembership({String? id, required String groupId, required String userId, required String role, required String displayName, required String status, amplify_core.TemporalDateTime? joinedAt}) {
    return GroupMembership._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      groupId: groupId,
      userId: userId,
      role: role,
      displayName: displayName,
      status: status,
      joinedAt: joinedAt);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GroupMembership &&
      id == other.id &&
      _groupId == other._groupId &&
      _userId == other._userId &&
      _role == other._role &&
      _displayName == other._displayName &&
      _status == other._status &&
      _joinedAt == other._joinedAt;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("GroupMembership {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("groupId=" + "$_groupId" + ", ");
    buffer.write("userId=" + "$_userId" + ", ");
    buffer.write("role=" + "$_role" + ", ");
    buffer.write("displayName=" + "$_displayName" + ", ");
    buffer.write("status=" + "$_status" + ", ");
    buffer.write("joinedAt=" + (_joinedAt != null ? _joinedAt!.format() : "null") + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  GroupMembership copyWith({String? groupId, String? userId, String? role, String? displayName, String? status, amplify_core.TemporalDateTime? joinedAt}) {
    return GroupMembership._internal(
      id: id,
      groupId: groupId ?? this.groupId,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      displayName: displayName ?? this.displayName,
      status: status ?? this.status,
      joinedAt: joinedAt ?? this.joinedAt);
  }
  
  GroupMembership copyWithModelFieldValues({
    ModelFieldValue<String>? groupId,
    ModelFieldValue<String>? userId,
    ModelFieldValue<String>? role,
    ModelFieldValue<String>? displayName,
    ModelFieldValue<String>? status,
    ModelFieldValue<amplify_core.TemporalDateTime?>? joinedAt
  }) {
    return GroupMembership._internal(
      id: id,
      groupId: groupId == null ? this.groupId : groupId.value,
      userId: userId == null ? this.userId : userId.value,
      role: role == null ? this.role : role.value,
      displayName: displayName == null ? this.displayName : displayName.value,
      status: status == null ? this.status : status.value,
      joinedAt: joinedAt == null ? this.joinedAt : joinedAt.value
    );
  }
  
  GroupMembership.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _groupId = json['groupId'],
      _userId = json['userId'],
      _role = json['role'],
      _displayName = json['displayName'],
      _status = json['status'],
      _joinedAt = json['joinedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['joinedAt']) : null,
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'groupId': _groupId, 'userId': _userId, 'role': _role, 'displayName': _displayName, 'status': _status, 'joinedAt': _joinedAt?.format(), 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'groupId': _groupId,
    'userId': _userId,
    'role': _role,
    'displayName': _displayName,
    'status': _status,
    'joinedAt': _joinedAt,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<GroupMembershipModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<GroupMembershipModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final GROUPID = amplify_core.QueryField(fieldName: "groupId");
  static final USERID = amplify_core.QueryField(fieldName: "userId");
  static final ROLE = amplify_core.QueryField(fieldName: "role");
  static final DISPLAYNAME = amplify_core.QueryField(fieldName: "displayName");
  static final STATUS = amplify_core.QueryField(fieldName: "status");
  static final JOINEDAT = amplify_core.QueryField(fieldName: "joinedAt");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "GroupMembership";
    modelSchemaDefinition.pluralName = "GroupMemberships";
    
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
      amplify_core.ModelIndex(fields: const ["groupId"], name: "byGroup"),
      amplify_core.ModelIndex(fields: const ["userId"], name: "byUser")
    ];
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: GroupMembership.GROUPID,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: GroupMembership.USERID,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: GroupMembership.ROLE,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: GroupMembership.DISPLAYNAME,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: GroupMembership.STATUS,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: GroupMembership.JOINEDAT,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
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

class _GroupMembershipModelType extends amplify_core.ModelType<GroupMembership> {
  const _GroupMembershipModelType();
  
  @override
  GroupMembership fromJson(Map<String, dynamic> jsonData) {
    return GroupMembership.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'GroupMembership';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [GroupMembership] in your schema.
 */
class GroupMembershipModelIdentifier implements amplify_core.ModelIdentifier<GroupMembership> {
  final String id;

  /** Create an instance of GroupMembershipModelIdentifier using [id] the primary key. */
  const GroupMembershipModelIdentifier({
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
  String toString() => 'GroupMembershipModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is GroupMembershipModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}