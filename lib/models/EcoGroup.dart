// ignore_for_file: public_member_api_docs, prefer_const_constructors, prefer_adjacent_string_concatenation, unnecessary_new, annotate_overrides, override_on_non_overriding_member

import 'ModelProvider.dart';
import 'package:amplify_core/amplify_core.dart' as amplify_core;

/// Amplify model for eco travel groups (Phase 1).
class EcoGroup extends amplify_core.Model {
  static const classType = const _EcoGroupModelType();
  final String id;
  final String? _name;
  final String? _description;
  final String? _visibility;
  final String? _inviteCode;
  final String? _ownerUserId;
  final String? _ownerDisplayName;
  final bool? _archived;
  final String? _tags;
  final String? _cohortId;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;

  @Deprecated('Use modelIdentifier')
  @override
  String getId() => id;

  EcoGroupModelIdentifier get modelIdentifier =>
      EcoGroupModelIdentifier(id: id);

  String get name => _name!;
  String? get description => _description;
  String get visibility => _visibility ?? 'private';
  String get inviteCode => _inviteCode!;
  String get ownerUserId => _ownerUserId!;
  String? get ownerDisplayName => _ownerDisplayName;
  bool get archived => _archived ?? false;
  String? get tags => _tags;
  String? get cohortId => _cohortId;
  amplify_core.TemporalDateTime? get createdAt => _createdAt;
  amplify_core.TemporalDateTime? get updatedAt => _updatedAt;

  const EcoGroup._internal({
    required this.id,
    name,
    description,
    visibility,
    inviteCode,
    ownerUserId,
    ownerDisplayName,
    archived,
    tags,
    cohortId,
    createdAt,
    updatedAt,
  })  : _name = name,
        _description = description,
        _visibility = visibility,
        _inviteCode = inviteCode,
        _ownerUserId = ownerUserId,
        _ownerDisplayName = ownerDisplayName,
        _archived = archived,
        _tags = tags,
        _cohortId = cohortId,
        _createdAt = createdAt,
        _updatedAt = updatedAt;

