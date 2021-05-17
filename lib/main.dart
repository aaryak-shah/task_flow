import 'dart:io';
import 'dart:isolate';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as dot_env;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:task_flow/utils/transcation_isolate.dart';

import 'providers/auth_service.dart';
import 'providers/goals.dart';
import 'providers/projects.dart';
import 'providers/settings.dart';
import 'providers/tasks.dart';
import 'providers/theme_switcher.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final path = await getApplicationDocumentsDirectory();
  // create the tasks.csv file if it doesn't exist
  final File f = File('${path.path}/tasks.csv');
  if (!f.existsSync()) {
    f.writeAsStringSync('');
  }

  final File f2 = File('${path.path}/projects.csv');
  if (!f2.existsSync()) {
    f2.writeAsStringSync('');
  }

  await dot_env.load();
  final ReceivePort mainIsolateReceivePort = ReceivePort();
  SendPort transactionSendPort;
  await Isolate.spawn(initiateHandler, mainIsolateReceivePort.sendPort);
  mainIsolateReceivePort.listen((dynamic data) {
    if (data is SendPort) {
      transactionSendPort = data;
      runApp(App(transactionSendPort));
    }
  });
}

class App extends StatefulWidget {
  // This widget is the root of your application.
  final SendPort transactionSendPort;
  const App(this.transactionSendPort);
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  bool isAuth = false;
  bool isInit = true;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthService(FirebaseAuth.instance),
        ),
        StreamProvider(
          initialData: null,
          create: (context) => context.read<AuthService>().authStateChanges,
        ),
        ChangeNotifierProvider(
          create: (context) => Tasks(
            context: context,
            transactionSendPort: widget.transactionSendPort,
          ), //passing context for calling Auth provider in Tasks
        ),
        ChangeNotifierProvider(
          create: (context) => Goals(
            context: context,
            transactionSendPort: widget.transactionSendPort,
          ), //passing context for calling Auth provider in Goals
        ),
        ChangeNotifierProvider(
          create: (context) => Projects(
            context: context,
            transactionSendPort: widget.transactionSendPort,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => ThemeModel(),
        ),
        ChangeNotifierProvider(
          create: (context) => Settings(),
        ),
      ],
      builder: (context, _) => AuthenticationWrapper(context),
    );
  }
}

class AuthenticationWrapper extends StatefulWidget {
  final BuildContext ctx;
  const AuthenticationWrapper(this.ctx);
  @override
  _AuthenticationWrapperState createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper> {
  bool isGuest = false;

  @override
  Widget build(BuildContext context) {
    final firebaseUser = Provider.of<User?>(widget.ctx);
    return FutureBuilder<bool>(
      future: Provider.of<AuthService>(widget.ctx).isGuest,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Login();
        } else {
          if ((snapshot.data!) ||
              (firebaseUser != null && firebaseUser.emailVerified)) {
            return HomeScreen();
          } else {
            return const Login();
          }
        }
      },
    );
  }
}

class Login extends StatelessWidget {
  const Login({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(
      builder: (context, themeModel, _) => MaterialApp(
        theme: themeModel.currentTheme,
        home: LoginScreen(),
      ),
    );
  }
}
