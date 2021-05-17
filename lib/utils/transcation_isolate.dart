import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../models/transaction.dart';

Queue<Transaction> taskQueue = Queue();
Queue<Transaction> projectQueue = Queue();

Future<void> initiateHandler(SendPort port) async {
  final ReceivePort transactionReceivePort = ReceivePort();
  port.send(transactionReceivePort.sendPort);
  transactionReceivePort
      .listen((tx) => _enqueueTransaction(port, tx as Transaction));
  Timer.periodic(const Duration(seconds: 5), (_) async {
    try {
      final result =
          await InternetAddress.lookup('taskflow1-4a77f.firebaseio.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        await processTaskTransactions();
      }
    } on SocketException {
      debugPrint('not connected');
    }
  });
  // processGoalTransactions();
  // processProjectTransactions();
}

void _enqueueTransaction(SendPort port, Transaction transaction) {
  switch (transaction.dataType) {
    case DataType.task:
      taskQueue.add(transaction);
      break;
    case DataType.project:
    case DataType.subTask:
      projectQueue.add(transaction);
      break;
    default:
      break;
  }
  port.send('Returning data from transaction isolate');
}

Future<void> processTaskTransactions() async {
  if (taskQueue.isNotEmpty) {
    final Transaction t = taskQueue.removeFirst();

    if (t.transactionType == TransactionType.update) {
      late String dataUrl;
      switch (t.dataType) {
        case DataType.task:
          dataUrl =
              "https://taskflow1-4a77f.firebaseio.com/Users/${t.uid}/tasks/-M_voWL4fx6w8EzNVlTd/timestamp.json?auth=${t.token}";
          break;
        default:
      }

      final Uri url = Uri.parse(dataUrl);
      final firebaseTaskTime =
          json.decode((await http.get(url)).body) as String?;
      final DateTime firebaseTaskDate =
          DateFormat("dd-MM-yyyy HH:mm:ss").parse(firebaseTaskTime!);

      if (firebaseTaskDate.isBefore(t.timeStamp)) {
        final Uri taskUrl = Uri.parse(
            "https://taskflow1-4a77f.firebaseio.com/Users/${t.uid}/tasks/-M_voWL4fx6w8EzNVlTd.json?auth=${t.token}");
        t.data['timestamp'] =
            DateFormat("dd-MM-yyyy HH:mm:ss").format(t.timeStamp);
        t.data['id'] = null;

        await http.patch(
          taskUrl,
          body: json.encode(t.data),
        );
        debugPrint('task update transaction successful');
      }
    } else {
      final Uri taskUrl = Uri.parse(
          "https://taskflow1-4a77f.firebaseio.com/Users/${t.uid}/tasks.json?auth=${t.token}");
      await http.post(
        taskUrl,
        body: json.encode({
          'title': t.data['title'],
          'start': t.data['start'],
          'category': t.data['category'],
          'isRunning': t.data['isRunning'],
          'isPaused': t.data['isPaused'],
          'timestamp': DateFormat("dd-MM-yyyy HH:mm:ss").format(t.timeStamp)
        }),
      );
    }
  }
}

void processProjectTransactions() {
  final Transaction t = projectQueue.removeFirst();
}
