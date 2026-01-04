import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/foundation.dart';

import '../../features/blockchain/data/blockchain_key_service.dart';


class Block {
  final int index;
  final String previousHash;
  final int timestamp;
  final String encryptedData;
  String hash;

  Block({
    required this.index,
    required this.previousHash,
    required this.timestamp,
    required this.encryptedData,
    required this.hash,
  });

  String calculateHash() {
    final input = '$index$previousHash$timestamp$encryptedData';
    return sha256.convert(utf8.encode(input)).toString();
  }

  Map<String, dynamic> toMap() {
    return {
      'index': index,
      'previousHash': previousHash,
      'timestamp': timestamp,
      'encryptedData': encryptedData,
      'hash': hash,
    };
  }

  factory Block.fromMap(Map<String, dynamic> map) {
    return Block(
      index: map['index'] as int? ?? 0,
      previousHash: map['previousHash'] as String? ?? '',
      timestamp: map['timestamp'] as int? ?? 0,
      encryptedData: map['encryptedData'] as String? ?? '',
      hash: map['hash'] as String? ?? '',
    );
  }
}

class Blockchain {
  List<Block> chain = [];

  // ✅ Use secure key from KeyService
  final String _aesKey = KeyService().aesKey;

  Blockchain() {
    if (_aesKey.isEmpty || ![16, 24, 32].contains(utf8.encode(_aesKey).length)) {
      throw ArgumentError('❌ Invalid AES key length from KeyService');
    }
    chain.add(_createGenesisBlock());
  }

  Block _createGenesisBlock() {
    final block = Block(
      index: 0,
      previousHash: '0',
      timestamp: DateTime.now().millisecondsSinceEpoch,
      encryptedData: 'Genesis Block',
      hash: '',
    );
    block.hash = block.calculateHash();
    return block;
  }

  String encryptData(String data) {
    final keyBytes = utf8.encode(_aesKey);
    final key = encrypt.Key(Uint8List.fromList(keyBytes));
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    return encrypter.encrypt(data, iv: iv).base64;
  }

  String decryptData(String encryptedBase64) {
    final keyBytes = utf8.encode(_aesKey);
    final key = encrypt.Key(Uint8List.fromList(keyBytes));
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    try {
      return encrypter.decrypt64(encryptedBase64, iv: iv);
    } catch (e) {
      return '⚠️ Unable to decrypt';
    }
  }

  void addBlock(String voteData) {
    final previousBlock = chain.last;
    final encryptedData = encryptData(voteData);
    final newBlock = Block(
      index: previousBlock.index + 1,
      previousHash: previousBlock.hash,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      encryptedData: encryptedData,
      hash: '',
    );
    newBlock.hash = newBlock.calculateHash();
    chain.add(newBlock);
    debugPrint('✅ Added block ${newBlock.index} for voteData: $voteData');
  }

  bool isValidChain() {
    for (int i = 1; i < chain.length; i++) {
      final currentBlock = chain[i];
      final previousBlock = chain[i - 1];
      if (currentBlock.hash != currentBlock.calculateHash()) {
        debugPrint('❌ Invalid hash for block ${currentBlock.index}');
        return false;
      }
      if (currentBlock.previousHash != previousBlock.hash) {
        debugPrint('❌ Invalid previousHash for block ${currentBlock.index}');
        return false;
      }
    }
    debugPrint('✅ Blockchain is valid with ${chain.length} blocks');
    return true;
  }

  Future<void> loadFromFirebase(String electionId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('elections')
          .doc(electionId)
          .collection('blockchain')
          .doc('chain')
          .get();
      if (doc.exists) {
        final blocks = (doc['blocks'] as List<dynamic>?)?.map((b) => Block.fromMap(b)).toList() ?? [];
        chain = blocks.isNotEmpty ? blocks : [_createGenesisBlock()];
      } else {
        chain = [_createGenesisBlock()];
      }
      debugPrint('✅ Loaded blockchain for election $electionId: ${chain.length} blocks');
    } catch (e) {
      debugPrint('❌ Error loading blockchain: $e');
      chain = [_createGenesisBlock()];
    }
  }

  Future<void> saveToFirebase(String electionId) async {
    try {
      await FirebaseFirestore.instance
          .collection('elections')
          .doc(electionId)
          .collection('blockchain')
          .doc('chain')
          .set({
        'blocks': chain.map((b) => b.toMap()).toList(),
      });
      debugPrint('✅ Saved blockchain for election $electionId');
    } catch (e) {
      debugPrint('❌ Error saving blockchain: $e');
      throw e;
    }
  }
}
