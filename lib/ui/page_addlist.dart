import 'dart:async';
import 'package:flutter/services.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'package:connectivity/connectivity.dart';

class NewTaskPage extends StatefulWidget {
  final FirebaseUser user;

  NewTaskPage({Key key, this.user}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _NewTaskPageState();
}

class _NewTaskPageState extends State<NewTaskPage> {
  TextEditingController listNameController = new TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Color pickerColor = Color(0xff6633ff);
  Color currentColor = Color(0xff6633ff);

  ValueChanged<Color> onColorChanged;

  bool _saving = false;

  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = new Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  Future<Null> initConnectivity() async {
    String connectionStatus;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      connectionStatus = (await _connectivity.checkConnectivity()).toString();
    } on PlatformException catch (e) {
      print(e.toString());
      connectionStatus = 'Failed to get connectivity.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return;
    }

    setState(() {
      _connectionStatus = connectionStatus;
    });
  }

  void addToFirebase() async {
    setState(() {
      _saving = true;
    });

    print(_connectionStatus);

    if (_connectionStatus == "ConnectivityResult.none") {
      showInSnackBar("No internet connection currently available");
      setState(() {
        _saving = false;
      });
    } else {
      bool isExist = false;

      QuerySnapshot query =
          await Firestore.instance.collection(widget.user.uid).getDocuments();

      query.documents.forEach((doc) {
        if (listNameController.text.toString() == doc.documentID) {
          isExist = true;
        }
      });

      if (isExist == false && listNameController.text.isNotEmpty) {
        print(currentColor.value.toString());
        print(DateTime.now().millisecondsSinceEpoch);
        await Firestore.instance
            .collection(widget.user.uid)
            .document(listNameController.text.toString().trim())
            .setData({
          "color": currentColor.value.toString(),
          "date": DateTime.now().millisecondsSinceEpoch
        });

        listNameController.clear();

        pickerColor = Color(0xff6633ff);
        currentColor = Color(0xff6633ff);

        Navigator.of(context).pop();
      }
      if (isExist == true) {
        showInSnackBar("This list already exists");
        setState(() {
          _saving = false;
        });
      }
      if (listNameController.text.isEmpty) {
        showInSnackBar("Please enter a name");
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final _autoColor =
        currentColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: pickerColor,
      body: ModalProgressHUD(
          child: new Stack(
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildHeader(context, _autoColor),
                  Padding(
                    padding:
                        EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
                    child: new Column(
                      children: <Widget>[
                        new TextFormField(
                          decoration: InputDecoration(
                            labelText: "Name",
                            labelStyle: TextStyle(color: _autoColor),
                          ),
                          controller: listNameController,
                          autofocus: true,
                          style: TextStyle(
                            fontSize: 22.0,
                            color: _autoColor,
                            fontWeight: FontWeight.w500,
                          ),
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.sentences,
                        ),
                        new Padding(
                          padding: EdgeInsets.only(bottom: 10.0),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            RichText(
                              text: TextSpan(
                                  text: "Task color: ",
                                  style: Theme.of(context)
                                      .textTheme
                                      .body1
                                      .merge(TextStyle(color: _autoColor)),
                                  children: [
                                    TextSpan(
                                      text:
                                          "#${currentColor.toString().substring(8, 14)}",
                                      style: Theme.of(context)
                                          .textTheme
                                          .subhead
                                          .merge(TextStyle(color: _autoColor)),
                                    ),
                                  ]),
                            ),
                            OutlineButton.icon(
                              icon: Icon(Icons.color_lens),
                              label: Text("Change"),
                              textColor: currentColor.computeLuminance() > 0.5
                                  ? Colors.black
                                  : Colors.white,
                              onPressed: () {
                                pickerColor = currentColor;
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text(
                                        'Pick a color',
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle,
                                      ),
                                      content: SingleChildScrollView(
                                        child: ColorPicker(
                                          pickerColor: pickerColor,
                                          onColorChanged: changeColor,
                                          enableLabel: true,
                                          colorPickerWidth: 300.0,
                                          pickerAreaHeightPercent: 0.7,
                                          paletteType: PaletteType.hsl,
                                        ),
                                      ),
                                      actions: <Widget>[
                                        RaisedButton(
                                          child: Text('Got it'),
                                          onPressed: () {
                                            setState(() =>
                                                currentColor = pickerColor);
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 15.0),
                      child: FloatingActionButton.extended(
                        backgroundColor: Color(0xff2A25D7),
                        label: Padding(
                          padding:
                              const EdgeInsets.only(left: 32.0, right: 32.0),
                          child: Text(
                            'Add',
                            style: Theme.of(context).textTheme.body1.merge(
                                  TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                          ),
                        ),
                        onPressed: addToFirebase,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          inAsyncCall: _saving),
    );
  }

  changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  Widget _buildHeader(BuildContext context, Color _autoColor) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 30.0),
          InkWell(
            child: Icon(
              Icons.arrow_back_ios,
              color: _autoColor,
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          Text(
            "Add",
            style: Theme.of(context)
                .textTheme
                .title
                .merge(TextStyle(color: _autoColor)),
          ),
          Text(
            "new task",
            style: Theme.of(context)
                .textTheme
                .subtitle
                .merge(TextStyle(color: _autoColor)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scaffoldKey.currentState?.dispose();
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        _connectionStatus = result.toString();
      });
    });
  }

  void showInSnackBar(String value) {
    _scaffoldKey.currentState?.removeCurrentSnackBar();

    _scaffoldKey.currentState?.showSnackBar(new SnackBar(
      content: new Text(value, textAlign: TextAlign.center),
      backgroundColor: currentColor,
      duration: Duration(seconds: 3),
    ));
  }
}
