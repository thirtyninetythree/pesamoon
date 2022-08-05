import "package:flutter/material.dart";
import 'package:pesamoon/providers/address_book.dart';
import 'package:pesamoon/widgets/wallet_header.dart';

import 'package:provider/provider.dart';

import 'package:pesamoon/providers/blockchain_provider.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  void initState() {
    super.initState();
    Provider.of<BlockchainProvider>(context, listen: false).fetchTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Consumer<BlockchainProvider>(builder: (context, block, child) {
        return FutureBuilder(
            future: block.getBalance(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError || !snapshot.hasData) {
                  return Text("ERROR ${snapshot.error}");
                }
                return Column(children: [
                  Expanded(
                      flex: 2,
                      child: WalletHeader(
                        name: "Allan",
                        address: block.address,
                        balance: snapshot.data.toString(),
                      )),
                  const Divider(
                    height: 20.0,
                    thickness: 2.0,
                    color: Colors.black12,
                    indent: 10.0,
                    endIndent: 10.0,
                  ),
                  Expanded(
                    flex: 2,
                    child: ListView.builder(
                        itemCount: block.transactions.length,
                        itemBuilder: (context, int index) {
                          return (ExpansionTile(
                            leading: Text(
                                (block.transactions.length - index).toString()),
                            title: Text(
                              "${block.transactions[index].value.getInEther} PMS",
                              style: const TextStyle(
                                fontSize: 24.0,
                              ),
                            ),
                            subtitle: Text(
                                "TO: ${Provider.of<AddressBooks>(context, listen: false).getName(block.transactions[index].to)}"),
                            children: <Widget>[
                              Container(
                                margin: const EdgeInsets.all(4.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        "DATE: ${block.transactions[index].timeStamp}"),
                                    Text(
                                        "HASH: ${block.transactions[index].hash}")
                                  ],
                                ),
                              )
                            ],
                          ));
                        }),
                  )
                ]);
              } else {
                return const CircularProgressIndicator();
              }
            });
      }),
    );
  }
}
