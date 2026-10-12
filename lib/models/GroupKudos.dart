// ignore_for_file: public_member_api_docs, prefer_const_constructors, annotate_overrides, non_constant_identifier_names, unnecessary_const

import 'package:amplify_core/amplify_core.dart' as amplify_core;

class GroupKudos extends amplify_core.Model {
  static const classType = _GroupKudosModelType();
  final String id;
  final String? _groupId;
  final String? _fromUserId;
  final String? _fromDisplayName;
  final String? _toUserId;
  final String? _toDisplayName;
  final String? _targetType;
  final String? _targetId;
  final String? _kind;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  @Deprecated('Use modelIdentifier')
  @override
  String getId() => id;
  GroupKudosModelIdentifier get modelIdentifier =>
      GroupKudosModelIdentifier(id: id);

  String get groupId => _groupId!;
  String get fromUserId => _fromUserId!;
  String? get fromDisplayName => _fromDisplayName;
  String get toUserId => _toUserId!;
  String? get toDisplayName => _toDisplayName;
  String get targetType => _targetType ?? 'feed';
  String get targetId => _targetId!;
  String get kind => _kind ?? 'congrats';
  amplify_core.TemporalDateTime? get createdAt => _createdAt;
  amplify_core.TemporalDateTime? get updatedAt => _updatedAt;

  const GroupKudos._internal({
    required this.id,
    groupId,
    fromUserId,
    fromDisplayName,
    toUserId,
    toDisplayName,
    targetType,
    targetId,
    kind,
    createdAt,
    updatedAt,
  })  : _groupId = groupId,
        _fromUserId = fromUserId,
        _fromDisplayName = fromDisplayName,
        _toUserId = toUserId,
        _toDisplayName = toDisplayName,
        _targetType = targetType,
        _targetId = targetId,
        _kind = kind,
        _createdAt = createdAt,
        _updatedAt = updatedAt;

  factory GroupKudos({
    String? id,
    required String groupId,
    required String fromUserId,
    String? fromDisplayName,
    required String toUserId,
    String? toDisplayName,
    required String targetType,
    required String targetId,
    String kind = 'congrats',
    amplify_core.TemporalDateTime? createdAt,
  }) =>
      GroupKudos._internal(
        id: id ?? amplify_core.UUID.getUUID(),
        groupId: groupId,
        fromUserId: fromUserId,
        fromDisplayName: fromDisplayName,
        toUserId: toUserId,
        toDisplayName: toDisplayName,
        targetType: targetType,
        targetId: targetId,
        kind: kind,
        createdAt:
            createdAt ?? amplify_core.TemporalDateTime(DateTime.now().toUtc()),
      );

  GroupKudos.fromJson(Map<String, dynamic> j)
      : id = j['id'],
        _groupId = j['groupId'],
        _fromUserId = j['fromUserId'],
        _fromDisplayName = j['fromDisplayName'],
        _toUserId = j['toUserId'],
        _toDisplayName = j['toDisplayName'],
        _targetType = j['targetType'],
        _targetId = j['targetId'],
        _kind = j['kind'],
        _createdAt = j['createdAt'] != null
            ? amplify_core.TemporalDateTime.fromString(j['createdAt'])
            : null,
        _updatedAt = j['updatedAt'] != null
            ? amplify_core.TemporalDateTime.fromString(j['updatedAt'])
            : null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'groupId': _groupId,
        'fromUserId': _fromUserId,
        'fromDisplayName': _fromDisplayName,
        'toUserId': _toUserId,
        'toDisplayName': _toDisplayName,
        'targetType': _targetType,
        'targetId': _targetId,
        'kind': _kind,
        'createdAt': _createdAt?.format(),
        'updatedAt': _updatedAt?.format(),
      };
  Map<String, Object?> toMap() => toJson();

  static final ID = amplify_core.QueryField(fieldName: 'id');
  static final GROUPID = amplify_core.QueryField(fieldName: 'groupId');
  static final FROMUSERID = amplify_core.QueryField(fieldName: 'fromUserId');
  static final FROMDISPLAYNAME =
      amplify_core.QueryField(fieldName: 'fromDisplayName');
  static final TOUSERID = amplify_core.QueryField(fieldName: 'toUserId');
  static final TODISPLAYNAME =
      amplify_core.QueryField(fieldName: 'toDisplayName');
  static final TARGETTYPE = amplify_core.QueryField(fieldName: 'targetType');
  static final TARGETID = amplify_core.QueryField(fieldName: 'targetId');
  static final KIND = amplify_core.QueryField(fieldName: 'kind');
  static final CREATEDAT = amplify_core.QueryField(fieldName: 'createdAt');

  static var schema = amplify_core.Model.defineSchema(
      define: (amplify_core.ModelSchemaDefinition d) {
    d.name = 'GroupKudos';
    d.pluralName = 'GroupKudos';
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
    s(FROMUSERID, req: true);
    s(FROMDISPLAYNAME);
    s(TOUSERID, req: true);
    s(TODISPLAYNAME);
    s(TARGETTYPE, req: true);
    s(TARGETID, req: true);
    s(KIND, req: true);
    d.addField(amplify_core.ModelFieldDefinition.field(
      key: CREATEDAT,
      isRequired: false,
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

class _GroupKudosModelType extends amplify_core.ModelType<GroupKudos> {
  const _GroupKudosModelType();
  @override
  GroupKudos fromJson(Map<String, dynamic> j) => GroupKudos.fromJson(j);
  @override
  String modelName() => 'GroupKudos';
}

class GroupKudosModelIdentifier
    implements amplify_core.ModelIdentifier<GroupKudos> {
  final String id;
  const GroupKudosModelIdentifier({required this.id});
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
      other is GroupKudosModelIdentifier && other.id == id;
  @override
  int get hashCode => id.hashCode;
}
