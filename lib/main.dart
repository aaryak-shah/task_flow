import 'dart:collection';
import 'dart:io';
import 'dart:isolate';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as dot_env;
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:task_flow/models/task.dart';
import 'package:task_flow/models/transaction.dart';
import 'package:task_flow/utils/transcation_isolate.dart';
import 'package:hive_flutter/hive_flutter.dart';

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
  final ReceivePort appReceivePort = ReceivePort();
  SendPort transactionSendPort;

  await Isolate.spawn(initiateHandler, [
    mainIsolateReceivePort.sendPort,
    appReceivePort.sendPort,
  ]);
  mainIsolateReceivePort.listen((dynamic data) async {
    if (data is SendPort) {
      transactionSendPort = data;
      await Hive.initFlutter();
      Hive.registerAdapter(TaskAdapter());
      Hive.registerAdapter(SyncStatusAdapter());
      Hive.registerAdapter(TransactionTypeAdapter());
      Hive.registerAdapter(DataTypeAdapter());
      Hive.registerAdapter(TransactionAdapter());
      final taskTransactionBox = await Hive.openBox('taskTransactionBox');
      final projectTransactionBox = await Hive.openBox('projectTransactionBox');
      final List<Transaction> taskList = [];
      final List<Transaction> projectList = [];
      taskTransactionBox.toMap().forEach((key, tx) {
        taskList.add(tx as Transaction);
      });
      taskList.sort((a, b) => a.timeStamp.isBefore(b.timeStamp) ? 0 : 1);
      // projectTransactionBox.toMap().forEach((key, tx) {
      //   projectList.add(tx as Transaction);
      // });
      // projectList.sort((a, b) => a.timeStamp.isBefore(b.timeStamp) ? 1 : 0);

      transactionSendPort.send(Queue<Transaction>.from(taskList));
      transactionSendPort.send(Queue<Transaction>.from(projectList));
      runApp(App(transactionSendPort, appReceivePort));
    } else if (data is Queue<Transaction>) {
      final taskTransactionBox = await Hive.openBox('taskTransactionBox');
      final projectTransactionBox = await Hive.openBox('projectTransactionBox');
      if (data.isNotEmpty) {
        if (data.first.dataType == DataType.task) {
          taskTransactionBox.putAll({
            for (Transaction t in data)
              t.timeStamp.millisecondsSinceEpoch ~/ 1000: t
          });
        } else {
          projectTransactionBox.putAll({
            for (Transaction t in data)
              t.timeStamp.millisecondsSinceEpoch ~/ 1000: t
          });
        }
      } else {
        debugPrint('Box is empty');
      }
    }
  });
}

class App extends StatefulWidget {
  // This widget is the root of your application.
  final SendPort transactionSendPort;
  final ReceivePort appReceivePort;
  const App(this.transactionSendPort, this.appReceivePort);
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  bool isAuth = false;
  bool isInit = true;
  bool isLoaded = false;
  Box<Task>? taskBox;
  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      taskBox = await Hive.openBox('taskBox');
      setState(() {
        isLoaded = true;
      });
    });
    super.initState();
  }

  // @override
  // void didChangeDependencies() {
  //   // TODO: implement didChangeDependencies
  //   super.didChangeDependencies();
  // }

  @override
  Widget build(BuildContext context) {
    return !isLoaded
        ? const Center(child: CircularProgressIndicator())
        : MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) => AuthService(FirebaseAuth.instance),
              ),
              StreamProvider(
                initialData: null,
                create: (context) =>
                    context.read<AuthService>().authStateChanges,
              ),
              ChangeNotifierProvider(
                create: (context) => Tasks(
                  box: taskBox!,
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
            builder: (context, _) => AuthenticationWrapper(context, widget.appReceivePort),
          );
  }
}

class AuthenticationWrapper extends StatefulWidget {
  final BuildContext ctx;
  final ReceivePort appReceivePort;
  const AuthenticationWrapper(this.ctx, this.appReceivePort);
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
            return HomeScreen(widget.appReceivePort);
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
