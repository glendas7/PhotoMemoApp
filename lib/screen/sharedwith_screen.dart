import 'package:L3P1/controller/firebasecontroller.dart';
import 'package:L3P1/model/constant.dart';
import 'package:L3P1/model/photocomment.dart';
import 'package:L3P1/model/photolike.dart';
import 'package:L3P1/model/photomemo.dart';
import 'package:L3P1/model/profile.dart';
import 'package:L3P1/screen/myview/mydialog.dart';
import 'package:L3P1/screen/myview/myimage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SharedWithScreen extends StatefulWidget {
  static const routeName = '/sharedWithScreen';
  @override
  State<StatefulWidget> createState() {
    return _SharedWithState();
  }
}

class _SharedWithState extends State<SharedWithScreen> {
  bool liked = false;
  List<PhotoMemo> photoMemoList;
  User user;
  List<PhotoComment> photoCommentList;
  _Controller con;
  String progMessage;
  Profile tempProfile;
  List<String> users;
  String _selectedEmail = '';

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }

  Future<String> updateVisitDate(DateTime timestamp) async {
    List<Profile> profile = await FirebaseController.getOneProfile(user.email);
    try {
      Map<String, dynamic> updateInfo = {};
      updateInfo[Profile.DESCRIPTION] = profile[0].description;
      updateInfo[Profile.NAME] = profile[0].name;
      updateInfo[Profile.USER_EMAIL] = profile[0].email;
      updateInfo[Profile.SIGNUP_DATE] = profile[0].signUpDate;
      updateInfo[Profile.LAST_HOME_VISIT] = profile[0].lastVisitedHome;
      updateInfo[Profile.LAST_SHAREDPAGE_VISIT] = DateTime.now();

      await FirebaseController.updateProfile(profile[0].docId, updateInfo);
    } catch (e) {
      return null;
    }
    if (profile[0].lastVisitedShared == null) return 'new';
    if (timestamp.isAfter(profile[0].lastVisitedShared)) {
      return 'new';
    } else {
      return 'old';
    }
  }

  void getCommentList(int index) async {
    try {
      photoCommentList = await FirebaseController.getPhotoCommentList(
          originalPoster: photoMemoList[index].createdBy,
          memoId: photoMemoList[index].docId);
    } catch (e) {
      MyDialog.circularProgressStop(context);
      MyDialog.info(
          context: context, title: 'getPhotoCommentList error', content: '$e');
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailScreen(
          memo: photoMemoList[index],
          cont: con,
          photoCommentList: photoCommentList,
          user: user,
        ),
      ),
    );
  }

  void render(fn) => setState(fn);

  Widget build(BuildContext context) {
    Map args = ModalRoute.of(context).settings.arguments;
    user ??= args[Constant.ARG_USER];
    photoMemoList ??= args[Constant.ARG_PHOTOMEMOLIST];
    users ??= args[Constant.ARG_TAGGEDME];

    return Scaffold(
      appBar: AppBar(
        title: Text('Shared With Me'),
        actions: [
          PopupMenuButton(
            itemBuilder: (BuildContext bc) {
              return users
                  .map((user) => PopupMenuItem(
                        child: Text(user),
                        value: user,
                      ))
                  .toList();
            },
            onSelected: (value) {
              setState(() {
                _selectedEmail = value;
              });
            },
          ),
        ],
      ),
      body: _selectedEmail == ''
          ? Padding(
              padding: const EdgeInsets.fromLTRB(25, 6, 2, 0),
              child: Text('Use the menu To Choose ^ What Memories to View! ',
                  style: TextStyle(fontFamily: 'RockSalt', fontSize: 25.0)),
            )
          : ListView.builder(
              itemCount: photoMemoList.length,
              itemBuilder: (context, index) => GestureDetector(
                onTap: () {
                  getCommentList(index);
                },
                child: photoMemoList[index].createdBy == _selectedEmail
                    ? Card(
                        elevation: 7.0,
                        child: Column(
                          children: [
                            Center(
                              child: Container(
                                height: MediaQuery.of(context).size.height * .4,
                                child: MyImage.network(
                                  url: photoMemoList[index].photoURL,
                                  context: context,
                                ),
                              ),
                            ),
                            Text(
                              'Title: ${photoMemoList[index].title}',
                              style: Theme.of(context).textTheme.headline6,
                            ),
                            Text('Memo: ${photoMemoList[index].memo}'),
                            Text(
                                'Created By: ${photoMemoList[index].createdBy}'),
                            Text(
                                'Updated At: ${photoMemoList[index].timestamp}'),
                            Text(
                                'Shared With: ${photoMemoList[index].sharedWith}'),
                            FutureBuilder<String>(
                              future: updateVisitDate(
                                  photoMemoList[index].timestamp),
                              builder: (BuildContext context,
                                  AsyncSnapshot<String> snapshot) {
                                List<Widget> children;
                                if (snapshot.hasData) {
                                  children = <Widget>[
                                    snapshot.data == 'new'
                                        ? Icon(Icons.fiber_new,
                                            size: 50, color: Colors.green)
                                        : Text('')
                                  ];
                                } else if (snapshot.hasError) {
                                  children = <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 0, left: 0),
                                      child: Text('Error: ${snapshot.error}'),
                                    )
                                  ];
                                } else {
                                  children = const <Widget>[
                                    SizedBox(
                                      child: CircularProgressIndicator(),
                                      width: 60,
                                      height: 60,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: 16),
                                      child: Text('Finding Liked Status...'),
                                    )
                                  ];
                                }
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: children,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      )
                    : Text(''),
              ),
            ),
    );
  }
}

