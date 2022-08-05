import 'package:pesamoon/providers/address_book.dart';
import "package:sembast/sembast_io.dart";
import "package:sembast/sembast.dart";
import "package:path_provider/path_provider.dart" as path;
import "package:path/path.dart";

class Database {
  static StoreRef<int, Map<String, dynamic>> addressBookStore() =>
      intMapStoreFactory.store("address_book");

  static Future database() async {
    var dir = await path.getApplicationDocumentsDirectory();
    await dir.create(recursive: true);
    var dbPath = join(dir.path, "address_book.db");
    var db = await databaseFactoryIo.openDatabase(dbPath);
    return db;
  }

  static Future insert(AddressBook addressBook) async {
    final db = await database();
    var store = addressBookStore();
    return await store.add(db, addressBook.toMap());
  }

  static Future update(AddressBook addressBook) async {
    final db = await database();
    var store = addressBookStore();
    var filter = Filter.matches("address", addressBook.address);
    var finder = Finder(filter: filter);
    return await store.update(db, addressBook.toMap(), finder: finder);
  }

  static Future<List<AddressBook>> read() async {
    final db = await database();
    var store = addressBookStore();
    final snapshots = await store.find(db);
    return List.generate(snapshots.length, (int index) {
      return AddressBook.fromMap(snapshots[index]);
    });
  }

  static Future delete(String address) async {
    final db = await database();
    var store = addressBookStore();
    var filter = Filter.matches("address", address);
    var finder = Finder(filter: filter);
    return await store.delete(db, finder: finder);
  }
}
