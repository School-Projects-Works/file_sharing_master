import 'dart:convert';

class UserModel {
  String id;
  String name;
  String phone;
  String email;
  String role;
  String password;
  String status;
  int createdAt;
  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
     this.role='lecturer',
    this.password='',
     this.status='active',
    required this.createdAt,
  });

  static UserModel empty(){
    return UserModel(
      id: '',
      name: '',
      phone: '',
      email: '',
      role: 'lecturer',
      password: '',
      status: 'active',
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
  }


  UserModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? role,
    String? password,
    String? status,
    int? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      role: role ?? this.role,
      password: password ?? this.password,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};
  
    result.addAll({'id': id});
    result.addAll({'name': name});
    result.addAll({'phone': phone});
    result.addAll({'email': email});
    result.addAll({'role': role});
    result.addAll({'password': password});
    result.addAll({'status': status});
    result.addAll({'createdAt': createdAt});
  
    return result;
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? '',
      password: map['password'] ?? '',
      status: map['status'] ?? '',
      createdAt: map['createdAt']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) => UserModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, phone: $phone, email: $email, role: $role, password: $password, status: $status, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is UserModel &&
      other.id == id &&
      other.name == name &&
      other.phone == phone &&
      other.email == email &&
      other.role == role &&
      other.password == password &&
      other.status == status &&
      other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      name.hashCode ^
      phone.hashCode ^
      email.hashCode ^
      role.hashCode ^
      password.hashCode ^
      status.hashCode ^
      createdAt.hashCode;
  }
}
