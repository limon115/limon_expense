import 'package:isar/isar.dart';

part 'schema.g.dart';

@collection
class UserSettings {
  Id id = Isar.autoIncrement;
  String userName = 'User';
  String currency = '$';
  bool isDarkMode = false;
  double monthlyBudget = 0.0;
}

@collection
class Wallet {
  Id id = Isar.autoIncrement;
  late String name;
  double budget = 0.0;

  @Backlink('wallet')
  final transactions = IsarLinks<Transaction>();
}

@collection
class Transaction {
  Id id = Isar.autoIncrement;
  late String title;
  late double amount;
  late DateTime date;
  late String category;
  late String type; // 'income' or 'expense'

  final wallet = IsarLink<Wallet>();
}