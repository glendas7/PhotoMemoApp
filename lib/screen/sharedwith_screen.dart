import 'package:L3P1/controller/firebasecontroller.dart';
import 'package:L3P1/model/constant.dart';
import 'package:L3P1/model/photocomment.dart';
import 'package:L3P1/model/photomemo.dart';
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
  User user;
  List<PhotoMemo> photoMemoList;
  List<PhotoComment> photoCommentList;
  _Controller con;
  String progMessage;

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }

  void render(fn) => setState(fn);

  Widget build(BuildContext context) {
    Map args = ModalRoute.of(context).settings.arguments;
    user ??= args[Constant.ARG_USER];
    photoMemoList ??= args[Constant.ARG_PHOTOMEMOLIST];

    return Scaffold(
      appBar: AppBar(
        title: Text('Shared With Me'),
      ),
      body: photoMemoList.length == 0
          ? Text(
              'No PhotoMemos shared with me 😭',
              style: Theme.of(context).textTheme.headline5,
            )
          : ListView.builder(
              itemCount: photoMemoList.length,
              itemBuilder: (context, index) => GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailScreen(
                        memo: photoMemoList[index],
                        cont: con,
                      ),
                    ),
                  );
                },
                child: Card(
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
                      Text('Created By: ${photoMemoList[index].createdBy}'),
                      Text('Updated At: ${photoMemoList[index].timestamp}'),
                      Text('Shared With: ${photoMemoList[index].sharedWith}'),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class DetailScreen extends StatelessWidget {
  final PhotoMemo memo;
  final _Controller cont;

  DetailScreen({Key key, @required this.memo, @required this.cont})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use the Todo to create the UI.
    return Scaffold(
      appBar: AppBar(
        title: Text(memo.title),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          cont.addComment(memo.docId);
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
      tempComment.createdBy = state.user.email;
      tempComment.memoId = memo;

      String docId = await FirebaseController.addPhotoComment(tempComment);
      tempComment.docId = docId;
      // state.photoCommentList.insert(0, tempComment);

      MyDialog.circularProgressStop(state.context);
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

  void addComment(String value) {
    memo = value;

    showDialog(
        context: state.context,
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Create an account'),
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
                      Text('Create a Comment',
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
