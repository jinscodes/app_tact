import 'package:app_sticker_note/colors.dart';
import 'package:app_sticker_note/widgets/login.dart';
import 'package:app_sticker_note/widgets/signup.dart';
import 'package:app_sticker_note/widgets/verify.dart';
import 'package:app_sticker_note/widgets/welcome.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'services/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    name: "app-sticky-note",
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
            scaffoldBackgroundColor: Colors.white,
          ),
          title: 'Sticker Note App',
          home: LoginScreen(),
          routes: {
            '/login': (context) => const LoginScreen(),
            '/signup': (context) => const SignupScreen(),
            '/verify': (context) => const VerifyScreen(),
            '/welcome': (context) => const WelcomeScreen(),
          },
        );
      },
    );
  }
}
