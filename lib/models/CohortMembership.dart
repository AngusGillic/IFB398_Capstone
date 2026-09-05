// ignore_for_file: public_member_api_docs, prefer_const_constructors, annotate_overrides, non_constant_identifier_names, unnecessary_const

import 'package:amplify_core/amplify_core.dart' as amplify_core;

class CohortMembership extends amplify_core.Model {
  static const classType = _CohortMembershipModelType();
  final String id;
  final String? _cohortId;
  final String? _userId;
  final String? _displayName;
  final bool? _showDisplayName;
  final int? _totalPoints;
  final int? _weekPoints;
  final amplify_core.TemporalDateTime? _joinedAt;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  @Deprecated('Use modelIdentifier')
  @override
  String getId() => id;
  CohortMembershipModelIdentifier get modelIdentifier =>
      CohortMembershipModelIdentifier(id: id);

  String get cohortId => _cohortId!;
  String get userId => _userId!;
  String get displayName => _displayName ?? 'Traveller';
  bool get showDisplayName => _showDisplayName ?? true;
  int get totalPoints => _totalPoints ?? 0;
  int get weekPoints => _weekPoints ?? 0;
  amplify_core.TemporalDateTime? get joinedAt => _joinedAt;
  amplify_core.TemporalDateTime? get createdAt => _createdAt;
  amplify_core.TemporalDateTime? get updatedAt => _updatedAt;

  const CohortMembership._internal({
    required this.id,
    cohortId,
    userId,
    displayName,
    showDisplayName,
    totalPoints,
    weekPoints,
    joinedAt,
    createdAt,
    updatedAt,
  })  : _cohortId = cohortId,
        _userId = userId,
        _displayName = displayName,
        _showDisplayName = showDisplayName,
        _totalPoints = totalPoints,
        _weekPoints = weekPoints,
        _joinedAt = joinedAt,
        _createdAt = createdAt,
        _updatedAt = updatedAt;

  factory CohortMembership({
    String? id,
    required String cohortId,
    required String userId,
    required String displayName,
    bool showDisplayName = true,
    int totalPoints = 0,
    int weekPoints = 0,
    amplify_core.TemporalDateTime? joinedAt,
  }) =>
      CohortMembership._internal(
        id: id ?? amplify_core.UUID.getUUID(),
        cohortId: cohortId,
        userId: userId,
        displayName: displayName,
        showDisplayName: showDisplayName,
        totalPoints: totalPoints,
        weekPoints: weekPoints,
        joinedAt:
            joinedAt ?? amplify_core.TemporalDateTime(DateTime.now().toUtc()),
      );

  CohortMembership copyWith({
    String? displayName,
    bool? showDisplayName,
    int? totalPoints,
    int? weekPoints,
  }) =>
      CohortMembership._internal(
        id: id,
        cohortId: cohortId,
        userId: userId,
        displayName: displayName ?? this.displayName,
        showDisplayName: showDisplayName ?? this.showDisplayName,
        totalPoints: totalPoints ?? this.totalPoints,
        weekPoints: weekPoints ?? this.weekPoints,
        joinedAt: joinedAt,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  CohortMembership.fromJson(Map<String, dynamic> j)
      : id = j['id'],
        _cohortId = j['cohortId'],
        _userId = j['userId'],
        _displayName = j['displayName'],
        _showDisplayName = j['showDisplayName'],
        _totalPoints = (j['totalPoints'] as num?)?.toInt(),
        _weekPoints = (j['weekPoints'] as num?)?.toInt(),
        _joinedAt = j['joinedAt'] != null
            ? amplify_core.TemporalDateTime.fromString(j['joinedAt'])
            : null,
        _createdAt = j['createdAt'] != null
            ? amplify_core.TemporalDateTime.fromString(j['createdAt'])
            : null,
        _updatedAt = j['updatedAt'] != null
            ? amplify_core.TemporalDateTime.fromString(j['updatedAt'])
            : null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'cohortId': _cohortId,
        'userId': _userId,
        'displayName': _displayName,
        'showDisplayName': _showDisplayName,
        'totalPoints': _totalPoints,
        'weekPoints': _weekPoints,
        'joinedAt': _joinedAt?.format(),
        'createdAt': _createdAt?.format(),
        'updatedAt': _updatedAt?.format(),
      };
  Map<String, Object?> toMap() => toJson();

  static final ID = amplify_core.QueryField(fieldName: 'id');
  static final COHORTID = amplify_core.QueryField(fieldName: 'cohortId');
  static final USERID = amplify_core.QueryField(fieldName: 'userId');
  static final DISPLAYNAME = amplify_core.QueryField(fieldName: 'displayName');
  static final SHOWDISPLAYNAME =
      amplify_core.QueryField(fieldName: 'showDisplayName');
  static final TOTALPOINTS = amplify_core.QueryField(fieldName: 'totalPoints');
  static final WEEKPOINTS = amplify_core.QueryField(fieldName: 'weekPoints');
  static final JOINEDAT = amplify_core.QueryField(fieldName: 'joinedAt');

  static var schema = amplify_core.Model.defineSchema(
      define: (amplify_core.ModelSchemaDefinition d) {
    d.name = 'CohortMembership';
    d.pluralName = 'CohortMemberships';
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
    s(COHORTID, req: true);
    s(USERID, req: true);
    s(DISPLAYNAME, req: true);
    d.addField(amplify_core.ModelFieldDefinition.field(
      key: SHOWDISPLAYNAME,
      isRequired: false,
      ofType:
          amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.bool),
    ));
    d.addField(amplify_core.ModelFieldDefinition.field(
      key: TOTALPOINTS,
      isRequired: false,
      ofType:
          amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int),
    ));
    d.addField(amplify_core.ModelFieldDefinition.field(
      key: WEEKPOINTS,
      isRequired: false,
      ofType:
          amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int),
    ));
    d.addField(amplify_core.ModelFieldDefinition.field(
      key: JOINEDAT,
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

class _CohortMembershipModelType
    extends amplify_core.ModelType<CohortMembership> {
  const _CohortMembershipModelType();
  @override
  CohortMembership fromJson(Map<String, dynamic> j) =>
      CohortMembership.fromJson(j);
  @override
  String modelName() => 'CohortMembership';
}

class CohortMembershipModelIdentifier
    implements amplify_core.ModelIdentifier<CohortMembership> {
  final String id;
  const CohortMembershipModelIdentifier({required this.id});
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
      other is CohortMembershipModelIdentifier && other.id == id;
  @override
  int get hashCode => id.hashCode;
}
