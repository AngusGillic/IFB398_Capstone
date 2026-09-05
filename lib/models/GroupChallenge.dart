// ignore_for_file: public_member_api_docs, prefer_const_constructors, annotate_overrides, non_constant_identifier_names, unnecessary_const

import 'package:amplify_core/amplify_core.dart' as amplify_core;

/// Amplify model: member-created opt-in group challenge (Phase 2).
class GroupChallenge extends amplify_core.Model {
  static const classType = _GroupChallengeModelType();
  final String id;
  final String? _groupId;
  final String? _creatorUserId;
  final String? _creatorDisplayName;
  final String? _title;
  final String? _description;
  final String? _emoji;
  final String? _goalType;
  final double? _goalTarget;
  final amplify_core.TemporalDateTime? _startAt;
  final amplify_core.TemporalDateTime? _endAt;
  final String? _status;
  final String? _progressVisibility;
  final String? _templateId;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  @Deprecated('Use modelIdentifier')
  @override
  String getId() => id;
  GroupChallengeModelIdentifier get modelIdentifier =>
      GroupChallengeModelIdentifier(id: id);

  String get groupId => _groupId!;
  String get creatorUserId => _creatorUserId!;
  String? get creatorDisplayName => _creatorDisplayName;
  String get title => _title!;
  String? get description => _description;
  String get emoji => _emoji ?? '🎯';
  String get goalType => _goalType!;
  double get goalTarget => _goalTarget ?? 1;
  amplify_core.TemporalDateTime get startAt => _startAt!;
  amplify_core.TemporalDateTime get endAt => _endAt!;
  String get status => _status ?? 'open';
  String get progressVisibility => _progressVisibility ?? 'whole_group';
  String? get templateId => _templateId;
  amplify_core.TemporalDateTime? get createdAt => _createdAt;
  amplify_core.TemporalDateTime? get updatedAt => _updatedAt;

  const GroupChallenge._internal({
    required this.id,
    groupId,
    creatorUserId,
    creatorDisplayName,
    title,
    description,
    emoji,
    goalType,
    goalTarget,
    startAt,
    endAt,
    status,
    progressVisibility,
    templateId,
    createdAt,
    updatedAt,
  })  : _groupId = groupId,
        _creatorUserId = creatorUserId,
        _creatorDisplayName = creatorDisplayName,
        _title = title,
        _description = description,
        _emoji = emoji,
        _goalType = goalType,
        _goalTarget = goalTarget,
        _startAt = startAt,
        _endAt = endAt,
        _status = status,
        _progressVisibility = progressVisibility,
        _templateId = templateId,
        _createdAt = createdAt,
        _updatedAt = updatedAt;

  factory GroupChallenge({
    String? id,
    required String groupId,
    required String creatorUserId,
    String? creatorDisplayName,
    required String title,
    String? description,
    String emoji = '🎯',
    required String goalType,
    required double goalTarget,
    required amplify_core.TemporalDateTime startAt,
    required amplify_core.TemporalDateTime endAt,
    String status = 'open',
    String progressVisibility = 'whole_group',
    String? templateId,
  }) {
    return GroupChallenge._internal(
      id: id ?? amplify_core.UUID.getUUID(),
      groupId: groupId,
      creatorUserId: creatorUserId,
      creatorDisplayName: creatorDisplayName,
      title: title,
      description: description,
      emoji: emoji,
      goalType: goalType,
      goalTarget: goalTarget,
      startAt: startAt,
      endAt: endAt,
      status: status,
      progressVisibility: progressVisibility,
      templateId: templateId,
    );
  }

