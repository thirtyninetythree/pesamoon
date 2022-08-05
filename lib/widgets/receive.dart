import 'package:flutter/material.dart';

import 'package:qr_flutter/qr_flutter.dart';
import 'package:provider/provider.dart';

import 'package:pesamoon/providers/blockchain_provider.dart';

class Receive extends StatefulWidget {
  const Receive({Key? key}) : super(key: key);

  @override
  State<Receive> createState() => _ReceiveState();
}

class _ReceiveState extends State<Receive> {
  @override
  Widget build(BuildContext context) {
    final address = context.select((BlockchainProvider bp) => bp.address);

    return Center(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Receive",
              style: TextStyle(fontSize: 16.0),
            ),
            const SizedBox(
              height: 20.0,
            ),
            QrImage(
              data: address,
              version: QrVersions.auto,
              size: 320.0,
            ),
            Container(
              height: 20,
            ),
            Text(
              address,
              style: const TextStyle(fontSize: 18.0),
            ),
          ]),
    );
  }
}
