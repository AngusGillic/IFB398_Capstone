// ignore_for_file: public_member_api_docs, prefer_const_constructors, annotate_overrides, non_constant_identifier_names, unnecessary_const

import 'package:amplify_core/amplify_core.dart' as amplify_core;

/// Lightweight group feed post (challenge created/completed in Phase 2).
class GroupFeedItem extends amplify_core.Model {
  static const classType = _GroupFeedItemModelType();
  final String id;
  final String? _groupId;
  final String? _authorUserId;
  final String? _authorDisplayName;
  final String? _type;
  final String? _title;
  final String? _body;
  final String? _challengeId;
  final String? _activityId;
  final int? _kudosCount;
  final amplify_core.TemporalDateTime? _postedAt;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  @Deprecated('Use modelIdentifier')
  @override
  String getId() => id;
  GroupFeedItemModelIdentifier get modelIdentifier =>
      GroupFeedItemModelIdentifier(id: id);

  String get groupId => _groupId!;
  String get authorUserId => _authorUserId!;
  String get authorDisplayName => _authorDisplayName ?? 'Member';
  String get type => _type ?? 'manual';
  String get title => _title ?? '';
  String? get body => _body;
  String? get challengeId => _challengeId;
  String? get activityId => _activityId;
  int get kudosCount => _kudosCount ?? 0;
  amplify_core.TemporalDateTime? get postedAt => _postedAt;
  amplify_core.TemporalDateTime? get createdAt => _createdAt;
  amplify_core.TemporalDateTime? get updatedAt => _updatedAt;

  const GroupFeedItem._internal({
    required this.id,
    groupId,
    authorUserId,
    authorDisplayName,
    type,
    title,
    body,
    challengeId,
    activityId,
    kudosCount,
    postedAt,
    createdAt,
    updatedAt,
  })  : _groupId = groupId,
        _authorUserId = authorUserId,
        _authorDisplayName = authorDisplayName,
        _type = type,
        _title = title,
        _body = body,
        _challengeId = challengeId,
        _activityId = activityId,
        _kudosCount = kudosCount,
        _postedAt = postedAt,
        _createdAt = createdAt,
        _updatedAt = updatedAt;

  factory GroupFeedItem({
    String? id,
    required String groupId,
    required String authorUserId,
    required String authorDisplayName,
    required String type,
    required String title,
    String? body,
    String? challengeId,
    String? activityId,
    int kudosCount = 0,
    amplify_core.TemporalDateTime? postedAt,
  }) {
    return GroupFeedItem._internal(
      id: id ?? amplify_core.UUID.getUUID(),
      groupId: groupId,
      authorUserId: authorUserId,
      authorDisplayName: authorDisplayName,
      type: type,
      title: title,
      body: body,
      challengeId: challengeId,
      activityId: activityId,
      kudosCount: kudosCount,
      postedAt:
          postedAt ?? amplify_core.TemporalDateTime(DateTime.now().toUtc()),
    );
  }

  GroupFeedItem copyWith({int? kudosCount, String? body, String? title}) {
    return GroupFeedItem._internal(
      id: id,
      groupId: groupId,
      authorUserId: authorUserId,
      authorDisplayName: authorDisplayName,
      type: type,
      title: title ?? this.title,
      body: body ?? this.body,
      challengeId: challengeId,
      activityId: activityId,
      kudosCount: kudosCount ?? this.kudosCount,
      postedAt: postedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  GroupFeedItem.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        _groupId = json['groupId'],
        _authorUserId = json['authorUserId'],
        _authorDisplayName = json['authorDisplayName'],
        _type = json['type'],
        _title = json['title'],
        _body = json['body'],
        _challengeId = json['challengeId'],
        _activityId = json['activityId'],
        _kudosCount = (json['kudosCount'] as num?)?.toInt(),
        _postedAt = json['postedAt'] != null
            ? amplify_core.TemporalDateTime.fromString(json['postedAt'])
            : null,
        _createdAt = json['createdAt'] != null
            ? amplify_core.TemporalDateTime.fromString(json['createdAt'])
            : null,
        _updatedAt = json['updatedAt'] != null
            ? amplify_core.TemporalDateTime.fromString(json['updatedAt'])
            : null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'groupId': _groupId,
        'authorUserId': _authorUserId,
        'authorDisplayName': _authorDisplayName,
        'type': _type,
        'title': _title,
        'body': _body,
        'challengeId': _challengeId,
        'activityId': _activityId,
        'kudosCount': _kudosCount,
        'postedAt': _postedAt?.format(),
        'createdAt': _createdAt?.format(),
        'updatedAt': _updatedAt?.format(),
      };

  Map<String, Object?> toMap() => toJson();

  static final ID = amplify_core.QueryField(fieldName: 'id');
  static final GROUPID = amplify_core.QueryField(fieldName: 'groupId');
  static final AUTHORUSERID =
      amplify_core.QueryField(fieldName: 'authorUserId');
  static final AUTHORDISPLAYNAME =
      amplify_core.QueryField(fieldName: 'authorDisplayName');
  static final TYPE = amplify_core.QueryField(fieldName: 'type');
  static final TITLE = amplify_core.QueryField(fieldName: 'title');
  static final BODY = amplify_core.QueryField(fieldName: 'body');
  static final CHALLENGEID = amplify_core.QueryField(fieldName: 'challengeId');
  static final ACTIVITYID = amplify_core.QueryField(fieldName: 'activityId');
  static final KUDOSCOUNT = amplify_core.QueryField(fieldName: 'kudosCount');
  static final POSTEDAT = amplify_core.QueryField(fieldName: 'postedAt');

  static var schema = amplify_core.Model.defineSchema(
      define: (amplify_core.ModelSchemaDefinition d) {
    d.name = 'GroupFeedItem';
    d.pluralName = 'GroupFeedItems';
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
    str(AUTHORUSERID, req: true);
    str(AUTHORDISPLAYNAME, req: true);
    str(TYPE, req: true);
    str(TITLE, req: true);
    str(BODY);
    str(CHALLENGEID);
    str(ACTIVITYID);
    d.addField(amplify_core.ModelFieldDefinition.field(
      key: KUDOSCOUNT,
      isRequired: false,
      ofType:
          amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int),
    ));
    d.addField(amplify_core.ModelFieldDefinition.field(
      key: POSTEDAT,
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

class _GroupFeedItemModelType extends amplify_core.ModelType<GroupFeedItem> {
  const _GroupFeedItemModelType();
  @override
  GroupFeedItem fromJson(Map<String, dynamic> j) => GroupFeedItem.fromJson(j);
  @override
  String modelName() => 'GroupFeedItem';
}

class GroupFeedItemModelIdentifier
    implements amplify_core.ModelIdentifier<GroupFeedItem> {
  final String id;
  const GroupFeedItemModelIdentifier({required this.id});
  @override
  Map<String, dynamic> serializeAsMap() => {'id': id};
  @override
  List<Map<String, dynamic>> serializeAsList() => [{'id': id}];
  @override
  String serializeAsString() => id;
  @override
  bool operator ==(Object o) => o is GroupFeedItemModelIdentifier && o.id == id;
  @override
  int get hashCode => id.hashCode;
}