  factory EcoGroup({
    String? id,
    required String name,
    String? description,
    String visibility = 'private',
    required String inviteCode,
    required String ownerUserId,
    String? ownerDisplayName,
    bool archived = false,
    String? tags,
    String? cohortId,
  }) {
    return EcoGroup._internal(
      id: id ?? amplify_core.UUID.getUUID(),
      name: name,
      description: description,
      visibility: visibility,
      inviteCode: inviteCode,
      ownerUserId: ownerUserId,
      ownerDisplayName: ownerDisplayName,
      archived: archived,
      tags: tags,
      cohortId: cohortId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is EcoGroup &&
        id == other.id &&
        _name == other._name &&
        _inviteCode == other._inviteCode &&
        _ownerUserId == other._ownerUserId;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'EcoGroup{id=$id, name=$_name, inviteCode=$_inviteCode, owner=$_ownerUserId}';

  EcoGroup copyWith({
    String? name,
    String? description,
    String? visibility,
    String? inviteCode,
    String? ownerUserId,
    String? ownerDisplayName,
    bool? archived,
    String? tags,
    String? cohortId,
  }) {
    return EcoGroup._internal(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      visibility: visibility ?? this.visibility,
      inviteCode: inviteCode ?? this.inviteCode,
      ownerUserId: ownerUserId ?? this.ownerUserId,
      ownerDisplayName: ownerDisplayName ?? this.ownerDisplayName,
      archived: archived ?? this.archived,
      tags: tags ?? this.tags,
      cohortId: cohortId ?? this.cohortId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  EcoGroup.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        _name = json['name'],
        _description = json['description'],
        _visibility = json['visibility'],
        _inviteCode = json['inviteCode'],
        _ownerUserId = json['ownerUserId'],
        _ownerDisplayName = json['ownerDisplayName'],
        _archived = json['archived'],
        _tags = json['tags'],
        _cohortId = json['cohortId'],
        _createdAt = json['createdAt'] != null
            ? amplify_core.TemporalDateTime.fromString(json['createdAt'])
            : null,
        _updatedAt = json['updatedAt'] != null
            ? amplify_core.TemporalDateTime.fromString(json['updatedAt'])
            : null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': _name,
        'description': _description,
        'visibility': _visibility,
        'inviteCode': _inviteCode,
        'ownerUserId': _ownerUserId,
        'ownerDisplayName': _ownerDisplayName,
        'archived': _archived,
        'tags': _tags,
        'cohortId': _cohortId,
        'createdAt': _createdAt?.format(),
        'updatedAt': _updatedAt?.format(),
      };

  Map<String, Object?> toMap() => {
        'id': id,
        'name': _name,
        'description': _description,
        'visibility': _visibility,
        'inviteCode': _inviteCode,
        'ownerUserId': _ownerUserId,
        'ownerDisplayName': _ownerDisplayName,
        'archived': _archived,
        'tags': _tags,
        'cohortId': _cohortId,
        'createdAt': _createdAt,
        'updatedAt': _updatedAt,
      };

  static final amplify_core.QueryModelIdentifier<EcoGroupModelIdentifier>
      MODEL_IDENTIFIER =
      amplify_core.QueryModelIdentifier<EcoGroupModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: 'id');
  static final NAME = amplify_core.QueryField(fieldName: 'name');
  static final DESCRIPTION = amplify_core.QueryField(fieldName: 'description');
  static final VISIBILITY = amplify_core.QueryField(fieldName: 'visibility');
  static final INVITECODE = amplify_core.QueryField(fieldName: 'inviteCode');
  static final OWNERUSERID = amplify_core.QueryField(fieldName: 'ownerUserId');
  static final OWNERDISPLAYNAME =
      amplify_core.QueryField(fieldName: 'ownerDisplayName');
  static final ARCHIVED = amplify_core.QueryField(fieldName: 'archived');
  static final TAGS = amplify_core.QueryField(fieldName: 'tags');
  static final COHORTID = amplify_core.QueryField(fieldName: 'cohortId');

  static var schema = amplify_core.Model.defineSchema(
      define: (amplify_core.ModelSchemaDefinition d) {
    d.name = 'EcoGroup';
    d.pluralName = 'EcoGroups';
    d.authRules = [
      amplify_core.AuthRule(
        authStrategy: amplify_core.AuthStrategy.PUBLIC,
        operations: const [
          amplify_core.ModelOperation.CREATE,
          amplify_core.ModelOperation.UPDATE,
          amplify_core.ModelOperation.DELETE,
          amplify_core.ModelOperation.READ,
        ],
      )
    ];
    d.addField(amplify_core.ModelFieldDefinition.id());
    d.addField(amplify_core.ModelFieldDefinition.field(
      key: EcoGroup.NAME,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(
          amplify_core.ModelFieldTypeEnum.string),
    ));
    d.addField(amplify_core.ModelFieldDefinition.field(
      key: EcoGroup.DESCRIPTION,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(
          amplify_core.ModelFieldTypeEnum.string),
    ));
    d.addField(amplify_core.ModelFieldDefinition.field(
      key: EcoGroup.VISIBILITY,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(
          amplify_core.ModelFieldTypeEnum.string),
    ));
    d.addField(amplify_core.ModelFieldDefinition.field(
      key: EcoGroup.INVITECODE,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(
          amplify_core.ModelFieldTypeEnum.string),
    ));
    d.addField(amplify_core.ModelFieldDefinition.field(
      key: EcoGroup.OWNERUSERID,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(
          amplify_core.ModelFieldTypeEnum.string),
    ));
    d.addField(amplify_core.ModelFieldDefinition.field(
      key: EcoGroup.OWNERDISPLAYNAME,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(
          amplify_core.ModelFieldTypeEnum.string),
    ));
    d.addField(amplify_core.ModelFieldDefinition.field(
      key: EcoGroup.ARCHIVED,
      isRequired: false,
      ofType:
          amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.bool),
    ));
    d.addField(amplify_core.ModelFieldDefinition.field(
      key: EcoGroup.TAGS,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(
          amplify_core.ModelFieldTypeEnum.string),
    ));
    d.addField(amplify_core.ModelFieldDefinition.field(
      key: EcoGroup.COHORTID,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(
          amplify_core.ModelFieldTypeEnum.string),
    ));
    d.addField(amplify_core.ModelFieldDefinition.nonQueryField(
      fieldName: 'createdAt',
      isRequired: false,
      isReadOnly: true,
      ofType: amplify_core.ModelFieldType(
          amplify_core.ModelFieldTypeEnum.dateTime),
    ));
    d.addField(amplify_core.ModelFieldDefinition.nonQueryField(
      fieldName: 'updatedAt',
      isRequired: false,
      isReadOnly: true,
      ofType: amplify_core.ModelFieldType(
          amplify_core.ModelFieldTypeEnum.dateTime),
    ));
  });
}

class _EcoGroupModelType extends amplify_core.ModelType<EcoGroup> {
  const _EcoGroupModelType();
  @override
  EcoGroup fromJson(Map<String, dynamic> jsonData) => EcoGroup.fromJson(jsonData);
  @override
  String modelName() => 'EcoGroup';
}

class EcoGroupModelIdentifier implements amplify_core.ModelIdentifier<EcoGroup> {
  final String id;
  const EcoGroupModelIdentifier({required this.id});
  @override
  Map<String, dynamic> serializeAsMap() => {'id': id};
  @override
  List<Map<String, dynamic>> serializeAsList() =>
      serializeAsMap().entries.map((e) => {e.key: e.value}).toList();
  @override
  String serializeAsString() => id;
  @override
  String toString() => 'EcoGroupModelIdentifier(id: $id)';
  @override
  bool operator ==(Object other) =>
      other is EcoGroupModelIdentifier && other.id == id;
  @override
  int get hashCode => id.hashCode;
}
