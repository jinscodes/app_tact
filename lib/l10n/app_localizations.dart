// ignore_for_file: non_constant_identifier_names
import 'package:flutter/material.dart';

/// Hand-written localization class (EN + KO).
///
/// Add the delegate to MaterialApp:
///   localizationsDelegates: [AppLocalizations.delegate, ...]
///
/// Usage in widgets:
///   final l = AppLocalizations.of(context);
///   Text(l.settingsTitle)
class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  // ── Translation tables ──────────────────────────────────────────────────────

  static final Map<String, Map<String, String>> _strings = {
    'en': {
      // ── Settings ─────────────────────────────────────────────────────────
      'settingsTitle': 'Settings',
      'sectionPreferences': 'Preferences',
      'sectionAccount': 'Account',
      'sectionSupport': 'Support',
      'rowNotifications': 'Notifications',
      'rowAppearance': 'Appearance',
      'rowLanguage': 'Language',
      'rowProfile': 'Profile',
      'rowPrivacySecurity': 'Privacy & Security',
      'rowSubscription': 'Subscription',
      'rowHelpSupport': 'Help & Support',
      'rowAbout': 'About',
      'rowVersionLabel': 'Version 1.0.0',
      'logOut': 'Log Out',
      'langPickerTitle': 'Language',
      'langPickerSubtitle': 'Choose your preferred language',

      // ── Notifications ─────────────────────────────────────────────────────
      'notifSectionGeneral': 'General',
      'notifPushTitle': 'Push Notifications',
      'notifPushSubtitle': 'Receive push notifications',
      'notifEmailTitle': 'Email Notifications',
      'notifEmailSubtitle': 'Receive notifications via email',
      'notifSectionActivity': 'Activity',
      'notifLinkRemindersTitle': 'Link Reminders',
      'notifLinkRemindersSubtitle': 'Get reminded about saved links',
      'notifWeeklyDigestTitle': 'Weekly Digest',
      'notifWeeklyDigestSubtitle': 'Weekly summary of your activity',
      'notifSectionUpdates': 'Updates',
      'notifNewFeaturesTitle': 'New Features',
      'notifNewFeaturesSubtitle': 'Updates about new features',
      'notifPromotionsTitle': 'Promotions',
      'notifPromotionsSubtitle': 'Special offers and promotions',
      'notifFailedToSave': 'Failed to save settings',

      // ── Privacy & Security ────────────────────────────────────────────────
      'privSecTitle': 'Privacy & Security',
      'privSecSectionAuth': 'Authentication',
      'privSecBiometricTitle': 'Biometric Login',
      'privSecBiometricSubtitle': 'Use fingerprint or face ID',
      'privSecTwoFactorTitle': 'Two-Factor Authentication',
      'privSecTwoFactorSubtitle': 'Add an extra layer of security',
      'privSecSetTwoFactorTitle': 'Set Two-Factor Authentication',
      'privSecSetTwoFactorSubtitle': 'Configure 2FA with verification code',
      'privSecSectionPassword': 'Password',
      'privSecChangePasswordTitle': 'Change Password',
      'privSecChangePasswordSubtitle': 'Update your account password',
      'privSecSectionPrivacyPolicy': 'Privacy Policy',
      'privSecPrivacyPolicyTitle': 'Privacy Policy',
      'privSecPrivacyPolicySubtitle': 'Read our privacy policy',
      'privSecTermsTitle': 'Terms of Service',
      'privSecTermsSubtitle': 'Read our terms of service',
      'privSecSectionDataPrivacy': 'Data & Privacy',
      'privSecDownloadDataTitle': 'Download Your Data',
      'privSecDownloadDataSubtitle': 'Export your personal information',
      'privSecDeleteAccountTitle': 'Delete Account',
      'privSecDeleteAccountSubtitle': 'Permanently delete your account',

      // ── Subscription ──────────────────────────────────────────────────────
      'subTitle': 'Subscription',
      'subStatusActive': 'ACTIVE',
      'subStatusInactive': 'INACTIVE',
      'subSectionManage': 'MANAGE',
      'subUpgradeManagePlan': 'Upgrade / Manage Plan',
      'subRestorePurchases': 'Restore Purchases',
      'subRestoring': 'Restoring…',
      'subPurchaseSuccessful': 'Purchase successful',
      'subPurchaseFailed': 'Purchase failed or canceled',
      'subPurchasesRestored': 'Purchases restored',
      'subUpgradeToPro': 'Upgrade to Pro',
      'subUnlockAllFeatures': 'Unlock all features & remove limits',
      'subRenews': 'Renews',

      // ── Help & Support ────────────────────────────────────────────────────
      'helpTitle': 'Help & Support',
      'helpSectionContactUs': 'Contact Us',
      'helpEmailSupportTitle': 'Email Support',
      'helpReportBugTitle': 'Report a Bug',
      'helpReportBugSubtitle': 'Help us improve Tact',
      'helpSectionFAQ': 'Frequently Asked Questions',
      'helpFAQ1Q': 'How do I create a category?',
      'helpFAQ1A':
          'Tap the + button on the main screen, enter a category name and emoji, then tap Create.',
      'helpFAQ2Q': 'How do I add links to a category?',
      'helpFAQ2A':
          'Tap on a category card, then tap the + button to add a new link. Enter the URL and optional title.',
      'helpFAQ3Q': 'Can I sync my data across devices?',
      'helpFAQ3A':
          'Yes! Your data is automatically synced across all devices where you\'re signed in with the same account.',
      'helpFAQ4Q': 'How do I delete a category?',
      'helpFAQ4A':
          'Long press on a category card, then select the delete option from the menu.',
      'helpFAQ5Q': 'Is my data secure?',
      'helpFAQ5A':
          'Yes, all your data is encrypted and stored securely using Firebase. We take your privacy seriously.',
      'helpFAQ6Q': 'How do I change my password?',
      'helpFAQ6A':
          'Go to Settings > Privacy & Security > Change Password to update your account password.',
      'helpSectionResources': 'Resources',
      'helpUserGuideTitle': 'User Guide',
      'helpUserGuideSubtitle': 'Learn how to use Tact',
      'helpVideoTutorialsTitle': 'Video Tutorials',
      'helpVideoTutorialsSubtitle': 'Watch step-by-step guides',
      'helpBlogUpdatesTitle': 'Blog & Updates',
      'helpBlogUpdatesSubtitle': 'Latest news and tips',
      'helpSectionCommunity': 'Community',
      'helpFeatureRequestsTitle': 'Feature Requests',
      'helpFeatureRequestsSubtitle': 'Suggest new features',
      'helpBugDialogTitle': 'Report a Bug',
      'helpBugTitleLabel': 'Bug Title',
      'helpDescriptionLabel': 'Description',
      'helpCancel': 'Cancel',
      'helpSubmit': 'Submit',
      'helpBugSubmitted': 'Bug report submitted!',
      'helpFeatureDialogTitle': 'Feature Request',
      'helpFeatureTitleLabel': 'Feature Title',
      'helpFeatureSubmitted': 'Feature request submitted!',
      'helpEmailCopied': 'Email copied to clipboard',
      'helpOpeningUserGuide': 'Opening user guide...',
      'helpOpeningVideoTutorials': 'Opening video tutorials...',
      'helpOpeningBlog': 'Opening blog...',

      // ── About ─────────────────────────────────────────────────────────────
      'aboutTitle': 'About',
      'aboutAppSubtitle': 'Your smart link & note organizer',
      'aboutCardTitle': 'About Tact',
      'aboutCardBody':
          'Tact is your personal link and note organization tool — helping you capture important URLs, sticker notes, and resources. Build categories, add context, and access everything instantly.',
      'aboutSectionFeatures': 'FEATURES',
      'aboutFeature1Title': 'Organize with Categories',
      'aboutFeature1Desc': 'Create custom categories to organize your links',
      'aboutFeature2Title': 'Cloud Sync',
      'aboutFeature2Desc': 'Access your data across all your devices',
      'aboutFeature3Title': 'Secure & Private',
      'aboutFeature3Desc': 'Your data is encrypted and protected at rest',
      'aboutFeature4Title': 'Notes & Stickers',
      'aboutFeature4Desc': 'Add context and sticker notes to anything',
      'aboutInfoDeveloper': 'Developer',
      'aboutInfoPlatform': 'Platform',
      'aboutInfoReleased': 'Released',
      'aboutInfoContact': 'Contact',
      'aboutCopyright': '© 2025 Tact · All rights reserved.',

      // ── Links screen ─────────────────────────────────────────────────────
      'linksTitle': 'Links',
      'linksOpenLinkTitle': 'Open Link',
      'linksUrlLabel': 'URL',
      'linksCopyUrl': 'Copy URL',
      'linksClose': 'Close',
      'linksUrlCopied': 'URL copied to clipboard',
      'linksErrorLoading': 'Error loading categories',
      'linksNoCategoriesTitle': 'No categories yet',
      'linksNoCategoriesSubtitle': 'Start by creating your first category',

      // ── Profile screen ───────────────────────────────────────────────────
      'profileEditName': 'Edit Name',
      'profileEnterNameHint': 'Enter your name',
      'profileCancel': 'Cancel',
      'profileSave': 'Save',
      'profileOpeningGallery': 'Opening gallery...',
      'profileUploadingImage': 'Uploading image...',
      'profileImageUpdated': 'Profile image updated successfully',
      'profileImageTooLarge':
          'Image is too large. Please choose a photo under 2 MB.',
      'profileFailedUpload': 'Failed to upload image',
      'profileStorageError':
          'Storage error. Please ensure Firebase Storage is enabled.',
      'profilePermissionError':
          'Permission denied. Please check storage rules.',
      'profileNetworkError': 'Network error. Please check your connection.',
      'profileUserIdCopied': 'User ID copied',
      'profileSectionAccount': 'Account',
      'profileSectionSubscription': 'Subscription',
      'profileSectionSupport': 'Support',
      'profileRowEmail': 'Email',
      'profileRowMemberSince': 'Member Since',
      'profileRowUserId': 'User ID',
      'profileRowPlan': 'Plan',
      'profileSubActive': 'Active',
      'profileRowGetHelp': 'Get help',
      'profileComingSoon': 'Coming soon',
      'profileLogOut': 'Log Out',

      // ── Tab bar ──────────────────────────────────────────────────────────
      'tabLinks': 'Links',
      'tabSettings': 'Settings',
      'tabProfile': 'Profile',

      // ── Notification permission sheet ────────────────────────────────────
      'notifPermTitle': 'Allow Notifications',
      'notifPermBody': 'Get reminders and updates when they matter.',
      'notifPermAllow': 'Allow Notifications',
      'notifPermNotNow': 'Not Now',
    },

    // ── Korean ──────────────────────────────────────────────────────────────
    'ko': {
      // ── Settings ─────────────────────────────────────────────────────────
      'settingsTitle': '설정',
      'sectionPreferences': '환경설정',
      'sectionAccount': '계정',
      'sectionSupport': '지원',
      'rowNotifications': '알림',
      'rowAppearance': '디자인',
      'rowLanguage': '언어',
      'rowProfile': '프로필',
      'rowPrivacySecurity': '개인정보 및 보안',
      'rowSubscription': '구독',
      'rowHelpSupport': '도움말 및 지원',
      'rowAbout': '앱 정보',
      'rowVersionLabel': 'Version 1.0.0',
      'logOut': '로그아웃',
      'langPickerTitle': '언어',
      'langPickerSubtitle': '원하는 언어를 선택하세요',

      // ── Notifications ─────────────────────────────────────────────────────
      'notifSectionGeneral': '일반',
      'notifPushTitle': '푸시 알림',
      'notifPushSubtitle': '푸시 알림 받기',
      'notifEmailTitle': '이메일 알림',
      'notifEmailSubtitle': '이메일로 알림 받기',
      'notifSectionActivity': '활동',
      'notifLinkRemindersTitle': '링크 리마인더',
      'notifLinkRemindersSubtitle': '저장된 링크 알림 받기',
      'notifWeeklyDigestTitle': '주간 요약',
      'notifWeeklyDigestSubtitle': '주간 활동 요약 받기',
      'notifSectionUpdates': '업데이트',
      'notifNewFeaturesTitle': '새 기능',
      'notifNewFeaturesSubtitle': '새 기능 업데이트 알림',
      'notifPromotionsTitle': '프로모션',
      'notifPromotionsSubtitle': '특별 혜택 및 프로모션',
      'notifFailedToSave': '설정 저장에 실패했습니다',

      // ── Privacy & Security ────────────────────────────────────────────────
      'privSecTitle': '개인정보 및 보안',
      'privSecSectionAuth': '인증',
      'privSecBiometricTitle': '생체인식 로그인',
      'privSecBiometricSubtitle': '지문 또는 Face ID 사용',
      'privSecTwoFactorTitle': '2단계 인증',
      'privSecTwoFactorSubtitle': '추가 보안 레이어 설정',
      'privSecSetTwoFactorTitle': '2단계 인증 설정',
      'privSecSetTwoFactorSubtitle': '인증 코드로 2FA 구성',
      'privSecSectionPassword': '비밀번호',
      'privSecChangePasswordTitle': '비밀번호 변경',
      'privSecChangePasswordSubtitle': '계정 비밀번호 업데이트',
      'privSecSectionPrivacyPolicy': '개인정보 처리방침',
      'privSecPrivacyPolicyTitle': '개인정보 처리방침',
      'privSecPrivacyPolicySubtitle': '개인정보 처리방침 읽기',
      'privSecTermsTitle': '이용약관',
      'privSecTermsSubtitle': '이용약관 읽기',
      'privSecSectionDataPrivacy': '데이터 및 개인정보',
      'privSecDownloadDataTitle': '데이터 다운로드',
      'privSecDownloadDataSubtitle': '개인정보 내보내기',
      'privSecDeleteAccountTitle': '계정 삭제',
      'privSecDeleteAccountSubtitle': '계정 영구 삭제',

      // ── Subscription ──────────────────────────────────────────────────────
      'subTitle': '구독',
      'subStatusActive': '활성',
      'subStatusInactive': '비활성',
      'subSectionManage': '관리',
      'subUpgradeManagePlan': '업그레이드 / 플랜 관리',
      'subRestorePurchases': '구매 복원',
      'subRestoring': '복원 중…',
      'subPurchaseSuccessful': '구매 성공',
      'subPurchaseFailed': '구매 실패 또는 취소됨',
      'subPurchasesRestored': '구매 복원 완료',
      'subUpgradeToPro': 'Pro로 업그레이드',
      'subUnlockAllFeatures': '모든 기능 잠금 해제 및 제한 해제',
      'subRenews': '갱신일',

      // ── Help & Support ────────────────────────────────────────────────────
      'helpTitle': '도움말 및 지원',
      'helpSectionContactUs': '문의하기',
      'helpEmailSupportTitle': '이메일 지원',
      'helpReportBugTitle': '버그 신고',
      'helpReportBugSubtitle': 'Tact 개선을 도와주세요',
      'helpSectionFAQ': '자주 묻는 질문',
      'helpFAQ1Q': '카테고리를 어떻게 만드나요?',
      'helpFAQ1A': '메인 화면에서 + 버튼을 탭하고, 카테고리 이름과 이모지를 입력한 후 만들기를 탭하세요.',
      'helpFAQ2Q': '카테고리에 링크를 어떻게 추가하나요?',
      'helpFAQ2A': '카테고리 카드를 탭한 후 + 버튼을 탭해 새 링크를 추가하세요. URL과 선택적 제목을 입력하세요.',
      'helpFAQ3Q': '여러 기기에서 데이터를 동기화할 수 있나요?',
      'helpFAQ3A': '네! 같은 계정으로 로그인한 모든 기기에서 데이터가 자동으로 동기화됩니다.',
      'helpFAQ4Q': '카테고리를 어떻게 삭제하나요?',
      'helpFAQ4A': '카테고리 카드를 길게 누른 후 메뉴에서 삭제 옵션을 선택하세요.',
      'helpFAQ5Q': '내 데이터는 안전한가요?',
      'helpFAQ5A':
          '네, 모든 데이터는 Firebase를 통해 암호화되어 안전하게 저장됩니다. 개인정보 보호를 최우선으로 생각합니다.',
      'helpFAQ6Q': '비밀번호를 어떻게 변경하나요?',
      'helpFAQ6A': '설정 > 개인정보 및 보안 > 비밀번호 변경으로 이동하여 계정 비밀번호를 업데이트하세요.',
      'helpSectionResources': '리소스',
      'helpUserGuideTitle': '사용 가이드',
      'helpUserGuideSubtitle': 'Tact 사용법 알아보기',
      'helpVideoTutorialsTitle': '동영상 튜토리얼',
      'helpVideoTutorialsSubtitle': '단계별 가이드 시청',
      'helpBlogUpdatesTitle': '블로그 및 업데이트',
      'helpBlogUpdatesSubtitle': '최신 뉴스 및 팁',
      'helpSectionCommunity': '커뮤니티',
      'helpFeatureRequestsTitle': '기능 요청',
      'helpFeatureRequestsSubtitle': '새 기능 제안하기',
      'helpBugDialogTitle': '버그 신고',
      'helpBugTitleLabel': '버그 제목',
      'helpDescriptionLabel': '설명',
      'helpCancel': '취소',
      'helpSubmit': '제출',
      'helpBugSubmitted': '버그 신고가 제출되었습니다!',
      'helpFeatureDialogTitle': '기능 요청',
      'helpFeatureTitleLabel': '기능 제목',
      'helpFeatureSubmitted': '기능 요청이 제출되었습니다!',
      'helpEmailCopied': '이메일이 클립보드에 복사되었습니다',
      'helpOpeningUserGuide': '사용 가이드 열기...',
      'helpOpeningVideoTutorials': '동영상 튜토리얼 열기...',
      'helpOpeningBlog': '블로그 열기...',

      // ── About ─────────────────────────────────────────────────────────────
      'aboutTitle': '앱 정보',
      'aboutAppSubtitle': '스마트 링크 및 노트 관리 앱',
      'aboutCardTitle': 'Tact 소개',
      'aboutCardBody':
          'Tact는 중요한 URL, 스티커 메모, 리소스를 캡처하는 개인 링크 및 노트 관리 도구입니다. 카테고리를 만들고 컨텍스트를 추가하여 모든 것에 즉시 접근하세요.',
      'aboutSectionFeatures': '주요 기능',
      'aboutFeature1Title': '카테고리로 정리',
      'aboutFeature1Desc': '커스텀 카테고리를 만들어 링크를 정리하세요',
      'aboutFeature2Title': '클라우드 동기화',
      'aboutFeature2Desc': '모든 기기에서 데이터에 접근하세요',
      'aboutFeature3Title': '안전 및 개인정보 보호',
      'aboutFeature3Desc': '데이터가 암호화되어 안전하게 보호됩니다',
      'aboutFeature4Title': '노트 및 스티커',
      'aboutFeature4Desc': '무엇이든 컨텍스트와 스티커 메모를 추가하세요',
      'aboutInfoDeveloper': '개발자',
      'aboutInfoPlatform': '플랫폼',
      'aboutInfoReleased': '출시일',
      'aboutInfoContact': '문의',
      'aboutCopyright': '© 2025 Tact · All rights reserved.',

      // ── Links screen ─────────────────────────────────────────────────────
      'linksTitle': '링크',
      'linksOpenLinkTitle': '링크 열기',
      'linksUrlLabel': 'URL',
      'linksCopyUrl': 'URL 복사',
      'linksClose': '닫기',
      'linksUrlCopied': 'URL이 클립보드에 복사되었습니다',
      'linksErrorLoading': '카테고리 불러오기 오류',
      'linksNoCategoriesTitle': '카테고리가 없습니다',
      'linksNoCategoriesSubtitle': '첫 번째 카테고리를 만들어보세요',

      // ── Profile screen ───────────────────────────────────────────────────
      'profileEditName': '이름 수정',
      'profileEnterNameHint': '이름을 입력하세요',
      'profileCancel': '취소',
      'profileSave': '저장',
      'profileOpeningGallery': '갤러리 열기...',
      'profileUploadingImage': '이미지 업로드 중...',
      'profileImageUpdated': '프로필 이미지가 업데이트되었습니다',
      'profileImageTooLarge': '이미지가 너무 큽니다. 2MB 미만의 사진을 선택해주세요.',
      'profileFailedUpload': '이미지 업로드 실패',
      'profileStorageError': '스토리지 오류. Firebase Storage가 활성화되어 있는지 확인해주세요.',
      'profilePermissionError': '권한이 거부되었습니다. 스토리지 규칙을 확인해주세요.',
      'profileNetworkError': '네트워크 오류. 연결 상태를 확인해주세요.',
      'profileUserIdCopied': '사용자 ID가 복사되었습니다',
      'profileSectionAccount': '계정',
      'profileSectionSubscription': '구독',
      'profileSectionSupport': '지원',
      'profileRowEmail': '이메일',
      'profileRowMemberSince': '가입일',
      'profileRowUserId': '사용자 ID',
      'profileRowPlan': '플랜',
      'profileSubActive': '활성',
      'profileRowGetHelp': '도움 받기',
      'profileComingSoon': '준비 중입니다',
      'profileLogOut': '로그아웃',

      // ── Tab bar ──────────────────────────────────────────────────────────
      'tabLinks': '링크',
      'tabSettings': '설정',
      'tabProfile': '프로필',

      // ── Notification permission sheet ────────────────────────────────────
      'notifPermTitle': '알림 허용',
      'notifPermBody': '중요한 순간에 리마인더와 업데이트를 받아보세요.',
      'notifPermAllow': '알림 허용',
      'notifPermNotNow': '나중에',
    },
  };

  // ── Lookup helper ───────────────────────────────────────────────────────────

  String _t(String key) {
    return _strings[locale.languageCode]?[key] ?? _strings['en']![key] ?? key;
  }

  // ── Settings ────────────────────────────────────────────────────────────────
  String get settingsTitle => _t('settingsTitle');
  String get sectionPreferences => _t('sectionPreferences');
  String get sectionAccount => _t('sectionAccount');
  String get sectionSupport => _t('sectionSupport');
  String get rowNotifications => _t('rowNotifications');
  String get rowAppearance => _t('rowAppearance');
  String get rowLanguage => _t('rowLanguage');
  String get rowProfile => _t('rowProfile');
  String get rowPrivacySecurity => _t('rowPrivacySecurity');
  String get rowSubscription => _t('rowSubscription');
  String get rowHelpSupport => _t('rowHelpSupport');
  String get rowAbout => _t('rowAbout');
  String get rowVersionLabel => _t('rowVersionLabel');
  String get logOut => _t('logOut');
  String get langPickerTitle => _t('langPickerTitle');
  String get langPickerSubtitle => _t('langPickerSubtitle');

  // ── Notifications ────────────────────────────────────────────────────────────
  String get notifSectionGeneral => _t('notifSectionGeneral');
  String get notifPushTitle => _t('notifPushTitle');
  String get notifPushSubtitle => _t('notifPushSubtitle');
  String get notifEmailTitle => _t('notifEmailTitle');
  String get notifEmailSubtitle => _t('notifEmailSubtitle');
  String get notifSectionActivity => _t('notifSectionActivity');
  String get notifLinkRemindersTitle => _t('notifLinkRemindersTitle');
  String get notifLinkRemindersSubtitle => _t('notifLinkRemindersSubtitle');
  String get notifWeeklyDigestTitle => _t('notifWeeklyDigestTitle');
  String get notifWeeklyDigestSubtitle => _t('notifWeeklyDigestSubtitle');
  String get notifSectionUpdates => _t('notifSectionUpdates');
  String get notifNewFeaturesTitle => _t('notifNewFeaturesTitle');
  String get notifNewFeaturesSubtitle => _t('notifNewFeaturesSubtitle');
  String get notifPromotionsTitle => _t('notifPromotionsTitle');
  String get notifPromotionsSubtitle => _t('notifPromotionsSubtitle');
  String get notifFailedToSave => _t('notifFailedToSave');

  // ── Privacy & Security ───────────────────────────────────────────────────────
  String get privSecTitle => _t('privSecTitle');
  String get privSecSectionAuth => _t('privSecSectionAuth');
  String get privSecBiometricTitle => _t('privSecBiometricTitle');
  String get privSecBiometricSubtitle => _t('privSecBiometricSubtitle');
  String get privSecTwoFactorTitle => _t('privSecTwoFactorTitle');
  String get privSecTwoFactorSubtitle => _t('privSecTwoFactorSubtitle');
  String get privSecSetTwoFactorTitle => _t('privSecSetTwoFactorTitle');
  String get privSecSetTwoFactorSubtitle => _t('privSecSetTwoFactorSubtitle');
  String get privSecSectionPassword => _t('privSecSectionPassword');
  String get privSecChangePasswordTitle => _t('privSecChangePasswordTitle');
  String get privSecChangePasswordSubtitle =>
      _t('privSecChangePasswordSubtitle');
  String get privSecSectionPrivacyPolicy => _t('privSecSectionPrivacyPolicy');
  String get privSecPrivacyPolicyTitle => _t('privSecPrivacyPolicyTitle');
  String get privSecPrivacyPolicySubtitle => _t('privSecPrivacyPolicySubtitle');
  String get privSecTermsTitle => _t('privSecTermsTitle');
  String get privSecTermsSubtitle => _t('privSecTermsSubtitle');
  String get privSecSectionDataPrivacy => _t('privSecSectionDataPrivacy');
  String get privSecDownloadDataTitle => _t('privSecDownloadDataTitle');
  String get privSecDownloadDataSubtitle => _t('privSecDownloadDataSubtitle');
  String get privSecDeleteAccountTitle => _t('privSecDeleteAccountTitle');
  String get privSecDeleteAccountSubtitle => _t('privSecDeleteAccountSubtitle');

  // ── Subscription ─────────────────────────────────────────────────────────────
  String get subTitle => _t('subTitle');
  String get subStatusActive => _t('subStatusActive');
  String get subStatusInactive => _t('subStatusInactive');
  String get subSectionManage => _t('subSectionManage');
  String get subUpgradeManagePlan => _t('subUpgradeManagePlan');
  String get subRestorePurchases => _t('subRestorePurchases');
  String get subRestoring => _t('subRestoring');
  String get subPurchaseSuccessful => _t('subPurchaseSuccessful');
  String get subPurchaseFailed => _t('subPurchaseFailed');
  String get subPurchasesRestored => _t('subPurchasesRestored');
  String get subUpgradeToPro => _t('subUpgradeToPro');
  String get subUnlockAllFeatures => _t('subUnlockAllFeatures');
  String get subRenews => _t('subRenews');

  // ── Help & Support ───────────────────────────────────────────────────────────
  String get helpTitle => _t('helpTitle');
  String get helpSectionContactUs => _t('helpSectionContactUs');
  String get helpEmailSupportTitle => _t('helpEmailSupportTitle');
  String get helpReportBugTitle => _t('helpReportBugTitle');
  String get helpReportBugSubtitle => _t('helpReportBugSubtitle');
  String get helpSectionFAQ => _t('helpSectionFAQ');
  String get helpFAQ1Q => _t('helpFAQ1Q');
  String get helpFAQ1A => _t('helpFAQ1A');
  String get helpFAQ2Q => _t('helpFAQ2Q');
  String get helpFAQ2A => _t('helpFAQ2A');
  String get helpFAQ3Q => _t('helpFAQ3Q');
  String get helpFAQ3A => _t('helpFAQ3A');
  String get helpFAQ4Q => _t('helpFAQ4Q');
  String get helpFAQ4A => _t('helpFAQ4A');
  String get helpFAQ5Q => _t('helpFAQ5Q');
  String get helpFAQ5A => _t('helpFAQ5A');
  String get helpFAQ6Q => _t('helpFAQ6Q');
  String get helpFAQ6A => _t('helpFAQ6A');
  String get helpSectionResources => _t('helpSectionResources');
  String get helpUserGuideTitle => _t('helpUserGuideTitle');
  String get helpUserGuideSubtitle => _t('helpUserGuideSubtitle');
  String get helpVideoTutorialsTitle => _t('helpVideoTutorialsTitle');
  String get helpVideoTutorialsSubtitle => _t('helpVideoTutorialsSubtitle');
  String get helpBlogUpdatesTitle => _t('helpBlogUpdatesTitle');
  String get helpBlogUpdatesSubtitle => _t('helpBlogUpdatesSubtitle');
  String get helpSectionCommunity => _t('helpSectionCommunity');
  String get helpFeatureRequestsTitle => _t('helpFeatureRequestsTitle');
  String get helpFeatureRequestsSubtitle => _t('helpFeatureRequestsSubtitle');
  String get helpBugDialogTitle => _t('helpBugDialogTitle');
  String get helpBugTitleLabel => _t('helpBugTitleLabel');
  String get helpDescriptionLabel => _t('helpDescriptionLabel');
  String get helpCancel => _t('helpCancel');
  String get helpSubmit => _t('helpSubmit');
  String get helpBugSubmitted => _t('helpBugSubmitted');
  String get helpFeatureDialogTitle => _t('helpFeatureDialogTitle');
  String get helpFeatureTitleLabel => _t('helpFeatureTitleLabel');
  String get helpFeatureSubmitted => _t('helpFeatureSubmitted');
  String get helpEmailCopied => _t('helpEmailCopied');
  String get helpOpeningUserGuide => _t('helpOpeningUserGuide');
  String get helpOpeningVideoTutorials => _t('helpOpeningVideoTutorials');
  String get helpOpeningBlog => _t('helpOpeningBlog');

  // ── About ────────────────────────────────────────────────────────────────────
  String get aboutTitle => _t('aboutTitle');
  String get aboutAppSubtitle => _t('aboutAppSubtitle');
  String get aboutCardTitle => _t('aboutCardTitle');
  String get aboutCardBody => _t('aboutCardBody');
  String get aboutSectionFeatures => _t('aboutSectionFeatures');
  String get aboutFeature1Title => _t('aboutFeature1Title');
  String get aboutFeature1Desc => _t('aboutFeature1Desc');
  String get aboutFeature2Title => _t('aboutFeature2Title');
  String get aboutFeature2Desc => _t('aboutFeature2Desc');
  String get aboutFeature3Title => _t('aboutFeature3Title');
  String get aboutFeature3Desc => _t('aboutFeature3Desc');
  String get aboutFeature4Title => _t('aboutFeature4Title');
  String get aboutFeature4Desc => _t('aboutFeature4Desc');
  String get aboutInfoDeveloper => _t('aboutInfoDeveloper');
  String get aboutInfoPlatform => _t('aboutInfoPlatform');
  String get aboutInfoReleased => _t('aboutInfoReleased');
  String get aboutInfoContact => _t('aboutInfoContact');
  String get aboutCopyright => _t('aboutCopyright');

  // ── Links screen ─────────────────────────────────────────────────────────────
  String get linksTitle => _t('linksTitle');
  String get linksOpenLinkTitle => _t('linksOpenLinkTitle');
  String get linksUrlLabel => _t('linksUrlLabel');
  String get linksCopyUrl => _t('linksCopyUrl');
  String get linksClose => _t('linksClose');
  String get linksUrlCopied => _t('linksUrlCopied');
  String get linksErrorLoading => _t('linksErrorLoading');
  String get linksNoCategoriesTitle => _t('linksNoCategoriesTitle');
  String get linksNoCategoriesSubtitle => _t('linksNoCategoriesSubtitle');

  // ── Profile screen ───────────────────────────────────────────────────────────
  String get profileEditName => _t('profileEditName');
  String get profileEnterNameHint => _t('profileEnterNameHint');
  String get profileCancel => _t('profileCancel');
  String get profileSave => _t('profileSave');
  String get profileOpeningGallery => _t('profileOpeningGallery');
  String get profileUploadingImage => _t('profileUploadingImage');
  String get profileImageUpdated => _t('profileImageUpdated');
  String get profileImageTooLarge => _t('profileImageTooLarge');
  String get profileFailedUpload => _t('profileFailedUpload');
  String get profileStorageError => _t('profileStorageError');
  String get profilePermissionError => _t('profilePermissionError');
  String get profileNetworkError => _t('profileNetworkError');
  String get profileUserIdCopied => _t('profileUserIdCopied');
  String get profileSectionAccount => _t('profileSectionAccount');
  String get profileSectionSubscription => _t('profileSectionSubscription');
  String get profileSectionSupport => _t('profileSectionSupport');
  String get profileRowEmail => _t('profileRowEmail');
  String get profileRowMemberSince => _t('profileRowMemberSince');
  String get profileRowUserId => _t('profileRowUserId');
  String get profileRowPlan => _t('profileRowPlan');
  String get profileSubActive => _t('profileSubActive');
  String get profileRowGetHelp => _t('profileRowGetHelp');
  String get profileComingSoon => _t('profileComingSoon');
  String get profileLogOut => _t('profileLogOut');

  // ── Tab bar ──────────────────────────────────────────────────────────────────
  String get tabLinks => _t('tabLinks');
  String get tabSettings => _t('tabSettings');
  String get tabProfile => _t('tabProfile');

  // ── Notification permission sheet ────────────────────────────────────────────
  String get notifPermTitle => _t('notifPermTitle');
  String get notifPermBody => _t('notifPermBody');
  String get notifPermAllow => _t('notifPermAllow');
  String get notifPermNotNow => _t('notifPermNotNow');
}

// ── Delegate ──────────────────────────────────────────────────────────────────

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ko'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
