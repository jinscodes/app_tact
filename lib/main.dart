import 'package:app_sticker_note/colors.dart';
import 'package:app_sticker_note/widgets/create_note.dart';
import 'package:app_sticker_note/widgets/home.dart';
import 'package:app_sticker_note/widgets/login.dart';
import 'package:app_sticker_note/widgets/manage_cate.dart';
import 'package:app_sticker_note/widgets/signup.dart';
import 'package:app_sticker_note/widgets/splash_screen.dart';
import 'package:app_sticker_note/widgets/verify.dart';
import 'package:app_sticker_note/widgets/welcome.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
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
        page = const VerifyScreen();
        break;
      case '/welcome':
        page = const WelcomeScreen();
        break;
      case '/manage-category':
        page = const ManageCategoryScreen();
        break;
      case '/create-note':
        page = const CreateNote();
        break;
      default:
        return null;
    }

    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 280),
      reverseTransitionDuration: const Duration(milliseconds: 250),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;

        var slideTween = Tween(begin: begin, end: end);
        var slideAnimation = animation.drive(slideTween);

        var opacityTween = Tween(begin: 0.0, end: 1.0);
        var opacityAnimation = animation.drive(opacityTween);

        return FadeTransition(
          opacity: opacityAnimation,
          child: SlideTransition(
            position: slideAnimation,
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: ThemeMode.system,
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: AppColors.baseBlack,
            brightness: Brightness.light,
            scaffoldBackgroundColor: Colors.transparent,
            textTheme: GoogleFonts.interTextTheme(),
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
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [Color(0xFF0B0E1D), Color(0xFF2E2939)],
                ),
              ),
              child: child,
            );
          },
          home: const SplashScreen(),
          onGenerateRoute: (RouteSettings settings) {
            return _createSmoothRoute(settings);
          },
        );
      },
    );
  }
}
