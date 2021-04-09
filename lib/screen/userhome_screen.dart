import 'package:L3P1/controller/firebasecontroller.dart';
import 'package:L3P1/model/constant.dart';
import 'package:L3P1/model/photocomment.dart';
import 'package:L3P1/model/photomemo.dart';
import 'package:L3P1/model/profile.dart';
import 'package:L3P1/screen/addphotomemo_screen.dart';
import 'package:L3P1/screen/detailedview_screen.dart';
import 'package:L3P1/screen/myview/mydialog.dart';
import 'package:L3P1/screen/myview/myimage.dart';
import 'package:L3P1/screen/profile_page.dart';
import 'package:L3P1/screen/sharedwith_screen.dart';
import 'package:L3P1/screen/view_allprofiles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserHomeScreen extends StatefulWidget {
  static const routeName = '/userHomeScreen';
  @override
  State<StatefulWidget> createState() {
    return _UserHomeState();
  }
}

class _UserHomeState extends State<UserHomeScreen> {
  _Controller con;
  User user;
  int index = 0;
  List<PhotoMemo> photoMemoList;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
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
    photoMemoList ??= args[Constant.ARG_PHOTOMEMOLIST];

    return WillPopScope(
      //android back button disabled
      onWillPop: () => Future.value(false),
      child: Scaffold(
        appBar: AppBar(
          actions: [
            con.delIndex != null
                ? IconButton(
                    icon: Icon(Icons.cancel), onPressed: con.cancelDelete)
                : Form(
                    key: formKey,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width * .7,
                        child: TextFormField(
                          decoration: InputDecoration(
                            fillColor: Theme.of(context).backgroundColor,
                            filled: true,
                            hintText: 'Search',
                          ),
                          autocorrect: true,
                          onSaved: con.saveSearchKeyString,
                        ),
                      ),
                    ),
                  ),
            con.delIndex != null
                ? IconButton(icon: Icon(Icons.delete), onPressed: con.delete)
                : IconButton(
                    icon: Icon(Icons.search),
                    onPressed: con.search,
                  ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              UserAccountsDrawerHeader(
                currentAccountPicture:
                    Icon(Icons.person, size: 100.0), //profile picture
                accountName: null,
                accountEmail: Text(user.email),
                onDetailsPressed: () => {con.viewMyProfile(user)},
              ),
              ListTile(
                leading: Icon(Icons.people),
                title: Text('Shared With Me'),
                onTap: con.sharedWithMe,
              ),
              ListTile(
                leading: Icon(Icons.emoji_people),
                title: Text('View Users'),
                onTap: con.viewAllProfiles,
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('Settings'),
                onTap: null, //con.settings
              ),
              ListTile(
                leading: Icon(Icons.exit_to_app),
                title: Text('SignOut'),
                onTap: con.signOut,
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: con.addButton,
        ),
        body: photoMemoList.length == 0
            ? Text('No PhotoMemos Found!',
                style: Theme.of(context).textTheme.headline5)
            : ListView.builder(
                itemCount: photoMemoList.length,
                itemBuilder: (BuildContext context, index) => Container(
                  color: con.delIndex != null && con.delIndex == index
                      ? Theme.of(context).highlightColor
                      : Theme.of(context).scaffoldBackgroundColor,
                  child: ListTile(
                    leading: MyImage.network(
                        url: photoMemoList[index].photoURL, context: context),
                    trailing: Icon(Icons.keyboard_arrow_right),
                    title: Text(photoMemoList[index].title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(photoMemoList[index].memo.length >= 20
                            ? photoMemoList[index].memo.substring(0, 20) + '...'
                            : photoMemoList[index].memo),
                        Text('Created By: ${photoMemoList[index].createdBy}'),
                        Text('Shared With: ${photoMemoList[index].sharedWith}'),
                        Text('Created On: ${photoMemoList[index].timestamp}'),
                      ],
                    ),
                    onTap: () => con.onTap(index),
                    onLongPress: () => con.onLongPress(index),
                  ),
                ),
              ),
      ),
    );
  }
}

class _Controller {
  _UserHomeState state;
  _Controller(this.state);
  List<PhotoComment> photoCommentList;
  List<Profile> profileList;
  int delIndex;
  String keyString;

