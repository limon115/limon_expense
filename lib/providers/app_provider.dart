import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/schema.dart';
import '../services/database_service.dart';

class AppProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  
  UserSettings? _settings;
  List<Wallet> _wallets = [];
  List<Transaction> _currentTransactions = [];
  int _activeWalletIndex = 0;

  UserSettings? get settings => _settings;
  List<Wallet> get wallets => _wallets;
  List<Transaction> get transactions => _currentTransactions;
  Wallet get activeWallet => _wallets.isNotEmpty ? _wallets[_activeWalletIndex] : Wallet()..name = 'Loading';

  final List<String> expenseCategories = ['Food', 'Transport', 'Shopping', 'Bills', 'Entertainment', 'Health', 'Education', 'Utilities', 'Other'];
  final List<String> incomeCategories = ['Salary', 'Allowance', 'Business', 'Freelance', 'Investment', 'Gift', 'Bonus', 'Other'];

  Future<void> initialize() async {
    await _db.init();
    await refreshData();
  }

  Future<void> refreshData() async {
    _settings = await _db.getSettings();
    _wallets = await _db.getAllWallets();
    if (_wallets.isNotEmpty) {
      _currentTransactions = await _db.getTransactionsByWallet(activeWallet.id);
    }
    notifyListeners();
  }

  void setActiveWallet(int index) {
    _activeWalletIndex = index;
    refreshData();
  }

  Future<void> addWallet(String name) async {
    await _db.addWallet(name);
    await refreshData();
  }

  Future<void> addTx(String title, double amount, String category, String type, DateTime date) async {
    final tx = Transaction()
      ..title = title
      ..amount = amount
      ..category = category
      ..type = type
      ..date = date;
    await _db.addTransaction(tx, activeWallet.id);
    await refreshData();
  }

  Future<void> deleteTx(int id) async {
    await _db.deleteTransaction(id);
    await refreshData();
  }

  Future<void> updateUserSettings(String name, String currency, double budget, bool dark) async {
    _settings!.userName = name;
    _settings!.currency = currency;
    _settings!.monthlyBudget = budget;
    _settings!.isDarkMode = dark;
    await _db.updateSettings(_settings!);
    notifyListeners();
  }

  String exportBackup() {
    // Simple JSON export simulation for brevity, in production iterate all wallets/txs
    return jsonEncode({
      'user': _settings!.userName,
      'currency': _settings!.currency,
      'transactions_count': _currentTransactions.length
    });
  }

  Future<void> resetAll() async {
    await _db.clearAll();
    await initialize();
  }
}