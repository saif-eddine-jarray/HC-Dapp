import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';
import 'package:web_socket_channel/io.dart';
import 'dart:developer' as dev;


class DoctorServices extends ChangeNotifier {
    final String _rpcURL =
      Platform.isAndroid ? 'http://10.0.2.2:7545' : 'http://127.0.0.1:7545';
  final String _wsURL =
      Platform.isAndroid ? 'http://10.0.2.2:7545' : 'ws://127.0.0.1:7545';
  final String _privateKey ="df9eeea57ee4954aa3bc8c8a8d81945198265e0e4d5b55f773dcf35c509c8fc0";
  late Web3Client _client;
  late ContractAbi _abiCode;
  late EthereumAddress _contractAddress;
  late EthPrivateKey _creds;
  late DeployedContract _contract;
  late ContractFunction _exist;
  late ContractFunction _addDoctor;
  late ContractFunction _displayDoctor;

  DoctorServices() {
    init();
  }
  Future<void> init() async{
    _client = Web3Client(_rpcURL, Client(), socketConnector: () {
      return IOWebSocketChannel.connect(_wsURL).cast<String>();
    },);
    dev.log("client done");
    await getABI();
    dev.log("abi done");
    await getCredentials();
    dev.log("cred done");
    await getContract();
    dev.log("conctract done");
  }
  Future<void> getABI() async{
    String abiFile = await rootBundle.loadString('build/contracts/doctor.json');
    var jsonABI=jsonDecode(abiFile);
    _abiCode= ContractAbi.fromJson(jsonEncode(jsonABI['abi']), 'doctor');
    _contractAddress =
        EthereumAddress.fromHex(jsonABI["networks"]["5777"]["address"]);
    dev.log(_contractAddress.toString());
  }
  Future<void> getCredentials() async {
    _creds=EthPrivateKey.fromHex(_privateKey);
    dev.log(_creds.address.toString());
  }
  Future<void> getContract() async {
    _contract= DeployedContract(_abiCode, _contractAddress);
    _addDoctor=_contract.function('addDoctor');
    _exist=_contract.function('exist');
    _displayDoctor=_contract.function('displayDoctor');
  }
  Future<void> addDoctor(String firstName , String lastName) async {
    notifyListeners();
    dev.log(firstName+" "+lastName);
    var id= await _client.getChainId();
    print(id);
    await _client.sendTransaction(
      _creds,
      Transaction.callContract(
        contract: _contract,
        function: _addDoctor,
        parameters: [firstName,lastName],
      ),
      chainId: 1337,
    );
 
    dev.log("added");
  }
  Future<bool> exist() async {
      var a = await _client.call(
          sender: _creds.address,
          contract: _contract,
          function: _exist,
          params: []);
          notifyListeners();
          print(a[0]);
          return a[0];
  }
  Future<void> displayDoctor() async {
      var a = await _client.call(
          sender: _creds.address,
          contract: _contract,
          function: _displayDoctor,
          params: []);
          notifyListeners();
          print(a);
          return a[0];
  }
}