  void addButton() async {
    await Navigator.pushNamed(
      state.context,
      AddPhotoMemoScreen.routeName,
      arguments: {
        Constant.ARG_USER: state.user,
        Constant.ARG_PHOTOMEMOLIST: state.photoMemoList
      },
    );
    state.render(() {}); //re render screen/ update screen
  }

  void signOut() async {
    try {
      await FirebaseController.signOut();
    } catch (e) {}
    Navigator.of(state.context).pop(); //close drawer
    Navigator.of(state.context).pop(); //close drawer
  }

  void viewMyProfile(User user) async {
    List<Profile> myProfile =
        await FirebaseController.getOneProfile(user.email);

    Navigator.pushNamed(
      state.context,
      ProfileScreen.routeName,
      arguments: {
        Constant.ARG_ONE_PROFILE: myProfile[1],
      },
    );
    state.render(() {});
  }

  void onTap(int index) async {
    try {
      photoCommentList = await FirebaseController.getPhotoCommentList(
          originalPoster: state.photoMemoList[index].createdBy,
          memoId: state.photoMemoList[index].docId);
    } catch (e) {
      MyDialog.circularProgressStop(state.context);
      MyDialog.info(
          context: state.context,
          title: 'getPhotoCommentList error',
          content: '$e');
    }
    if (delIndex != null) return;
    await Navigator.pushNamed(state.context, DetailedViewScreen.routeName,
        arguments: {
          Constant.ARG_USER: state.user,
          Constant.ARG_ONE_PHOTOMEMO: state.photoMemoList[index],
          Constant.ARG_PHOTOCOMMENTLIST: photoCommentList,
        });
    state.render(() {});
  }

  void sharedWithMe() async {
    try {
      List<PhotoMemo> photoMemoList =
          await FirebaseController.getPhotoMemoSharedWithMe(
        email: state.user.email,
      );
      await Navigator.pushNamed(state.context, SharedWithScreen.routeName,
          arguments: {
            Constant.ARG_USER: state.user,
            Constant.ARG_PHOTOMEMOLIST: photoMemoList,
            Constant.ARG_PHOTOCOMMENTLIST: photoCommentList,
          });
      Navigator.pop(state.context); //closes drawer
    } catch (e) {
      MyDialog.info(
        context: state.context,
        title: 'get Shared PhotoMemo error',
        content: '$e',
      );
    }
  }

  void viewAllProfiles() async {
    try {
      profileList = await FirebaseController.getProfileList();
      await Navigator.pushNamed(state.context, ViewAllProfileScreen.routeName,
          arguments: {
            Constant.ARG_PROFILELIST: profileList,
          });
      Navigator.pop(state.context); //closes drawer
    } catch (e) {
      MyDialog.circularProgressStop(state.context);
      MyDialog.info(
          context: state.context, title: 'getProfileList error', content: '$e');
    }
  }

  void onLongPress(int index) {
    if (delIndex != null) return;
    state.render(() => delIndex = index);
  }

  void cancelDelete() {
    state.render(() => delIndex = null);
  }

  void delete() async {
    try {
      PhotoMemo p = state.photoMemoList[delIndex];
      await FirebaseController.deletePhotoMemo(p);
      state.render(
        () {
          state.photoMemoList.removeAt(delIndex);
          delIndex = null;
        },
      );
    } catch (e) {
      MyDialog.info(
          context: state.context,
          title: 'Delete Photo Memo Error',
          content: '$e');
    }
  }

  void saveSearchKeyString(String value) {
    keyString = value;
  }

  void search() async {
    state.formKey.currentState.save();
    var keys = keyString.split(',').toList();
    List<String> searchKeys = [];
    for (var k in keys) {
      if (k.trim().isNotEmpty) searchKeys.add(k.trim().toLowerCase());
    }
    try {
      List<PhotoMemo> results;
      if (searchKeys.isNotEmpty) {
        results = await FirebaseController.searchImage(
            createdBy: state.user.email, searchLabels: searchKeys);
      } else {
        results =
            await FirebaseController.getPhotoMemoList(email: state.user.email);
      }
      state.render(() => state.photoMemoList = results);
    } catch (e) {
      MyDialog.info(
          context: state.context, title: 'Search Error', content: '$e');
    }
  }
}
