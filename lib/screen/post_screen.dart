import 'package:L3P1/model/constant.dart';
import 'package:L3P1/model/photomemo.dart';
import 'package:L3P1/screen/myview/myimage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PostScreen extends StatefulWidget {
  static const routeName = '/postScreen';
  @override
  State<StatefulWidget> createState() {
    return _PostScreenState();
  }
}

class _PostScreenState extends State<PostScreen> {
  _Controller con;
  User user;
  List<PhotoMemo> photoMemoList;

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
      body: ListView.builder(
        itemCount: photoMemoList.length,
        itemBuilder: (context, index) => Card(
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
              Text('TEST TEST TEST TEST'),
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
    );
  }
}

class _Controller {
  _PostScreenState state;
  _Controller(this.state);
}
