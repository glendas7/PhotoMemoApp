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
        actions: [
          Form(
            key: formKey,
            child: Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Container(
                width: MediaQuery.of(context).size.width * .7,
                child: TextFormField(
                  decoration: InputDecoration(
                    fillColor: Theme.of(context).backgroundColor,
                    filled: true,
                    hintText: 'Search',
                  ),
                  autocorrect: true,
                  onSaved: con.saveSearch,
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: con.search,
          ),
        ],
        // title: Text('View All Users'),
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
  String searchEmail;

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

  void saveSearch(String value) {
    searchEmail = value;
    print(searchEmail);
  }

  void search() async {
    state.formKey.currentState.save();
    var keys = searchEmail.split(' ').toList();
    print(keys);
    List<String> searchKeys = [];
    for (var k in keys) {
      if (k.trim().isNotEmpty) searchKeys.add(k.trim().toLowerCase());
    }
    try {
      List<Profile> results;
      if (searchKeys.isNotEmpty) {
        results =
            await FirebaseController.searchUsers(searchLabels: searchKeys);
      } else {
        results = await FirebaseController.getProfileList();
      }
      state.render(() => state.profileList = results);
    } catch (e) {
      MyDialog.info(
          context: state.context, title: 'Search Error', content: '$e');
    }
  }
}
