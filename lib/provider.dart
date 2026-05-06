import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

class AppProvider extends ChangeNotifier {
  AppState _state = AppState.initial();
  static const String _storageKey = 'limon_v2_data';

  AppState get state => _state;
  Wallet get activeWallet => _state.wallets[_state.activeWalletId]!;

  AppProvider() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_storageKey);
    if (data != null) {
      try {
        _state = AppState.fromJson(jsonDecode(data));
        notifyListeners();
      } catch (e) {
        debugPrint('Load Error: \$e');
      }
    }
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(_state.toJson()));
    notifyListeners();
  }

  void updateSettings({String? name, String? currency, double? budget}) {
    if (name != null) _state.user = name;
    if (currency != null) _state.currency = currency;
    if (budget != null) activeWallet.budget = budget;
    _saveToPrefs();
  }

  void toggleTheme() {
    _state.isDarkMode = !_state.isDarkMode;
    _saveToPrefs();
  }

  void switchWallet(String id) {
    if (_state.wallets.containsKey(id)) {
      _state.activeWalletId = id;
      _saveToPrefs();
    }
  }

  void createWallet(String name) {
    final id = 'wallet_${DateTime.now().millisecondsSinceEpoch}';
    _state.wallets[id] = Wallet(id: id, name: name, budget: 0, transactions: []);
    _state.activeWalletId = id;
    _saveToPrefs();
  }

  void deleteWallet(String id) {
    if (_state.wallets.length > 1 && id != _state.activeWalletId) {
      _state.wallets.remove(id);
      _saveToPrefs();
    }
  }

  void addTransaction(Transaction tx) {
    activeWallet.transactions.add(tx);
    _saveToPrefs();
  }

  void deleteTransaction(String id) {
    activeWallet.transactions.removeWhere((tx) => tx.id == id);
    _saveToPrefs();
  }

  void resetAll() {
    _state = AppState.initial();
    _saveToPrefs();
  }

  void restoreFromJson(String jsonString) {
    try {
      _state = AppState.fromJson(jsonDecode(jsonString));
      _saveToPrefs();
    } catch (e) {
      throw Exception('Invalid Backup Format');
    }
  }
}
