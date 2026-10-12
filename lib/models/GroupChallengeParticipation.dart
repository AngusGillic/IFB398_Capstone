// ignore_for_file: public_member_api_docs, prefer_const_constructors, annotate_overrides, non_constant_identifier_names, unnecessary_const

import 'package:amplify_core/amplify_core.dart' as amplify_core;

/// Opt-in participation + progress for a group challenge.
class GroupChallengeParticipation extends amplify_core.Model {
  static const classType = _GroupChallengeParticipationModelType();
  final String id;
  final String? _challengeId;
  final String? _groupId;
  final String? _userId;
  final String? _displayName;
  final double? _progress;
  final String? _metaJson;
  final amplify_core.TemporalDateTime? _joinedAt;
  final amplify_core.TemporalDateTime? _completedAt;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  @Deprecated('Use modelIdentifier')
  @override
  String getId() => id;
  GroupChallengeParticipationModelIdentifier get modelIdentifier =>
      GroupChallengeParticipationModelIdentifier(id: id);

  String get challengeId => _challengeId!;
  String get groupId => _groupId!;
  String get userId => _userId!;
  String get displayName => _displayName ?? 'Member';
  double get progress => _progress ?? 0;
  String? get metaJson => _metaJson;
  amplify_core.TemporalDateTime? get joinedAt => _joinedAt;
  amplify_core.TemporalDateTime? get completedAt => _completedAt;
  amplify_core.TemporalDateTime? get createdAt => _createdAt;
  amplify_core.TemporalDateTime? get updatedAt => _updatedAt;

  const GroupChallengeParticipation._internal({
    required this.id,
    challengeId,
    groupId,
    userId,
    displayName,
    progress,
    metaJson,
    joinedAt,
    completedAt,
    createdAt,
    updatedAt,
  })  : _challengeId = challengeId,
        _groupId = groupId,
        _userId = userId,
        _displayName = displayName,
        _progress = progress,
        _metaJson = metaJson,
        _joinedAt = joinedAt,
        _completedAt = completedAt,
        _createdAt = createdAt,
        _updatedAt = updatedAt;

  factory GroupChallengeParticipation({
    String? id,
    required String challengeId,
    required String groupId,
    required String userId,
    required String displayName,
    double progress = 0,
    String? metaJson,
    amplify_core.TemporalDateTime? joinedAt,
    amplify_core.TemporalDateTime? completedAt,
  }) {
    return GroupChallengeParticipation._internal(
      id: id ?? amplify_core.UUID.getUUID(),
      challengeId: challengeId,
      groupId: groupId,
      userId: userId,
      displayName: displayName,
      progress: progress,
      metaJson: metaJson,
      joinedAt: joinedAt ?? amplify_core.TemporalDateTime(DateTime.now().toUtc()),
      completedAt: completedAt,
    );
  }

  GroupChallengeParticipation copyWith({
    double? progress,
    String? displayName,
    String? metaJson,
    amplify_core.TemporalDateTime? completedAt,
  }) {
    return GroupChallengeParticipation._internal(
      id: id,
      challengeId: challengeId,
      groupId: groupId,
      userId: userId,
      displayName: displayName ?? this.displayName,
      progress: progress ?? this.progress,
      metaJson: metaJson ?? this.metaJson,
      joinedAt: joinedAt,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  GroupChallengeParticipation.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        _challengeId = json['challengeId'],
        _groupId = json['groupId'],
        _userId = json['userId'],
        _displayName = json['displayName'],
        _progress = (json['progress'] as num?)?.toDouble(),
        _metaJson = json['metaJson'],
        _joinedAt = json['joinedAt'] != null
            ? amplify_core.TemporalDateTime.fromString(json['joinedAt'])
            : null,
        _completedAt = json['completedAt'] != null
            ? amplify_core.TemporalDateTime.fromString(json['completedAt'])
            : null,
        _createdAt = json['createdAt'] != null
            ? amplify_core.TemporalDateTime.fromString(json['createdAt'])
            : null,
        _updatedAt = json['updatedAt'] != null
            ? amplify_core.TemporalDateTime.fromString(json['updatedAt'])
            : null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'challengeId': _challengeId,
        'groupId': _groupId,
        'userId': _userId,
        'displayName': _displayName,
        'progress': _progress,
        'metaJson': _metaJson,
        'joinedAt': _joinedAt?.format(),
        'completedAt': _completedAt?.format(),
        'createdAt': _createdAt?.format(),
        'updatedAt': _updatedAt?.format(),
      };

  Map<String, Object?> toMap() => toJson();

  static final ID = amplify_core.QueryField(fieldName: 'id');
  static final CHALLENGEID = amplify_core.QueryField(fieldName: 'challengeId');
  static final GROUPID = amplify_core.QueryField(fieldName: 'groupId');
  static final USERID = amplify_core.QueryField(fieldName: 'userId');
  static final DISPLAYNAME = amplify_core.QueryField(fieldName: 'displayName');
  static final PROGRESS = amplify_core.QueryField(fieldName: 'progress');
  static final METAJSON = amplify_core.QueryField(fieldName: 'metaJson');
  static final JOINEDAT = amplify_core.QueryField(fieldName: 'joinedAt');
  static final COMPLETEDAT = amplify_core.QueryField(fieldName: 'completedAt');

  static var schema = amplify_core.Model.defineSchema(
      define: (amplify_core.ModelSchemaDefinition d) {
    d.name = 'GroupChallengeParticipation';
    d.pluralName = 'GroupChallengeParticipations';
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
    void str(amplify_core.QueryField key, {bool req = false}) =>
        d.addField(amplify_core.ModelFieldDefinition.field(
          key: key,
          isRequired: req,
          ofType: amplify_core.ModelFieldType(
              amplify_core.ModelFieldTypeEnum.string),
        ));
    str(CHALLENGEID, req: true);
    str(GROUPID, req: true);
    str(USERID, req: true);
    str(DISPLAYNAME, req: true);
    d.addField(amplify_core.ModelFieldDefinition.field(
      key: PROGRESS,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(
          amplify_core.ModelFieldTypeEnum.double),
    ));
    str(METAJSON);
    d.addField(amplify_core.ModelFieldDefinition.field(
      key: JOINEDAT,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(
          amplify_core.ModelFieldTypeEnum.dateTime),
    ));
    d.addField(amplify_core.ModelFieldDefinition.field(
      key: COMPLETEDAT,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(
          amplify_core.ModelFieldTypeEnum.dateTime),
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

class _GroupChallengeParticipationModelType
    extends amplify_core.ModelType<GroupChallengeParticipation> {
  const _GroupChallengeParticipationModelType();
  @override
  GroupChallengeParticipation fromJson(Map<String, dynamic> j) =>
      GroupChallengeParticipation.fromJson(j);
  @override
  String modelName() => 'GroupChallengeParticipation';
}

class GroupChallengeParticipationModelIdentifier
    implements amplify_core.ModelIdentifier<GroupChallengeParticipation> {
  final String id;
  const GroupChallengeParticipationModelIdentifier({required this.id});
  @override
  Map<String, dynamic> serializeAsMap() => {'id': id};
  @override
  List<Map<String, dynamic>> serializeAsList() => [{'id': id}];
  @override
  String serializeAsString() => id;
  @override
  bool operator ==(Object o) =>
      o is GroupChallengeParticipationModelIdentifier && o.id == id;
  @override
  int get hashCode => id.hashCode;
}
