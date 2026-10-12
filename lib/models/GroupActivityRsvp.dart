// ignore_for_file: public_member_api_docs, prefer_const_constructors, annotate_overrides, non_constant_identifier_names, unnecessary_const

import 'package:amplify_core/amplify_core.dart' as amplify_core;

class GroupActivityRsvp extends amplify_core.Model {
  static const classType = _GroupActivityRsvpModelType();
  final String id;
  final String? _activityId;
  final String? _groupId;
  final String? _userId;
  final String? _displayName;
  final String? _status;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  @Deprecated('Use modelIdentifier')
  @override
  String getId() => id;
  GroupActivityRsvpModelIdentifier get modelIdentifier =>
      GroupActivityRsvpModelIdentifier(id: id);

  String get activityId => _activityId!;
  String get groupId => _groupId!;
  String get userId => _userId!;
  String get displayName => _displayName ?? 'Member';
  String get status => _status ?? 'going';
  amplify_core.TemporalDateTime? get createdAt => _createdAt;
  amplify_core.TemporalDateTime? get updatedAt => _updatedAt;

  const GroupActivityRsvp._internal({
    required this.id,
    activityId,
    groupId,
    userId,
    displayName,
    status,
    createdAt,
    updatedAt,
  })  : _activityId = activityId,
        _groupId = groupId,
        _userId = userId,
        _displayName = displayName,
        _status = status,
        _createdAt = createdAt,
        _updatedAt = updatedAt;

  factory GroupActivityRsvp({
    String? id,
    required String activityId,
    required String groupId,
    required String userId,
    required String displayName,
    String status = 'going',
  }) =>
      GroupActivityRsvp._internal(
        id: id ?? amplify_core.UUID.getUUID(),
        activityId: activityId,
        groupId: groupId,
        userId: userId,
        displayName: displayName,
        status: status,
      );

  GroupActivityRsvp copyWith({String? status, String? displayName}) =>
      GroupActivityRsvp._internal(
        id: id,
        activityId: activityId,
        groupId: groupId,
        userId: userId,
        displayName: displayName ?? this.displayName,
        status: status ?? this.status,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  GroupActivityRsvp.fromJson(Map<String, dynamic> j)
      : id = j['id'],
        _activityId = j['activityId'],
        _groupId = j['groupId'],
        _userId = j['userId'],
        _displayName = j['displayName'],
        _status = j['status'],
        _createdAt = j['createdAt'] != null
            ? amplify_core.TemporalDateTime.fromString(j['createdAt'])
            : null,
        _updatedAt = j['updatedAt'] != null
            ? amplify_core.TemporalDateTime.fromString(j['updatedAt'])
            : null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'activityId': _activityId,
        'groupId': _groupId,
        'userId': _userId,
        'displayName': _displayName,
        'status': _status,
        'createdAt': _createdAt?.format(),
        'updatedAt': _updatedAt?.format(),
      };
  Map<String, Object?> toMap() => toJson();

  static final ID = amplify_core.QueryField(fieldName: 'id');
  static final ACTIVITYID = amplify_core.QueryField(fieldName: 'activityId');
  static final GROUPID = amplify_core.QueryField(fieldName: 'groupId');
  static final USERID = amplify_core.QueryField(fieldName: 'userId');
  static final DISPLAYNAME = amplify_core.QueryField(fieldName: 'displayName');
  static final STATUS = amplify_core.QueryField(fieldName: 'status');

  static var schema = amplify_core.Model.defineSchema(
      define: (amplify_core.ModelSchemaDefinition d) {
    d.name = 'GroupActivityRsvp';
    d.pluralName = 'GroupActivityRsvps';
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
    s(ACTIVITYID, req: true);
    s(GROUPID, req: true);
    s(USERID, req: true);
    s(DISPLAYNAME, req: true);
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

class _GroupActivityRsvpModelType
    extends amplify_core.ModelType<GroupActivityRsvp> {
  const _GroupActivityRsvpModelType();
  @override
  GroupActivityRsvp fromJson(Map<String, dynamic> j) =>
      GroupActivityRsvp.fromJson(j);
  @override
  String modelName() => 'GroupActivityRsvp';
}

class GroupActivityRsvpModelIdentifier
    implements amplify_core.ModelIdentifier<GroupActivityRsvp> {
  final String id;
  const GroupActivityRsvpModelIdentifier({required this.id});
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
      other is GroupActivityRsvpModelIdentifier && other.id == id;
  @override
  int get hashCode => id.hashCode;
}
