import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../viewmodels/blockchain_validation_viewmodel.dart';

class BlockchainValidationScreen extends StatelessWidget {
  final String electionId;

  const BlockchainValidationScreen({super.key, required this.electionId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BlockchainValidationViewModel(),
      child: _BlockchainValidationContent(electionId: electionId),
    );
  }
}

class _BlockchainValidationContent extends StatefulWidget {
  final String electionId;

  const _BlockchainValidationContent({required this.electionId});

  @override
  State<_BlockchainValidationContent> createState() => _BlockchainValidationContentState();
}

class _BlockchainValidationContentState extends State<_BlockchainValidationContent> {
  late BlockchainValidationViewModel vm;

  @override
  void initState() {
    super.initState();
    vm = Provider.of<BlockchainValidationViewModel>(context, listen: false);
    Future.microtask(() => vm.loadChain(widget.electionId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Blockchain Validation"),
        backgroundColor: AppColors.appBar,
      ),
      body: Consumer<BlockchainValidationViewModel>(
        builder: (context, vm, child) {
          return vm.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      vm.isValid ? Icons.verified : Icons.warning,
                      color: vm.isValid ? AppColors.success : AppColors.error,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        vm.isValid
                            ? "✅ Blockchain is valid. No tampering detected."
                            : "❌ Blockchain is invalid. Tampering or corruption detected.",
                        style: TextStyle(
                          fontSize: 16,
                          color: vm.isValid ? AppColors.success : AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "🔗 Blockchain Blocks",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: vm.blockchain.chain.length,
                  itemBuilder: (context, index) {
                    final block = vm.blockchain.chain[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("🧱 Block #${block.index}", style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text("Hash: ${block.hash}"),
                            Text("Prev Hash: ${block.previousHash}"),
                            Text("Timestamp: ${DateTime.fromMillisecondsSinceEpoch(block.timestamp)}"),
                            const SizedBox(height: 6),
                            Text("Encrypted Vote: ${block.encryptedData}", style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
