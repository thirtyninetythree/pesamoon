import 'package:flutter/material.dart';
import 'package:pesamoon/providers/address_book.dart';

import 'package:provider/provider.dart';

import 'package:pesamoon/providers/blockchain_provider.dart';

import 'package:pesamoon/pages/qr_scan.dart';

class Send extends StatefulWidget {
  const Send({Key? key}) : super(key: key);

  @override
  State<Send> createState() => _SendState();
}

class _SendState extends State<Send> {
  int _amount = 0;
  final _to = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AddressBooks>(context, listen: false);
    provider.read();
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TextFormField(
            controller: _to,
            decoration: InputDecoration(
                labelText: "To",
                isDense: true,
                border: const UnderlineInputBorder(),
                suffixIcon: Padding(
                  padding: const EdgeInsetsDirectional.only(end: 12.0),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween, // added line
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                          onPressed: () {
                            showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return provider.addressList.isEmpty
                                      ? const Center(
                                          child: Text(
                                          "No addresses yet",
                                          style: TextStyle(fontSize: 32.0),
                                        ))
                                      : ListView.builder(
                                          itemCount:
                                              provider.addressList.length,
                                          itemBuilder: (context, int index) {
                                            return ListTile(
                                              onTap: () {
                                                setState(() {
                                                  _to.text = provider
                                                      .addressList[index]
                                                      .address;
                                                });
                                                Navigator.pop(context);
                                              },
                                              title: Text(
                                                provider
                                                    .addressList[index].name,
                                                style: const TextStyle(
                                                    color: Colors.black),
                                              ),
                                              subtitle: Text(provider
                                                  .addressList[index].address),
                                            );
                                          });
                                });
                          },
                          icon: const Icon(Icons.content_paste)),
                      IconButton(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              // Create the SelectionScreen in the next step.
                              MaterialPageRoute(
                                  builder: (context) => const QRScan()),
                            );
                            // final result =
                            //     Navigator.pushNamed(context, QRScan.routeName);
                            setState(() {
                              _to.text = result as String;
                            });
                          },
                          icon: const Icon(Icons.qr_code)),
                      const SizedBox(
                        width: 4.0,
                      ),
                      //CREATE A FORM
                      IconButton(
                          onPressed: () => _to.text.isEmpty
                              ? null
                              : showDialog(
                                  context: context,
                                  builder: (context) {
                                    String name = "";
                                    return AlertDialog(
                                      title: const Text("Add New Address"),
                                      content: SizedBox(
                                        height: 150.0,
                                        child: Form(
                                          key: _formKey,
                                          child: Column(
                                            children: <Widget>[
                                              Text(_to.text),
                                              TextFormField(
                                                onSaved: (String? value) {
                                                  name = value!;
                                                },
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return 'Please enter some text';
                                                  }
                                                  return null;
                                                },
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  // Validate returns true if the form is valid, or false otherwise.
                                                  if (_formKey.currentState!
                                                      .validate()) {
                                                    _formKey.currentState
                                                        ?.save();
                                                    provider.create(AddressBook(
                                                        address: _to.text,
                                                        name: name));
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                          content: Text(
                                                              'Processing Data')),
                                                    );
                                                  }
                                                },
                                                child: const Text("SAVE"),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      elevation: 10.0,
                                      actions: [
                                        TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              _to.clear();
                                            },
                                            child: const Text("DONE")),
                                      ],
                                    );
                                  }),
                          icon: const Icon(Icons.add))
                    ],
                  ),
                )),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TextField(
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.all(8.0),
              labelText: "Amount",
              hintText: "0.00",
              border: UnderlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                _amount = int.tryParse(value)!;
              });
            },
          ),
        ),
        OutlinedButton(
          onPressed: () {
            if (_amount <= 0 || !_to.text.startsWith("0")) {
              showDialog(
                  barrierDismissible: true,
                  context: context,
                  builder: (_) => AlertDialog(
                        title: const Text("Transaction Fail"),
                        content: const Text(
                            "Check address format or amount can not be less than zero "),
                        elevation: 10.0,
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("DONE"))
                        ],
                      ));
              _to.clear();
              _amount = 0;
              return;
            }
            context
                .read<BlockchainProvider>()
                .sendTx(_to.text, _amount)
                .whenComplete(() => showDialog(
                    barrierDismissible: true,
                    context: context,
                    builder: (_) => AlertDialog(
                          title: const Text("Transaction Successful"),
                          content: const Image(
                            height: 200.0,
                            image: AssetImage("assets/gif/done_animated.gif"),
                          ),
                          elevation: 10.0,
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _to.clear();
                                  _amount = 0;
                                },
                                child: const Text("DONE"))
                          ],
                        )));
          },
          child: const Text(
            "SEND",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0),
          ),
          style: ButtonStyle(
              padding: MaterialStateProperty.all(const EdgeInsets.all(8.0)),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                      side: const BorderSide(color: Colors.red)))),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _to.dispose();
    super.dispose();
  }
}