class DetailScreen extends StatelessWidget {
  final PhotoMemo memo;
  final _Controller cont;
  final User user;
  final List<PhotoComment> photoCommentList;

  DetailScreen({
    Key key,
    @required this.memo,
    @required this.cont,
    @required this.photoCommentList,
    @required this.user,
  }) : super(key: key);

  PhotoLike tempLike = PhotoLike();

  void createLike(memoId, context) async {
    List<PhotoLike> result =
        await FirebaseController.checkForLike(user.email, memoId);
    if (result.length == 0) {
      try {
        tempLike.memoId = memoId;
        tempLike.likedBy = user.email;
        tempLike.timestamp = DateTime.now();

        String docId = await FirebaseController.addPhotoLike(tempLike);
        tempLike.docId = docId;
        Navigator.pop(context);
      } catch (e) {}
    }
    if (result.length > 0) {
      print(result[0].docId);
      await FirebaseController.deletePhotoLike(result[0].docId);
      Navigator.pop(context);
    }
  }

  Future<String> checkLikes(String memoId) async {
    List<PhotoLike> result =
        await FirebaseController.checkForLike(user.email, memoId);
    if (result.length == 0) return '';
    return 'Liked';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(memo.title),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          cont.addComment(memo.docId, memo.createdBy);
        },
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          // child: Text(memo.),
          child: Card(
            elevation: 7.0,
            child: Column(
              children: [
                Center(
                  child: Container(
                    height: MediaQuery.of(context).size.height * .4,
                    child: MyImage.network(
                      url: memo.photoURL,
                      context: context,
                    ),
                  ),
                ),
                Text(
                  'Title: ${memo.title}',
                  style: Theme.of(context).textTheme.headline6,
                ),
                Text('Memo: ${memo.memo}'),
                Text('Created By: ${memo.createdBy}'),
                Text('Updated At: ${memo.timestamp}'),
                Text('Shared With: ${memo.sharedWith}'),
                new IconButton(
                    icon: new Icon(
                      Icons.thumb_up_alt_outlined,
                      color: Colors.green,
                      size: 30,
                    ),
                    onPressed: () => createLike(memo.docId, context)),
                FutureBuilder<String>(
                  //LIKE MEMO
                  future: checkLikes(
                    memo.docId,
                  ),
                  builder:
                      (BuildContext context, AsyncSnapshot<String> snapshot) {
                    List<Widget> children;
                    if (snapshot.hasData) {
                      children = <Widget>[
                        Text(
                          '${snapshot.data}',
                          style: TextStyle(fontSize: 20, color: Colors.green),
                        )
                      ];
                    } else if (snapshot.hasError) {
                      children = <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 0, left: 0),
                          child: Text('Error: ${snapshot.error}'),
                        )
                      ];
                    } else {
                      children = const <Widget>[
                        SizedBox(
                          child: CircularProgressIndicator(),
                          width: 60,
                          height: 60,
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 16),
                          child: Text('Finding Liked Status...'),
                        )
                      ];
                    }
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: children,
                      ),
                    );
                  },
                ),
                SizedBox(
                  height: 30.0,
                ),
                Container(
                  color: Colors.indigo[800],
                  child: Row(
                    children: [
                      Text(
                        '        COMMENTS',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 40,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 5.0,
                ),
                photoCommentList.length == 0
                    ? Text('No Comments Found',
                        style: Theme.of(context).textTheme.headline5)
                    : ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: photoCommentList.length,
                        itemBuilder: (BuildContext context, index) => Container(
                          color: index == 0 || index % 2 == 0
                              ? Colors.indigo[200]
                              : Colors.indigo[400],
                          child: ListTile(
                            title: Text(photoCommentList[index].createdBy,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.black,
                                )),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Created On: ${photoCommentList[index].timestamp}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  photoCommentList[index].content,
                                  style: TextStyle(
                                    fontSize: 35,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo[900],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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
  _SharedWithState state;
  _Controller(this.state);

  String memo;
  String originalPoster;
  String content;
  String createdBy;
  var timestamp;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  PhotoComment tempComment = PhotoComment();

  void createComment() async {
    if (!formKey.currentState.validate()) return;
    formKey.currentState.save();
    MyDialog.circularProgressStart(state.context);

    try {
      state.render(() => state.progMessage = "Uploading Comment!");

      tempComment.timestamp = DateTime.now();
      tempComment.originalPoster = originalPoster;
      tempComment.createdBy = state.user.email;
      tempComment.memoId = memo;

      String docId = await FirebaseController.addPhotoComment(tempComment);
      tempComment.docId = docId;
      // state.photoCommentList.insert(0, tempComment);

      MyDialog.circularProgressStop(state.context);
      Navigator.pop(state.context);
      Navigator.pop(state.context);
    } catch (e) {
      MyDialog.circularProgressStop(state.context);
      MyDialog.info(
          context: state.context,
          title: 'Save PhotoComment error',
          content: '$e');
    }
  }

  void saveContent(String value) {
    tempComment.content = value;
  }

  void addComment(String value, String namevalue) {
    memo = value;
    originalPoster = namevalue;

    showDialog(
        context: state.context,
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Create a Comment'),
            ),
            body: Padding(
              padding: const EdgeInsets.only(
                top: 15.0,
                left: 15.0,
                right: 15.0,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Text('Enter your Comment',
                          style: Theme.of(context).textTheme.headline5),
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Enter Comment',
                        ),
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        // validator: con.validateEmail,
                        onSaved: saveContent,
                      ),
                      RaisedButton(
                        onPressed: createComment,
                        child: Text(
                          'Create',
                          style: Theme.of(context).textTheme.button,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }
}
