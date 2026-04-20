import 'package:app_tact/colors.dart';
import 'package:app_tact/l10n/app_localizations.dart';
import 'package:app_tact/services/language_service.dart';
import 'package:app_tact/services/subscription_service.dart';
import 'package:app_tact/services/theme_service.dart';
import 'package:app_tact/theme/app_theme.dart';
import 'package:app_tact/widgets/about_screen.dart';
import 'package:app_tact/widgets/email_verification_screen.dart';
import 'package:app_tact/widgets/help_support_screen.dart';
import 'package:app_tact/widgets/home.dart';
import 'package:app_tact/widgets/links.dart';
import 'package:app_tact/widgets/login.dart';
import 'package:app_tact/widgets/signup.dart';
import 'package:app_tact/widgets/splash_screen.dart';
import 'package:app_tact/widgets/theme_picker_screen.dart';
import 'package:app_tact/widgets/user_guide_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  try {
    final iosKey = dotenv.env['REVENUECAT_IOS_API_KEY'];
    final androidKey = dotenv.env['REVENUECAT_ANDROID_API_KEY'];
    final uid = FirebaseAuth.instance.currentUser?.uid;
    await SubscriptionService.instance.init(
      iosApiKey: iosKey,
      androidApiKey: androidKey,
      appUserId: uid,
      enableDebugLogs: false,
    );
  } catch (_) {}
  await LanguageService.init();
  await appThemeController.loadTheme();
  runApp(
    ThemeControllerScope(
      controller: appThemeController,
      child: const MyApp(),
    ),
  );
}

class SwipePageRouteBuilder<T> extends PageRouteBuilder<T> {
  final Widget page;

  SwipePageRouteBuilder({
    required this.page,
    super.settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 200),
          reverseTransitionDuration: const Duration(milliseconds: 200),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return AnimatedBuilder(
              animation: animation,
              child: child,
              builder: (context, child) {
                final slideValue = animation.value;
                final screenWidth = MediaQuery.of(context).size.width;
                final isDark = Theme.of(context).brightness == Brightness.dark;

                return Transform.translate(
                  offset: Offset((1.0 - slideValue) * screenWidth, 0),
                  child: Container(
                    width: screenWidth,
                    height: MediaQuery.of(context).size.height,
                    decoration: BoxDecoration(
                      gradient: isDark
                          ? const LinearGradient(
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                              colors: [Color(0xFF0B0E1D), Color(0xFF2E2939)],
                            )
                          : const LinearGradient(
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                              colors: [Color(0xFFF3F1FF), Color(0xFFEDE9FF)],
                            ),
                    ),
                    child: child,
                  ),
                );
              },
            );
          },
        );

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    final result = page;
    return _SwipeGestureDetector<T>(
      route: this,
      child: result,
    );
  }
}

class _SwipeGestureDetector<T> extends StatefulWidget {
  const _SwipeGestureDetector({
    required this.route,
    required this.child,
  });

  final PageRoute<T> route;
  final Widget child;

  @override
  _SwipeGestureDetectorState<T> createState() =>
      _SwipeGestureDetectorState<T>();
}

class _SwipeGestureDetectorState<T> extends State<_SwipeGestureDetector<T>>
    with TickerProviderStateMixin {
  late AnimationController _gestureController;
  late Animation<Offset> _gestureAnimation;

  @override
  void initState() {
    super.initState();
    _gestureController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _gestureAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(1.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _gestureController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _gestureController.dispose();
    super.dispose();
  }

  void _handleDragStart(DragStartDetails details) {
    if (details.globalPosition.dx < 20) {
      _gestureController.reset();
    }
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (details.globalPosition.dx < 20 ||
        _gestureController.status == AnimationStatus.forward) {
      final progress =
          details.primaryDelta! / MediaQuery.of(context).size.width;
      _gestureController.value =
          (_gestureController.value + progress).clamp(0.0, 1.0);
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    const double threshold = 0.3;
    const double velocity = 1.0;

    if (_gestureController.value > threshold ||
        details.velocity.pixelsPerSecond.dx > velocity * 1000) {
      _gestureController.forward().then((_) {
        if (mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      });
    } else {
      _gestureController.reverse();
    }
  }

  void _handleDragCancel() {
    _gestureController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: _handleDragStart,
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: _handleDragEnd,
      onHorizontalDragCancel: _handleDragCancel,
      child: AnimatedBuilder(
        animation: _gestureAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              _gestureAnimation.value.dx * MediaQuery.of(context).size.width,
              0,
            ),
            child: widget.child,
          );
        },
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Route<dynamic>? _createSmoothRoute(RouteSettings settings) {
    Widget page;

    switch (settings.name) {
      case '/':
      case '/splash':
        page = const SplashScreen();
        break;
      case '/home':
        page = const HomeScreen();
        break;
      case '/login':
        page = const LoginScreen();
        break;
      case '/signup':
        page = const SignupScreen();
        break;
      case '/verify':
        page = const EmailVerificationScreen();
        break;
      case '/links':
        page = const Links();
        break;
      case '/theme-picker':
        page = const ThemePickerScreen();
        break;
      case '/help-support':
        page = const HelpSupportScreen();
        break;
      case '/user-guide':
        page = const UserGuideScreen();
        break;
      case '/about':
        page = const AboutScreen();
        break;
      default:
        return null;
    }

    return SwipePageRouteBuilder(
      page: page,
      settings: settings,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeController = ThemeControllerScope.of(context);
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return AnimatedBuilder(
          animation:
              Listenable.merge([themeController, LanguageService.locale]),
          builder: (context, _) => MaterialApp(
            debugShowCheckedModeBanner: false,
            locale: LanguageService.locale.value,
            supportedLocales: const [Locale('en'), Locale('ko')],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            themeMode: themeController.themeMode,
            themeAnimationDuration: const Duration(milliseconds: 200),
            themeAnimationCurve: Curves.easeOutCubic,
            theme: ThemeData(
              useMaterial3: true,
              colorSchemeSeed: AppColors.accentPurple,
              brightness: Brightness.light,
              scaffoldBackgroundColor: Colors.transparent,
              textTheme:
                  GoogleFonts.interTextTheme(ThemeData.light().textTheme),
              fontFamily: GoogleFonts.inter().fontFamily,
              pageTransitionsTheme: const PageTransitionsTheme(
                builders: {
                  TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                  TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
                },
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorSchemeSeed: AppColors.accentPurple,
              brightness: Brightness.dark,
              scaffoldBackgroundColor: Colors.transparent,
              textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
              fontFamily: GoogleFonts.inter().fontFamily,
              pageTransitionsTheme: const PageTransitionsTheme(
                builders: {
                  TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                  TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
                },
              ),
            ),
            title: 'Sticker Note App',
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: context.appBackgroundGradient,
                ),
                child: child,
              );
            },
            home: const SplashScreen(),
            onGenerateRoute: (RouteSettings settings) {
              return _createSmoothRoute(settings);
            },
          ),
        );
      },
    );
  }
}
