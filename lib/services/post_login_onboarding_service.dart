import 'package:app_tact/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostLoginOnboardingState {
  const PostLoginOnboardingState({
    required this.notificationPromptShown,
    required this.themeSelected,
    required this.howToUseSeen,
    required this.onboardingCompleted,
  });

  final bool notificationPromptShown;
  final bool themeSelected;
  final bool howToUseSeen;
  final bool onboardingCompleted;
}

class PostLoginOnboardingService {
  PostLoginOnboardingService._();

  static final PostLoginOnboardingService instance =
      PostLoginOnboardingService._();

  static const _notificationPromptShownKey = 'notificationPromptShown';
  static const _themeSelectedKey = 'themeSelected';
  static const _howToUseSeenKey = 'howToUseSeen';
  static const _onboardingCompletedKey = 'onboardingCompleted';

  Future<SharedPreferences> _prefs() async {
    return SharedPreferences.getInstance();
  }

  Future<PostLoginOnboardingState> loadState() async {
    final prefs = await _prefs();
    return PostLoginOnboardingState(
      notificationPromptShown:
          prefs.getBool(_notificationPromptShownKey) ?? false,
      themeSelected: prefs.getBool(_themeSelectedKey) ?? false,
      howToUseSeen: prefs.getBool(_howToUseSeenKey) ?? false,
      onboardingCompleted: prefs.getBool(_onboardingCompletedKey) ?? false,
    );
  }

  Future<bool> shouldShowOnboarding() async {
    final state = await loadState();
    return !state.onboardingCompleted;
  }

  Future<void> completeNotificationStep(
      {required bool requestPermission}) async {
    var notificationsEnabled = false;
    if (requestPermission) {
      notificationsEnabled =
          await NotificationService().requestNotificationPermission();
    }

    final prefs = await _prefs();
    await prefs.setBool(_notificationPromptShownKey, true);

    NotificationService().persistNotificationPreferenceInBackground(
      enabled: notificationsEnabled,
    );
  }

  Future<void> markThemeSelected() async {
    final prefs = await _prefs();
    await prefs.setBool(_themeSelectedKey, true);
  }

  Future<void> markHowToUseSeen() async {
    final prefs = await _prefs();
    await prefs.setBool(_howToUseSeenKey, true);
  }

  Future<void> markOnboardingCompleted() async {
    final prefs = await _prefs();
    await prefs.setBool(_onboardingCompletedKey, true);
  }

  Future<void> completeOnboarding() async {
    final prefs = await _prefs();
    await prefs.setBool(_howToUseSeenKey, true);
    await prefs.setBool(_onboardingCompletedKey, true);
  }
}
