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

Future<void> initiateHandler(List<SendPort> port) async {
  final ReceivePort transactionReceivePort = ReceivePort();
  port[0].send(transactionReceivePort.sendPort);
  transactionReceivePort.listen((data) {
    if (data is Transaction) {
      _enqueueTransaction(port[0], data);
    } else if (data is Queue<Transaction>) {
      if (data.isNotEmpty) {
        data.first.dataType == DataType.task
            ? taskQueue = data
            : projectQueue = data;
      }
    }
  });

  Timer.periodic(const Duration(seconds: 5), (_) async {
    try {
      final result =
          await InternetAddress.lookup('taskflow1-4a77f.firebaseio.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        await processTaskTransactions(port[0], port[1]);
      }
    } on SocketException {
      // debugPrint('not connected');
    }
  });
  // processGoalTransactions();
  // processProjectTransactions();
}

void _enqueueTransaction(SendPort port, Transaction transaction) {
  switch (transaction.dataType) {
    case DataType.task:
      taskQueue.add(transaction);
      port.send(taskQueue);
      break;
    case DataType.project:
    case DataType.subTask:
      projectQueue.add(transaction);
      port.send(projectQueue);
      break;
    default:
      break;
  }
}

Future<void> processTaskTransactions(
    SendPort mainPort, SendPort appPort) async {
  bool isBehind = false;
  while (taskQueue.isNotEmpty) {
    final Transaction t = taskQueue.first;
    try {
      if (t.transactionType == TransactionType.update) {
        late String dataUrl;
        switch (t.dataType) {
          case DataType.task:
            dataUrl =
                "https://taskflow1-4a77f.firebaseio.com/Users/${t.uid}/tasks/${t.objectId}/timestamp.json?auth=${t.token}";
            break;
          default:
        }

        final Uri url = Uri.parse(dataUrl);
        final firebaseTaskTime =
            json.decode((await http.get(url)).body) as String?;
        final DateTime firebaseTaskDate =
            DateFormat("dd-MM-yyyy HH:mm:ss").parse(firebaseTaskTime!);

        if (firebaseTaskDate.isBefore(t.timeStamp)) {
          print('${t.data}');
          final Uri taskUrl = Uri.parse(
              "https://taskflow1-4a77f.firebaseio.com/Users/${t.uid}/tasks/${t.objectId}.json?auth=${t.token}");
          t.data['timestamp'] =
              DateFormat("dd-MM-yyyy HH:mm:ss").format(t.timeStamp);
          await http.patch(
            taskUrl,
            body: json.encode(t.data),
          );
        } else {
          print(
              'Firebase time: $firebaseTaskDate and Task time: ${t.timeStamp}');
          isBehind = true;
        }
      } else {
        final Uri taskUrl = Uri.parse(
            "https://taskflow1-4a77f.firebaseio.com/Users/${t.uid}/tasks/${t.objectId}.json?auth=${t.token}");
        await http.put(
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
      if (taskQueue.isNotEmpty) {
        print("I removed");
        taskQueue.removeFirst();
      }
      if (taskQueue.isEmpty && isBehind) {
        print("queue empty now pull from firebase");
        appPort.send("pullFromFireBase");
      }
    } catch (e) {
      rethrow;
    } finally {
      mainPort.send(taskQueue);
    }
  }
}

void processProjectTransactions() {
  // final Transaction t = projectQueue.removeFirst();
}
