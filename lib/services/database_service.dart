import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/schema.dart';

class DatabaseService {
  late Isar isar;

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [UserSettingsSchema, WalletSchema, TransactionSchema],
      directory: dir.path,
    );

    // Ensure default settings and wallet exist
    if (await isar.userSettings.count() == 0) {
      await isar.writeTxn(() async {
        await isar.userSettings.put(UserSettings());
        await isar.wallets.put(Wallet()..name = 'Main Wallet');
      });
    }
  }

  Future<UserSettings> getSettings() async {
    return (await isar.userSettings.where().findFirst())!;
  }

  Future<void> updateSettings(UserSettings settings) async {
    await isar.writeTxn(() => isar.userSettings.put(settings));
  }

  Future<List<Wallet>> getAllWallets() async {
    return await isar.wallets.where().findAll();
  }

  Future<void> addWallet(String name) async {
    await isar.writeTxn(() => isar.wallets.put(Wallet()..name = name));
  }

  Future<void> deleteWallet(int id) async {
    await isar.writeTxn(() => isar.wallets.delete(id));
  }

  Future<void> addTransaction(Transaction tx, int walletId) async {
    final wallet = await isar.wallets.get(walletId);
    if (wallet != null) {
      await isar.writeTxn(() async {
        await isar.transactions.put(tx);
        tx.wallet.value = wallet;
        await tx.wallet.save();
      });
    }
  }

  Future<List<Transaction>> getTransactionsByWallet(int walletId) async {
    return await isar.transactions.filter().wallet((q) => q.idEqualTo(walletId)).sortByDateDesc().findAll();
  }

  Future<void> deleteTransaction(int id) async {
    await isar.writeTxn(() => isar.transactions.delete(id));
  }

  Future<void> clearAll() async {
    await isar.writeTxn(() => isar.clear());
  }
}