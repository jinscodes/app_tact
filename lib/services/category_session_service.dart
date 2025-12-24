/// Service to manage category unlock sessions
/// Categories unlocked during the session remain unlocked until app restart
class CategorySessionService {
  static final CategorySessionService _instance =
      CategorySessionService._internal();

  factory CategorySessionService() {
    return _instance;
  }

  CategorySessionService._internal();

  // Set of category IDs that have been unlocked in this session
  final Set<String> _unlockedCategories = {};

  /// Check if a category is unlocked in the current session
  bool isUnlockedInSession(String categoryId) {
    return _unlockedCategories.contains(categoryId);
  }

  /// Mark a category as unlocked for this session
  void unlockCategory(String categoryId) {
    _unlockedCategories.add(categoryId);
  }

  /// Lock a category (remove from session unlock list)
  void lockCategory(String categoryId) {
    _unlockedCategories.remove(categoryId);
  }

  /// Clear all session unlocks (e.g., when user logs out)
  void clearSession() {
    _unlockedCategories.clear();
  }

  /// Get all unlocked category IDs
  Set<String> getUnlockedCategories() {
    return Set.unmodifiable(_unlockedCategories);
  }
}
