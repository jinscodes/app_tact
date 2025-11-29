class LinkItem {
  final String id;
  final String title;
  final String url;
  final String description;
  final String categoryId;
  final String userId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isFavorite;

  LinkItem({
    required this.id,
    required this.title,
    required this.url,
    required this.description,
    required this.categoryId,
    required this.userId,
    required this.createdAt,
    this.updatedAt,
    this.isFavorite = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'description': description,
      'categoryId': categoryId,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isFavorite': isFavorite,
    };
  }

  static LinkItem fromMap(Map<String, dynamic> map) {
    return LinkItem(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      url: map['url'] ?? '',
      description: map['description'] ?? '',
      categoryId: map['categoryId'] ?? '',
      userId: map['userId'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt:
          map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
      isFavorite: map['isFavorite'] ?? false,
    );
  }

  static LinkItem fromFirestore(String docId, Map<String, dynamic> data) {
    return LinkItem(
      id: data['id'] ?? docId,
      title: data['title'] ?? '',
      url: data['url'] ?? '',
      description: data['description'] ?? '',
      categoryId: data['categoryId'] ?? '',
      userId: data['userId'] ?? '',
      createdAt: DateTime.parse(data['createdAt']),
      updatedAt:
          data['updatedAt'] != null ? DateTime.parse(data['updatedAt']) : null,
      isFavorite: data['isFavorite'] ?? false,
    );
  }
}

class Category {
  final String id;
  final String name;
  final String userId;
  final DateTime createdAt;
  final int linkCount;

  Category({
    required this.id,
    required this.name,
    required this.userId,
    required this.createdAt,
    this.linkCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'linkCount': linkCount,
    };
  }

  static Category fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      userId: map['userId'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      linkCount: map['linkCount'] ?? 0,
    );
  }

  static Category fromFirestore(String docId, Map<String, dynamic> data) {
    return Category(
      id: data['id'] ?? docId,
      name: data['name'] ?? '',
      userId: data['userId'] ?? '',
      createdAt: DateTime.parse(data['createdAt']),
      linkCount: data['linkCount'] ?? 0,
    );
  }
}
