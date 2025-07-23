import 'package:app_sticker_note/colors.dart';
import 'package:app_sticker_note/widgets/login.dart';
import 'package:app_sticker_note/widgets/signup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
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
          },
        );
      },
    );
  }
}
