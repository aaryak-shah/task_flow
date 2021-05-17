enum TransactionType { create, update, addSubTask }
enum DataType { task, project, subTask }

class Transaction {
  DateTime timeStamp;
  TransactionType transactionType;
  DataType dataType;
  String uid;
  String? token;
  Map data;

  Transaction({
    required this.timeStamp,
    required this.transactionType,
    required this.dataType,
    required this.uid,
    this.token,
    required this.data,
  });
}
