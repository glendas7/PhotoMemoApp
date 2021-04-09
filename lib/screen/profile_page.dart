import 'dart:io';
import 'package:L3P1/model/constant.dart';
import 'package:L3P1/model/profile.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = './profileScreen';
  @override
  State<StatefulWidget> createState() {
    return _ProfileState();
  }
}

class _ProfileState extends State<ProfileScreen> {
  Profile profile;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String progressMessage;

  @override
  void initState() {
    super.initState();
  }

  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    Map args = ModalRoute.of(context).settings.arguments;
    profile ??= args[Constant.ARG_ONE_PROFILE];

    return Scaffold(
      appBar: AppBar(
        title: Text('${profile.email}'),
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
                  'Title: ${profile.email}',
                  style: Theme.of(context).textTheme.headline6,
                ),
                Text('Name: ${profile.name}'),
                Text('Member Since: ${profile.signUpDate}'),
                Text('About Me: ${profile.description}'),
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
