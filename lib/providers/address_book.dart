import 'package:flutter/material.dart';
import 'package:pesamoon/utils/Database.dart';

class AddressBook {
  String address;
  String name;

  AddressBook({required this.address, required this.name});
  Map<String, dynamic> toMap() {
    return {
      "address": address,
      "name": name,
    };
  }

  static AddressBook fromMap(var map) {
    return AddressBook(
      address: map["address"],
      name: map["name"],
    );
  }
}

class AddressBooks with ChangeNotifier {
  List<AddressBook> _addressList = [];
  List<AddressBook> get addressList => _addressList.reversed.toList();

  Future<void> read() async {
    _addressList = await Database.read();
    notifyListeners();
  }

  void create(AddressBook addressBook) async {
    await Database.insert(addressBook);
    read();
    notifyListeners();
  }

  void update(AddressBook addressBook) async {
    await Database.update(addressBook);
    read();
    notifyListeners();
  }

  void delete(String address) async {
    await Database.delete(address);
    read();
    notifyListeners();
  }

  String getName(String address) {
    var contact = _addressList.firstWhere(
        (addressBook) =>
            addressBook.address.toUpperCase() == address.toUpperCase(),
        orElse: () => AddressBook(address: "0x0", name: "UNKNOWN ADDRESS"));
    return contact.name;
  }
}
