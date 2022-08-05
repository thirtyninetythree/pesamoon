import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';
import 'package:web_socket_channel/io.dart';

final EthereumAddress contractAddr =
    EthereumAddress.fromHex('0x5D3F859aDd81978D4F3c397879bdd076388c75aE');

class FetchedTransactions {
  String to;
  String from;
  EtherAmount value;
  DateTime timeStamp;
  String hash;

  FetchedTransactions(
      {required this.to,
      required this.from,
      required this.value,
      required this.timeStamp,
      required this.hash});

  static fromMap(map) {
    return FetchedTransactions(
        to: map["to"],
        from: map["from"],
        value: EtherAmount.fromUnitAndValue(
            EtherUnit.wei, (BigInt.parse(map["value"]))),
        timeStamp: DateTime.fromMillisecondsSinceEpoch(
            int.parse(map["timeStamp"]) * 1000),
        hash: map["hash"]);
  }
}

class BlockchainProvider with ChangeNotifier {
  static const String _rpcUrl = 'https://rpc.testnet.fantom.network/';
  static const String _wsUrl = 'wss://wsapi.fantom.network/';

  static const String _privateKey = '';
  static final client = Web3Client(_rpcUrl, Client(), socketConnector: () {
    return IOWebSocketChannel.connect(_wsUrl).cast<String>();
  });
  final credentials = EthPrivateKey.fromHex(_privateKey);
  final EthereumAddress receiver = EthereumAddress.fromHex('');

  late final EthereumAddress ownAddress;
  // ignore: prefer_typing_uninitialized_variables
  late final contract;

  //INITIALIZATIONS
  BlockchainProvider() {
    ownAddress = credentials.address;
    contract = DeployedContract(
        ContractAbi.fromJson(abiFile, 'Pesamoon'), contractAddr);
  }

  String get address => credentials.address.toString();
  List<FetchedTransactions> _transactions = <FetchedTransactions>[];
  List<FetchedTransactions> get transactions => _transactions.reversed.toList();

  Future getBalance() async {
    final balance = await client.call(
        contract: contract,
        function: contract.function('balanceOf'),
        params: [ownAddress]);

    return EtherAmount.fromUnitAndValue(EtherUnit.wei, balance[0]).getInEther;
  }

  Future<void> sendTx(String to, int value) async {
    //if functitons to check if balance is enough
    final recipient = EthereumAddress.fromHex(to);
    final amount =
        EtherAmount.fromUnitAndValue(EtherUnit.ether, value).getInWei;

    await client.sendTransaction(
        credentials,
        Transaction.callContract(
          contract: contract,
          function: contract.function('transfer'),
          parameters: [recipient, amount],
        ),
        chainId: 4002);
    // .then((txHash) => _previousTx = txHash);
    client.dispose();
  }

  Future fetchTransactions() async {
    const startBlock = 5748381;
    // ignore: constant_identifier_names
    const API_KEY = "";

    final response = await get(Uri.parse(
        'https://api-testnet.ftmscan.com/api?module=account&action=tokentx&address=$ownAddress&startblock=$startBlock&endblock=999999999&sort=asc&apikey=$API_KEY'));

    if (response.statusCode == 200) {
      final txs = jsonDecode(response.body);
      List txList = txs["result"];

      _transactions = List.generate(txList.length,
          (int index) => FetchedTransactions.fromMap(txList[index]));
    } else {
      throw Exception("Failed to load transactions");
    }
  }
}

const String abiFile = '''
[
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "owner",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "spender",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "value",
				"type": "uint256"
			}
		],
		"name": "Approval",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "from",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "to",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "value",
				"type": "uint256"
			}
		],
		"name": "Transfer",
		"type": "event"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "owner",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "spender",
				"type": "address"
			}
		],
		"name": "allowance",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "spender",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "amount",
				"type": "uint256"
			}
		],
		"name": "approve",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "account",
				"type": "address"
			}
		],
		"name": "balanceOf",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "totalSupply",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "recipient",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "amount",
				"type": "uint256"
			}
		],
		"name": "transfer",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "sender",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "recipient",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "amount",
				"type": "uint256"
			}
		],
		"name": "transferFrom",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	}
]
''';
