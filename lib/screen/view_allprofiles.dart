import 'package:L3P1/controller/firebasecontroller.dart';
import 'package:L3P1/model/constant.dart';
import 'package:L3P1/model/profile.dart';
import 'package:L3P1/screen/myview/mydialog.dart';
import 'package:L3P1/screen/profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ViewAllProfileScreen extends StatefulWidget {
  static const routeName = '/viewAllProfilesScreen';
  @override
  State<StatefulWidget> createState() {
    return _ViewAllProfileState();
  }
}

class _ViewAllProfileState extends State<ViewAllProfileScreen> {
  _Controller con;
  String progMessage;
  List<Profile> profileList;
  int index = 0;
  User user;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }

  void render(fn) => setState(fn);

  Widget build(BuildContext context) {
    Map args = ModalRoute.of(context).settings.arguments;
    profileList ??= args[Constant.ARG_PROFILELIST];
    user ??= args[Constant.ARG_USER];
    // photoLikeList ??= args[Constant.ARG_PHOTOMEMOLIKE];
    return Scaffold(
      appBar: AppBar(
        title: Text('View All Users'),
      ),
      body: ListView.builder(
        itemCount: profileList.length,
        itemBuilder: (context, index) => GestureDetector(
          child: ListTile(
            leading: Image.asset('images/small_profile.png'),
            trailing: Icon(Icons.keyboard_arrow_right),
            title: Text(
              '${profileList[index].email}',
              style: Theme.of(context).textTheme.headline6,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Signed Up On: ${profileList[index].signUpDate}'),
              ],
            ),
            onTap: () => con.onTap(profileList[index]),
          ),
        ),
      ),
    );
  }
}

class _Controller {
  _Controller(this.state);
  _ViewAllProfileState state;
  String email;

  void onTap(Profile profile) async {
    await Navigator.pushNamed(
      state.context,
      ProfileScreen.routeName,
      arguments: {
        Constant.ARG_ONE_PROFILE: profile,
        Constant.ARG_USER: state.user
      },
    );
    state.render(() {});
  }
}
