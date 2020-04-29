import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taskist/ui/page_addlist.dart';
import 'package:taskist/ui/page_done.dart';
import 'package:taskist/ui/page_settings.dart';
import 'package:taskist/ui/page_task.dart';

Future<Null> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _currentUser = await _signInAnonymously();

  runApp(new TaskistApp());
}

final FirebaseAuth _auth = FirebaseAuth.instance;

FirebaseUser _currentUser;

Future<FirebaseUser> _signInAnonymously() async {
  final user = await _auth.signInAnonymously();
  return user.user;
}

class HomePage extends StatefulWidget {
  final FirebaseUser user;

  HomePage({Key key, this.user}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class TaskistApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Taskist",
      home: HomePage(
        user: _currentUser,
      ),
      theme: ThemeData(
        textTheme: TextTheme(
          title: GoogleFonts.poppins(
            textStyle: TextStyle(
              fontSize: 60.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: GoogleFonts.oxygen(
            textStyle: TextStyle(
              fontSize: 27.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          subhead: GoogleFonts.oxygen(
            textStyle: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          headline: GoogleFonts.oxygen(
            textStyle: TextStyle(fontSize: 26.0, fontWeight: FontWeight.w600),
          ),
          body1: GoogleFonts.openSans(
            textStyle: TextStyle(
              fontSize: 16.0,
            ),
          ),
        ),
        primarySwatch: Colors.amber,
        primaryColor: Colors.black,
      ),
    );
  }
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 1;

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                "Taskist",
                style: Theme.of(context).textTheme.title,
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    _currentIndex = _currentIndex == 2 ? 1 : 2;
                  });
                },
                child: Icon(
                  Icons.settings,
                  size: 30.0,
                ),
              ),
            ],
          ),
          InkWell(
            onTap: () {
              setState(() {
                _currentIndex = _currentIndex == 1 ? 0 : 1;
              });
            },
            child: Text(
              _currentIndex == 1
                  ? "All tasks"
                  : _currentIndex == 0 ? "Completed tasks" : 'Settings',
              style: Theme.of(context).textTheme.subtitle,
            ),
          ),
        ],
      ),
    );
  }

  final List<Widget> _children = [
    DonePage(
      user: _currentUser,
    ),
    TaskPage(
      user: _currentUser,
    ),
    SettingsPage(
      user: _currentUser,
    )
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              child: _buildHeader(context),
            ),
            Container(
              height: MediaQuery.of(context).size.height,
              child: _children[_currentIndex],
            )
          ],
        ),
      ),
      floatingActionButton: _currentIndex != 2
          ? FloatingActionButton.extended(
              backgroundColor: Color(0xff2A25D7),
              label: Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                child: Text(
                  'Add new task',
                  style: Theme.of(context).textTheme.body1.merge(
                        TextStyle(
                          color: Colors.white,
                        ),
                      ),
                ),
              ),
              onPressed: _addTask,
            )
          : Container(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _addTask() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewTaskPage(
          user: _currentUser,
        ),
      ),
    );
  }
}
