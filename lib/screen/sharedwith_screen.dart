import 'package:L3P1/controller/firebasecontroller.dart';
import 'package:L3P1/model/constant.dart';
import 'package:L3P1/model/photomemo.dart';
import 'package:L3P1/screen/addcomment_screen.dart';
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
  _Controller con;

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
                      builder: (context) =>
                          DetailScreen(memo: photoMemoList[index], cont: con),
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
        onPressed: cont.addComment,
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

  void addComment() {
    showDialog(
        context: state.context,
        builder: (BuildContext context) {
          return AlertDialog(
            scrollable: true,
            title: Text('Comment'),
            content: Padding(
              padding: const EdgeInsets.all(0.0),
              child: Form(
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Message',
                        icon: Icon(Icons.message),
                      ),
                      maxLines: 20,
                      minLines: 5,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              RaisedButton(
                child: Text("Back"),
                onPressed: () {
                  Navigator.pop(state.context);
                  // your code
                },
              ),
              RaisedButton(
                child: Text("Submit"),
                onPressed: () {
                  FirebaseController.
                  // your code
                },
              ),
            ],
          );
        });
  }

  void submitComment() async {
    await Navigator.pushNamed(
      state.context,
      AddCommentScreen.routeName,
      arguments: {
        Constant.ARG_USER: state.user,
        Constant.ARG_PHOTOMEMOLIST: state.photoMemoList
      },
    );
    state.render(() {}); //re render screen/ update screen
  }

}
