import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 4)
enum TransactionType {
  @HiveField(0)
  create,
  @HiveField(1)
  update,
  @HiveField(2)
  addSubTask,
}
@HiveType(typeId: 5)
enum DataType {
  @HiveField(0)
  task,
  @HiveField(1)
  project,
  @HiveField(2)
  subTask,
}

@HiveType(typeId: 3)
class Transaction {
  @HiveField(0)
  late DateTime timeStamp;
  @HiveField(1)
  late TransactionType transactionType;
  @HiveField(2)
  late DataType dataType;
  @HiveField(3)
  late String uid;
  @HiveField(4)
  late String? token;
  @HiveField(5)
  late Map data;
  @HiveField(6)
  late String objectId;

  Transaction({
    required this.timeStamp,
    required this.transactionType,
    required this.dataType,
    required this.uid,
    required this.token,
    required this.data,
    required this.objectId,
  });

  Transaction.fromMap(Map<String, dynamic> map) {
    timeStamp = map["timeStamp"] as DateTime;
    transactionType = map["transactionType"] as TransactionType;
    dataType = map["dataType"] as DataType;
    uid = map["uid"] as String;
    token = map["token"] as String?;
    data = map["data"] as Map<String, dynamic>;
    objectId = map["objectId"] as String;
  }

  Map<String, dynamic> get asMap {
    return {
      "timeStamp": timeStamp,
      "transactionType": transactionType,
      "dataType": dataType,
      "uid": uid,
      "token": token,
      "data": data,
      "objectId": objectId,
    };
  }
}
