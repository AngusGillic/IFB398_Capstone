// ignore_for_file: public_member_api_docs, prefer_const_constructors, annotate_overrides, non_constant_identifier_names, unnecessary_const

import 'package:amplify_core/amplify_core.dart' as amplify_core;

class GroupActivity extends amplify_core.Model {
  static const classType = _GroupActivityModelType();
  final String id;
  final String? _groupId;
  final String? _creatorUserId;
  final String? _creatorDisplayName;
  final String? _title;
  final String? _description;
  final String? _emoji;
  final String? _modeHint;
  final String? _locationText;
  final amplify_core.TemporalDateTime? _startsAt;
  final amplify_core.TemporalDateTime? _endsAt;
  final String? _status;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  @Deprecated('Use modelIdentifier')
  @override
  String getId() => id;
  GroupActivityModelIdentifier get modelIdentifier =>
      GroupActivityModelIdentifier(id: id);

  String get groupId => _groupId!;
  String get creatorUserId => _creatorUserId!;
  String? get creatorDisplayName => _creatorDisplayName;
  String get title => _title!;
  String? get description => _description;
  String get emoji => _emoji ?? '📅';
  String? get modeHint => _modeHint;
  String? get locationText => _locationText;
  amplify_core.TemporalDateTime get startsAt => _startsAt!;
  amplify_core.TemporalDateTime? get endsAt => _endsAt;
  String get status => _status ?? 'scheduled';
  amplify_core.TemporalDateTime? get createdAt => _createdAt;
  amplify_core.TemporalDateTime? get updatedAt => _updatedAt;

  const GroupActivity._internal({
    required this.id,
    groupId,
    creatorUserId,
    creatorDisplayName,
    title,
    description,
    emoji,
    modeHint,
    locationText,
    startsAt,
    endsAt,
    status,
    createdAt,
    updatedAt,
  })  : _groupId = groupId,
        _creatorUserId = creatorUserId,
        _creatorDisplayName = creatorDisplayName,
        _title = title,
        _description = description,
        _emoji = emoji,
        _modeHint = modeHint,
        _locationText = locationText,
        _startsAt = startsAt,
        _endsAt = endsAt,
        _status = status,
        _createdAt = createdAt,
        _updatedAt = updatedAt;

  factory GroupActivity({
    String? id,
    required String groupId,
    required String creatorUserId,
    String? creatorDisplayName,
    required String title,
    String? description,
    String emoji = '📅',
    String? modeHint,
    String? locationText,
    required amplify_core.TemporalDateTime startsAt,
    amplify_core.TemporalDateTime? endsAt,
    String status = 'scheduled',
  }) =>
      GroupActivity._internal(
        id: id ?? amplify_core.UUID.getUUID(),
        groupId: groupId,
        creatorUserId: creatorUserId,
        creatorDisplayName: creatorDisplayName,
        title: title,
        description: description,
        emoji: emoji,
        modeHint: modeHint,
        locationText: locationText,
        startsAt: startsAt,
        endsAt: endsAt,
        status: status,
      );

  GroupActivity copyWith({String? status, String? title, String? description}) =>
      GroupActivity._internal(
        id: id,
        groupId: groupId,
        creatorUserId: creatorUserId,
        creatorDisplayName: creatorDisplayName,
        title: title ?? this.title,
        description: description ?? this.description,
        emoji: emoji,
        modeHint: modeHint,
        locationText: locationText,
        startsAt: startsAt,
        endsAt: endsAt,
        status: status ?? this.status,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  GroupActivity.fromJson(Map<String, dynamic> j)
      : id = j['id'],
        _groupId = j['groupId'],
        _creatorUserId = j['creatorUserId'],
        _creatorDisplayName = j['creatorDisplayName'],
        _title = j['title'],
        _description = j['description'],
        _emoji = j['emoji'],
        _modeHint = j['modeHint'],
        _locationText = j['locationText'],
        _startsAt = j['startsAt'] != null
            ? amplify_core.TemporalDateTime.fromString(j['startsAt'])
            : null,
        _endsAt = j['endsAt'] != null
            ? amplify_core.TemporalDateTime.fromString(j['endsAt'])
            : null,
        _status = j['status'],
        _createdAt = j['createdAt'] != null
            ? amplify_core.TemporalDateTime.fromString(j['createdAt'])
            : null,
        _updatedAt = j['updatedAt'] != null
            ? amplify_core.TemporalDateTime.fromString(j['updatedAt'])
            : null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'groupId': _groupId,
        'creatorUserId': _creatorUserId,
        'creatorDisplayName': _creatorDisplayName,
        'title': _title,
        'description': _description,
        'emoji': _emoji,
        'modeHint': _modeHint,
        'locationText': _locationText,
        'startsAt': _startsAt?.format(),
        'endsAt': _endsAt?.format(),
        'status': _status,
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
  static final MODEHINT = amplify_core.QueryField(fieldName: 'modeHint');
  static final LOCATIONTEXT =
      amplify_core.QueryField(fieldName: 'locationText');
  static final STARTSAT = amplify_core.QueryField(fieldName: 'startsAt');
  static final ENDSAT = amplify_core.QueryField(fieldName: 'endsAt');
  static final STATUS = amplify_core.QueryField(fieldName: 'status');

  static var schema = amplify_core.Model.defineSchema(
      define: (amplify_core.ModelSchemaDefinition d) {
    d.name = 'GroupActivity';
    d.pluralName = 'GroupActivities';
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
    void s(amplify_core.QueryField k, {bool req = false}) =>
        d.addField(amplify_core.ModelFieldDefinition.field(
          key: k,
          isRequired: req,
          ofType: amplify_core.ModelFieldType(
              amplify_core.ModelFieldTypeEnum.string),
        ));
    s(GROUPID, req: true);
    s(CREATORUSERID, req: true);
    s(CREATORDISPLAYNAME);
    s(TITLE, req: true);
    s(DESCRIPTION);
    s(EMOJI);
    s(MODEHINT);
    s(LOCATIONTEXT);
    d.addField(amplify_core.ModelFieldDefinition.field(
      key: STARTSAT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(
          amplify_core.ModelFieldTypeEnum.dateTime),
    ));
    d.addField(amplify_core.ModelFieldDefinition.field(
      key: ENDSAT,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(
          amplify_core.ModelFieldTypeEnum.dateTime),
    ));
    s(STATUS, req: true);
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

class _GroupActivityModelType extends amplify_core.ModelType<GroupActivity> {
  const _GroupActivityModelType();
  @override
  GroupActivity fromJson(Map<String, dynamic> j) => GroupActivity.fromJson(j);
  @override
  String modelName() => 'GroupActivity';
}

class GroupActivityModelIdentifier
    implements amplify_core.ModelIdentifier<GroupActivity> {
  final String id;
  const GroupActivityModelIdentifier({required this.id});
  @override
  Map<String, dynamic> serializeAsMap() => {'id': id};
  @override
  List<Map<String, dynamic>> serializeAsList() => [
        {'id': id}
      ];
  @override
  String serializeAsString() => id;
  @override
  bool operator ==(Object other) =>
      other is GroupActivityModelIdentifier && other.id == id;
  @override
  int get hashCode => id.hashCode;
}
