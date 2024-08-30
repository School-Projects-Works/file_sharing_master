import 'dart:convert';

class Upload {
  String description;
  String fileUrl;
  String folderId;
  String id;
  String uploadBy;
  int createdAt;
  Upload({
    required this.description,
    required this.fileUrl,
    required this.folderId,
    required this.id,
    required this.uploadBy,
    required this.createdAt,
  });

  Upload copyWith({
    String? description,
    String? fileUrl,
    String? folderId,
    String? id,
    String? uploadBy,
    int? createdAt,
  }) {
    return Upload(
      description: description ?? this.description,
      fileUrl: fileUrl ?? this.fileUrl,
      folderId: folderId ?? this.folderId,
      id: id ?? this.id,
      uploadBy: uploadBy ?? this.uploadBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};
  
    result.addAll({'description': description});
    result.addAll({'fileUrl': fileUrl});
    result.addAll({'folderId': folderId});
    result.addAll({'id': id});
    result.addAll({'uploadBy': uploadBy});
    result.addAll({'createdAt': createdAt});
  
    return result;
  }

  factory Upload.fromMap(Map<String, dynamic> map) {
    return Upload(
      description: map['description'] ?? '',
      fileUrl: map['fileUrl'] ?? '',
      folderId: map['folderId'] ?? '',
      id: map['id'] ?? '',
      uploadBy: map['uploadBy'] ?? '',
      createdAt: map['createdAt']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory Upload.fromJson(String source) => Upload.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Upload(description: $description, fileUrl: $fileUrl, folderId: $folderId, id: $id, uploadBy: $uploadBy, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Upload &&
      other.description == description &&
      other.fileUrl == fileUrl &&
      other.folderId == folderId &&
      other.id == id &&
      other.uploadBy == uploadBy &&
      other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return description.hashCode ^
      fileUrl.hashCode ^
      folderId.hashCode ^
      id.hashCode ^
      uploadBy.hashCode ^
      createdAt.hashCode;
  }

  static Upload empty() {
    return Upload(
      description: '',
      folderId: '',
      fileUrl: '',
      id: '',
      uploadBy: '',
      createdAt: 0,
    );
  }
}
