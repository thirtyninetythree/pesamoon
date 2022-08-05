import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pesamoon/pages/qr_scan.dart';
import 'package:pesamoon/providers/address_book.dart';

import 'package:provider/provider.dart';
import 'providers/blockchain_provider.dart';

import 'pages/nav.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ByteData data =
      await PlatformAssetBundle().load('assets/ca/lets-encrypt-r3.pem');
  SecurityContext.defaultContext
      .setTrustedCertificatesBytes(data.buffer.asUint8List());

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => BlockchainProvider()),
      ChangeNotifierProvider(create: (_) => AddressBooks())
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pesamoon',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFFCADCED),
        fontFamily: "Circular",
      ),
      initialRoute: "/",
      routes: {
        "/": (context) => const Nav(),
        QRScan.routeName: (context) => const QRScan(),
      },
    );
  }
}
