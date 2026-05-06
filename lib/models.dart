import 'dart:convert';

class AppState {
  String user;
  String currency;
  bool isDarkMode;
  String activeWalletId;
  Map<String, Wallet> wallets;

  AppState({
    this.user = 'User',
    this.currency = '\$',
    this.isDarkMode = false,
    this.activeWalletId = 'default',
    required this.wallets,
  });

  factory AppState.initial() {
    return AppState(
      wallets: {
        'default': Wallet(
          id: 'default',
          name: 'Main Wallet',
          budget: 0,
          transactions: [],
        ),
      },
    );
  }

  Map<String, dynamic> toJson() => {
        'user': user,
        'currency': currency,
        'isDarkMode': isDarkMode,
        'activeWalletId': activeWalletId,
        'wallets': wallets.map((k, v) => MapEntry(k, v.toJson())),
      };

  factory AppState.fromJson(Map<String, dynamic> json) {
    var walletMap = (json['wallets'] as Map<String, dynamic>).map(
      (k, v) => MapEntry(k, Wallet.fromJson(v as Map<String, dynamic>)),
    );
    return AppState(
      user: json['user'] ?? 'User',
      currency: json['currency'] ?? '\$',
      isDarkMode: json['isDarkMode'] ?? false,
      activeWalletId: json['activeWalletId'] ?? 'default',
      wallets: walletMap,
    );
  }
}

class Wallet {
  String id;
  String name;
  double budget;
  List<Transaction> transactions;

  Wallet({
    required this.id,
    required this.name,
    required this.budget,
    required this.transactions,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'budget': budget,
        'transactions': transactions.map((t) => t.toJson()).toList(),
      };

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id'],
      name: json['name'],
      budget: (json['budget'] as num).toDouble(),
      transactions: (json['transactions'] as List)
          .map((t) => Transaction.fromJson(t))
          .toList(),
    );
  }
}

class Transaction {
  String id;
  String type;
  double amount;
  String title;
  String category;
  DateTime date;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.title,
    required this.category,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'amount': amount,
        'title': title,
        'category': category,
        'date': date.toIso8601String(),
      };

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      type: json['type'],
      amount: (json['amount'] as num).toDouble(),
      title: json['title'],
      category: json['category'],
      date: DateTime.parse(json['date']),
    );
  }
}
