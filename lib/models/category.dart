class Category {
  final String id;
  final String name;
  final String userId;
  final DateTime createdAt;
  final bool isDefault;

  Category({
    required this.id,
    required this.name,
    required this.userId,
    required this.createdAt,
    this.isDefault = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'isDefault': isDefault,
    };
  }

  static Category fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      userId: map['userId'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      isDefault: map['isDefault'] ?? false,
    );
  }

  static Category fromFirestore(String docId, Map<String, dynamic> data) {
    return Category(
      id: data['id'] ?? docId,
      name: data['name'] ?? '',
      userId: data['userId'] ?? '',
      createdAt: DateTime.parse(data['createdAt']),
      isDefault: data['isDefault'] ?? false,
    );
  }

  Category copyWith({
    String? id,
    String? name,
    String? userId,
    DateTime? createdAt,
    bool? isDefault,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  @override
  String toString() {
    return 'Category(id: $id, name: $name, userId: $userId, createdAt: $createdAt, isDefault: $isDefault)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Category &&
        other.id == id &&
        other.name == name &&
        other.userId == userId &&
        other.createdAt == createdAt &&
        other.isDefault == isDefault;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        userId.hashCode ^
        createdAt.hashCode ^
        isDefault.hashCode;
  }
}
