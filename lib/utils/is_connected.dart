import 'package:connectivity/connectivity.dart';

Future<bool> isConnected() async {
  final connectivityState = await Connectivity().checkConnectivity();
  return connectivityState != ConnectivityResult.none;
}
