import 'package:L3P1/model/constant.dart';
import 'package:L3P1/screen/addphotomemo_screen.dart';
import 'package:L3P1/screen/detailedview_screen.dart';
import 'package:L3P1/screen/post_screen.dart';
import 'package:L3P1/screen/sharedwith_screen.dart';
import 'package:L3P1/screen/signin_screen.dart';
import 'package:L3P1/screen/signup_screen.dart';
import 'package:L3P1/screen/userhome_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(PhotoMemoApp());
}

class PhotoMemoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: Constant.DEV,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.purpleAccent,
      ),
      initialRoute: SignInScreen.routeName,
      routes: {
        SignInScreen.routeName: (context) => SignInScreen(),
        UserHomeScreen.routeName: (context) => UserHomeScreen(),
        AddPhotoMemoScreen.routeName: (context) => AddPhotoMemoScreen(),
        DetailedViewScreen.routeName: (context) => DetailedViewScreen(),
        SignUpScreen.routeName: (context) => SignUpScreen(),
        SharedWithScreen.routeName: (context) => SharedWithScreen(),
        PostScreen.routeName: (context) => PostScreen(),
      },
    );
  }
}
