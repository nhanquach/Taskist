import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:taskist/model/element.dart';
import 'package:taskist/ui/page_detail.dart';
import 'package:google_fonts/google_fonts.dart';

class TaskPage extends StatefulWidget {
  final FirebaseUser user;

  TaskPage({Key key, this.user}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage>
    with SingleTickerProviderStateMixin {
  int index = 1;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Container(
          height: MediaQuery.of(context).size.height - 240,
          padding: EdgeInsets.only(bottom: 25.0),
          child: NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (overscroll) {
              overscroll.disallowGlow();
            },
            child: new StreamBuilder<QuerySnapshot>(
                stream: Firestore.instance
                    .collection(widget.user.uid)
                    .orderBy("date", descending: true)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData)
                    return new Center(
                      child: CircularProgressIndicator(
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                    );

                  if (snapshot.data.documents.length == 0) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "Enjoy",
                            style: GoogleFonts.homemadeApple().merge(
                              TextStyle(
                                fontSize: 60.0,
                              ),
                            ),
                          ),
                          Text(
                            "Your task is empty",
                            style: Theme.of(context).textTheme.subhead,
                          ),
                        ],
                      ),
                    );
                  }

                  return new ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(left: 20.0, right: 40.0),
                    scrollDirection: Axis.horizontal,
                    children: getExpenseItems(snapshot),
                  );
                }),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  getExpenseItems(AsyncSnapshot<QuerySnapshot> snapshot) {
    List<ElementTask> listElement = new List(), listElement2;
    Map<String, List<ElementTask>> userMap = new Map();

    List<String> cardColor = new List();

    if (widget.user.uid.isNotEmpty) {
      cardColor.clear();

      snapshot.data.documents.map<List>((f) {
        String color;
        f.data.forEach((a, b) {
          if (b.runtimeType == bool) {
            listElement.add(new ElementTask(a, b));
          }
          if (b.runtimeType == String && a == "color") {
            color = b;
          }
        });
        listElement2 = new List<ElementTask>.from(listElement);
        for (int i = 0; i < listElement2.length; i++) {
          if (listElement2.elementAt(i).isDone == false) {
            userMap[f.documentID] = listElement2;
            cardColor.add(color);
            break;
          }
        }
        if (listElement2.length == 0) {
          userMap[f.documentID] = listElement2;
          cardColor.add(color);
        }
        listElement.clear();
      }).toList();

      return new List.generate(userMap.length, (int index) {
        final _cardColor = Color(int.parse(cardColor.elementAt(index)));
        final _autoColor =
            _cardColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
        final hasItem = userMap.values.elementAt(index).length > 0;

        return new GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              new PageRouteBuilder(
                pageBuilder: (_, __, ___) => new DetailPage(
                  user: widget.user,
                  i: index,
                  currentList: userMap,
                  color: cardColor.elementAt(index),
                ),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) =>
                        new ScaleTransition(
                  scale: new Tween<double>(
                    begin: 1.5,
                    end: 1.0,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Interval(
                        0.50,
                        1.00,
                        curve: Curves.linear,
                      ),
                    ),
                  ),
                  child: ScaleTransition(
                    scale: Tween<double>(
                      begin: 0.0,
                      end: 1.0,
                    ).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Interval(
                          0.00,
                          0.50,
                          curve: Curves.linear,
                        ),
                      ),
                    ),
                    child: child,
                  ),
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
              ),
              color: _cardColor,
              elevation: 5,
              child: Container(
                width: 260.0,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                          top: 20.0, bottom: 5.0, left: 5.0, right: 5.0),
                      child: Container(
                        child: Text(
                          userMap.keys.elementAt(index),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.homemadeApple().merge(
                            TextStyle(
                              color: _autoColor,
                              fontSize: 19.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.only(
                              top: 10.0, left: 15.0, right: 5.0, bottom: 10.0),
                          child: !hasItem
                              ? Text(
                                  "Empty",
                                  style: TextStyle(
                                    color: _autoColor,
                                  ),
                                )
                              : SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height - 380,
                                  child: ListView.builder(
                                    itemCount:
                                        userMap.values.elementAt(index).length,
                                    itemBuilder: (BuildContext ctxt, int i) {
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Icon(
                                            userMap.values
                                                    .elementAt(index)
                                                    .elementAt(i)
                                                    .isDone
                                                ? Icons.check_circle
                                                : FontAwesomeIcons.circle,
                                            color: userMap.values
                                                    .elementAt(index)
                                                    .elementAt(i)
                                                    .isDone
                                                ? _autoColor.withAlpha(100)
                                                : _autoColor,
                                            size: 14.0,
                                          ),
                                          Padding(
                                            padding:
                                                EdgeInsets.only(left: 10.0),
                                          ),
                                          Flexible(
                                            child: Text(
                                              userMap.values
                                                  .elementAt(index)
                                                  .elementAt(i)
                                                  .name,
                                              style: userMap.values
                                                      .elementAt(index)
                                                      .elementAt(i)
                                                      .isDone
                                                  ? TextStyle(
                                                      decoration: TextDecoration
                                                          .lineThrough,
                                                      color: _autoColor
                                                          .withAlpha(100),
                                                      fontSize: 17.0,
                                                    )
                                                  : TextStyle(
                                                      color: _autoColor,
                                                      fontSize: 17.0,
                                                    ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
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
      });
    }
  }

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
}
