import 'dart:developer';
import 'dart:io';
import 'package:L3P1/model/constant.dart';
import 'package:L3P1/model/profile.dart';
import 'package:L3P1/screen/addphotomemo_screen.dart';
import 'package:L3P1/screen/editprofile..dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = './profileScreen';
  @override
  State<StatefulWidget> createState() {
    return _ProfileState();
  }
}

class _ProfileState extends State<ProfileScreen> {
  _Controller con;
  User user;
  Profile profile;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String progressMessage;

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }

  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    Map args = ModalRoute.of(context).settings.arguments;
    profile ??= args[Constant.ARG_ONE_PROFILE];
    user ??= args[Constant.ARG_USER];

    return Scaffold(
      appBar: AppBar(
        title: user.email == profile.email
            ? Text('My Profile')
            : Text('Viewing ${profile.email}`s Profile'),
      ),
      floatingActionButton: FloatingActionButton(
        child: user.email == profile.email
            ? Icon(Icons.edit_outlined)
            : Icon(Icons.insert_emoticon_outlined),
        onPressed: user.email == profile.email
            ? () {
                con.editProfile(profile);
              }
            : null,
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Card(
            elevation: 7.0,
            child: Column(
              children: [
                Center(
                  child: Container(
                    height: MediaQuery.of(context).size.height * .4,
                    child: Image.asset('images/small_profile.png'),
                  ),
                ),
                Text(
                  '${profile.email}',
                  style: Theme.of(context).textTheme.headline6,
                ),
                Text('Name: ${profile.name}', style: TextStyle(fontSize: 30.0)),
                Text('${profile.description}',
                    style: TextStyle(fontSize: 25.0)),
                Text('Member Since: ${profile.signUpDate}',
                    style: TextStyle(fontSize: 15.0)),
                SizedBox(
                  height: 30.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Controller {
  _ProfileState state;
  _Controller(this.state);
  String keyString;

  void editProfile(profile) async {
    await Navigator.pushNamed(
      state.context,
      EditProfileScreen.routeName,
      arguments: {
        Constant.ARG_USER: state.user,
        Constant.ARG_PHOTOMEMOLIST: null,
        Constant.ARG_ONE_PROFILE: profile,
      },
    );
    state.render(() {});
  }
}
