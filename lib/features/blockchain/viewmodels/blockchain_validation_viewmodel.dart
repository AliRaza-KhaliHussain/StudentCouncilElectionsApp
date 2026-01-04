import 'package:flutter/material.dart';
import '../../../core/utils/blockchain.dart';

class BlockchainValidationViewModel extends ChangeNotifier {
  final Blockchain blockchain = Blockchain();
  bool isLoading = true;
  bool isValid = false;

  Future<void> loadChain(String electionId) async {
    isLoading = true;
    notifyListeners();

    await blockchain.loadFromFirebase(electionId);
    isValid = blockchain.isValidChain();

    isLoading = false;
    notifyListeners();
  }
}