import 'dart:convert';

class OfficeModel {
  String id;
  String name;
  String officeEmail;
  String officePhone;
  String password;
  String status;
  int createdAt;
  OfficeModel({
    required this.id,
    required this.name,
    required this.officeEmail,
    required this.officePhone,
    required this.password,
    required this.status,
    required this.createdAt,
  });

  OfficeModel copyWith({
    String? id,
    String? name,
    String? officeEmail,
    String? officePhone,
    String? password,
    String? status,
    int? createdAt,
  }) {
    return OfficeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      officeEmail: officeEmail ?? this.officeEmail,
      officePhone: officePhone ?? this.officePhone,
      password: password ?? this.password,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};
  
    result.addAll({'id': id});
    result.addAll({'name': name});
    result.addAll({'officeEmail': officeEmail});
    result.addAll({'officePhone': officePhone});
    result.addAll({'password': password});
    result.addAll({'status': status});
    result.addAll({'createdAt': createdAt});
  
    return result;
  }

  factory OfficeModel.fromMap(Map<String, dynamic> map) {
    return OfficeModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      officeEmail: map['officeEmail'] ?? '',
      officePhone: map['officePhone'] ?? '',
      password: map['password'] ?? '',
      status: map['status'] ?? '',
      createdAt: map['createdAt']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory OfficeModel.fromJson(String source) => OfficeModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'OfficeModel(id: $id, name: $name, officeEmail: $officeEmail, officePhone: $officePhone, password: $password, status: $status, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is OfficeModel &&
      other.id == id &&
      other.name == name &&
      other.officeEmail == officeEmail &&
      other.officePhone == officePhone &&
      other.password == password &&
      other.status == status &&
      other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      name.hashCode ^
      officeEmail.hashCode ^
      officePhone.hashCode ^
      password.hashCode ^
      status.hashCode ^
      createdAt.hashCode;
  }

  static OfficeModel empty() {
    return OfficeModel(
      id: '',
      name: '',
      officeEmail: '',
      officePhone: '',
      password: '',
      status: '',
      createdAt: 0,
    );

  }
}
