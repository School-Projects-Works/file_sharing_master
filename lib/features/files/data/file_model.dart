import 'dart:convert';

import 'package:flutter/foundation.dart';

class FileModel {
  String id;
  String title;
  String description;
  String creatorId;
  Map<String, dynamic> creator;
  List<String> usersIds;
  List<Map<String, dynamic>> users;
  List<Map<String,dynamic>> files;
  String status;
  int createdAt;
  FileModel({
    required this.id,
    required this.title,
    required this.description,
    required this.creatorId,
    required this.creator,
    required this.usersIds,
    this.users =const [],
    this.files=const [],
    this.status= 'opened',
    this.createdAt= 0,
  });


static FileModel empty() {
    return FileModel(
      id: '',
      title: '',
      description: '',
      creatorId: '',
      creator: {},
      usersIds: [],
      users: [],
      files: [],
      status: 'opened',
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
  }
  FileModel copyWith({
    String? id,
    String? title,
    String? description,
    String? creatorId,
    Map<String, dynamic>? creator,
    List<String>? usersIds,
    List<Map<String, dynamic>>? users,
    List<Map<String,dynamic>>? files,
    String? status,
    int? createdAt,
  }) {
    return FileModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      creatorId: creatorId ?? this.creatorId,
      creator: creator ?? this.creator,
      usersIds: usersIds ?? this.usersIds,
      users: users ?? this.users,
      files: files ?? this.files,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};
  
    result.addAll({'id': id});
    result.addAll({'title': title});
    result.addAll({'description': description});
    result.addAll({'creatorId': creatorId});
    result.addAll({'creator': creator});
    result.addAll({'usersIds': usersIds});
    result.addAll({'users': users});
    result.addAll({'files': files});
    result.addAll({'status': status});
    result.addAll({'createdAt': createdAt});
  
    return result;
  }

  factory FileModel.fromMap(Map<String, dynamic> map) {
    return FileModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      creatorId: map['creatorId'] ?? '',
      creator: Map<String, dynamic>.from(map['creator']),
      usersIds: List<String>.from(map['usersIds']),
      users: List<Map<String, dynamic>>.from(map['users']?.map((x) => Map<String, dynamic>.from(x))),
      files: List<Map<String,dynamic>>.from(map['files']?.map((x) => Map<String,dynamic>.from(x))),
      status: map['status'] ?? '',
      createdAt: map['createdAt']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory FileModel.fromJson(String source) => FileModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'FileModel(id: $id, title: $title, description: $description, creatorId: $creatorId, creator: $creator, usersIds: $usersIds, users: $users, files: $files, status: $status, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is FileModel &&
      other.id == id &&
      other.title == title &&
      other.description == description &&
      other.creatorId == creatorId &&
      mapEquals(other.creator, creator) &&
      listEquals(other.usersIds, usersIds) &&
      listEquals(other.users, users) &&
      listEquals(other.files, files) &&
      other.status == status &&
      other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      title.hashCode ^
      description.hashCode ^
      creatorId.hashCode ^
      creator.hashCode ^
      usersIds.hashCode ^
      users.hashCode ^
      files.hashCode ^
      status.hashCode ^
      createdAt.hashCode;
  }
}
