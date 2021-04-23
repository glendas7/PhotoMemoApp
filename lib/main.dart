import 'package:L3P1/model/constant.dart';
import 'package:L3P1/screen/addphotomemo_screen.dart';
import 'package:L3P1/screen/detailedview_screen.dart';
import 'package:L3P1/screen/editprofile..dart';
import 'package:L3P1/screen/profile_page.dart';
import 'package:L3P1/screen/sharedwith_screen.dart';
import 'package:L3P1/screen/signin_screen.dart';
import 'package:L3P1/screen/signup_screen.dart';
import 'package:L3P1/screen/userhome_screen.dart';
import 'package:L3P1/screen/view_allprofiles.dart';
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
        primaryColor: Colors.indigo[800],
      ),
      initialRoute: SignInScreen.routeName,
      routes: {
        SignInScreen.routeName: (context) => SignInScreen(),
        UserHomeScreen.routeName: (context) => UserHomeScreen(),
        AddPhotoMemoScreen.routeName: (context) => AddPhotoMemoScreen(),
        DetailedViewScreen.routeName: (context) => DetailedViewScreen(),
        SignUpScreen.routeName: (context) => SignUpScreen(),
        SharedWithScreen.routeName: (context) => SharedWithScreen(),
        ViewAllProfileScreen.routeName: (context) => ViewAllProfileScreen(),
        ProfileScreen.routeName: (context) => ProfileScreen(),
        EditProfileScreen.routeName: (context) => EditProfileScreen(),
      },
    );
  }
}