  GroupChallenge copyWith({
    String? title,
    String? description,
    String? status,
    String? progressVisibility,
    double? goalTarget,
  }) {
    return GroupChallenge._internal(
      id: id,
      groupId: groupId,
      creatorUserId: creatorUserId,
      creatorDisplayName: creatorDisplayName,
      title: title ?? this.title,
      description: description ?? this.description,
      emoji: emoji,
      goalType: goalType,
      goalTarget: goalTarget ?? this.goalTarget,
      startAt: startAt,
      endAt: endAt,
      status: status ?? this.status,
      progressVisibility: progressVisibility ?? this.progressVisibility,
      templateId: templateId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  GroupChallenge.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        _groupId = json['groupId'],
        _creatorUserId = json['creatorUserId'],
        _creatorDisplayName = json['creatorDisplayName'],
        _title = json['title'],
        _description = json['description'],
        _emoji = json['emoji'],
        _goalType = json['goalType'],
        _goalTarget = (json['goalTarget'] as num?)?.toDouble(),
        _startAt = json['startAt'] != null
            ? amplify_core.TemporalDateTime.fromString(json['startAt'])
            : null,
        _endAt = json['endAt'] != null
            ? amplify_core.TemporalDateTime.fromString(json['endAt'])
            : null,
        _status = json['status'],
        _progressVisibility = json['progressVisibility'],
        _templateId = json['templateId'],
        _createdAt = json['createdAt'] != null
            ? amplify_core.TemporalDateTime.fromString(json['createdAt'])
            : null,
        _updatedAt = json['updatedAt'] != null
            ? amplify_core.TemporalDateTime.fromString(json['updatedAt'])
            : null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'groupId': _groupId,
        'creatorUserId': _creatorUserId,
        'creatorDisplayName': _creatorDisplayName,
        'title': _title,
        'description': _description,
        'emoji': _emoji,
        'goalType': _goalType,
        'goalTarget': _goalTarget,
        'startAt': _startAt?.format(),
        'endAt': _endAt?.format(),
        'status': _status,
        'progressVisibility': _progressVisibility,
        'templateId': _templateId,
        'createdAt': _createdAt?.format(),
        'updatedAt': _updatedAt?.format(),
      };

  Map<String, Object?> toMap() => toJson();

  static final ID = amplify_core.QueryField(fieldName: 'id');
  static final GROUPID = amplify_core.QueryField(fieldName: 'groupId');
  static final CREATORUSERID =
      amplify_core.QueryField(fieldName: 'creatorUserId');
  static final CREATORDISPLAYNAME =
      amplify_core.QueryField(fieldName: 'creatorDisplayName');
  static final TITLE = amplify_core.QueryField(fieldName: 'title');
  static final DESCRIPTION = amplify_core.QueryField(fieldName: 'description');
  static final EMOJI = amplify_core.QueryField(fieldName: 'emoji');
  static final GOALTYPE = amplify_core.QueryField(fieldName: 'goalType');
  static final GOALTARGET = amplify_core.QueryField(fieldName: 'goalTarget');
  static final STARTAT = amplify_core.QueryField(fieldName: 'startAt');
  static final ENDAT = amplify_core.QueryField(fieldName: 'endAt');
  static final STATUS = amplify_core.QueryField(fieldName: 'status');
  static final PROGRESSVISIBILITY =
      amplify_core.QueryField(fieldName: 'progressVisibility');
  static final TEMPLATEID = amplify_core.QueryField(fieldName: 'templateId');

  static var schema = amplify_core.Model.defineSchema(
      define: (amplify_core.ModelSchemaDefinition d) {
    d.name = 'GroupChallenge';
    d.pluralName = 'GroupChallenges';
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
    str(GROUPID, req: true);
    str(CREATORUSERID, req: true);
    str(CREATORDISPLAYNAME);
    str(TITLE, req: true);
    str(DESCRIPTION);
    str(EMOJI);
    str(GOALTYPE, req: true);
    d.addField(amplify_core.ModelFieldDefinition.field(
      key: GOALTARGET,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(
          amplify_core.ModelFieldTypeEnum.double),
    ));
    d.addField(amplify_core.ModelFieldDefinition.field(
      key: STARTAT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(
          amplify_core.ModelFieldTypeEnum.dateTime),
    ));
    d.addField(amplify_core.ModelFieldDefinition.field(
      key: ENDAT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(
          amplify_core.ModelFieldTypeEnum.dateTime),
    ));
    str(STATUS, req: true);
    str(PROGRESSVISIBILITY);
    str(TEMPLATEID);
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

class _GroupChallengeModelType extends amplify_core.ModelType<GroupChallenge> {
  const _GroupChallengeModelType();
  @override
  GroupChallenge fromJson(Map<String, dynamic> j) => GroupChallenge.fromJson(j);
  @override
  String modelName() => 'GroupChallenge';
}

class GroupChallengeModelIdentifier
    implements amplify_core.ModelIdentifier<GroupChallenge> {
  final String id;
  const GroupChallengeModelIdentifier({required this.id});
  @override
  Map<String, dynamic> serializeAsMap() => {'id': id};
  @override
  List<Map<String, dynamic>> serializeAsList() =>
      [{'id': id}];
  @override
  String serializeAsString() => id;
  @override
  bool operator ==(Object o) => o is GroupChallengeModelIdentifier && o.id == id;
  @override
  int get hashCode => id.hashCode;
}
