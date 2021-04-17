import 'dart:io';
import 'package:L3P1/controller/firebasecontroller.dart';
import 'package:L3P1/model/constant.dart';
import 'package:L3P1/model/profile.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:L3P1/screen/myview/mydialog.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfileScreen extends StatefulWidget {
  static const routeName = '/editProfileScreen';
  @override
  State<StatefulWidget> createState() {
    return _EditProfileState();
  }
}

class _EditProfileState extends State<EditProfileScreen> {
  _Controller con;
  User user;
  List<Profile> profileList;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  File photo;
  Profile profile;
  Profile tempProfile;
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
    user ??= args[Constant.ARG_USER];
    profile ??= args[Constant.ARG_ONE_PROFILE];
    tempProfile ??= Profile.clone(profile);

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: con.save,
          ),
        ],
      ),
      body: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  children: [
                    Text(
                      'Update Your Profile',
                      style: TextStyle(fontFamily: 'Satisfy', fontSize: 35.0),
                    ),
                  ],
                ),
                progressMessage == null
                    ? SizedBox(height: 1.0)
                    : Text(
                        progressMessage,
                        style: Theme.of(context).textTheme.headline6,
                      ),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: profile.name == "" ? 'Name' : '${profile.name}',
                  ),
                  autocorrect: true,
                  onSaved: con.saveName,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: profile.description == ""
                        ? 'Description'
                        : '${profile.description}',
                  ),
                  autocorrect: true,
                  keyboardType: TextInputType.multiline,
                  maxLines: 6,
                  onSaved: con.saveDescription,
                ),
              ],
            ),
          )),
    );
  }
}

class _Controller {
  _EditProfileState state;
  _Controller(this.state);

  void save() async {
    if (!state.formKey.currentState.validate()) return;
    state.formKey.currentState.save();
    try {
      MyDialog.circularProgressStart(state.context);
      Map<String, dynamic> updateInfo = {};
      if (state.profile.description != state.tempProfile.description)
        updateInfo[Profile.DESCRIPTION] = state.tempProfile.description;

      if (state.profile.name != state.tempProfile.name)
        updateInfo[Profile.NAME] = state.tempProfile.name;

      updateInfo[Profile.USER_EMAIL] = state.profile.email;
      updateInfo[Profile.SIGNUP_DATE] = state.profile.signUpDate;
      await FirebaseController.updateProfile(state.profile.docId, updateInfo);
      state.profile.assign(state.tempProfile);
      MyDialog.circularProgressStop(state.context);
      Navigator.pop(state.context);
    } catch (e) {
      MyDialog.circularProgressStop(state.context);
      MyDialog.info(
          context: state.context, title: 'Update Profile error', content: '$e');
    }
  }

  void saveName(String value) {
    state.tempProfile.name = value;
  }

  void saveDescription(String value) {
    state.tempProfile.description = value;
  }
}
