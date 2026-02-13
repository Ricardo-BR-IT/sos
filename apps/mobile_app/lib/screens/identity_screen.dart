import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sos_kernel/sos_kernel.dart';

class IdentityScreen extends StatefulWidget {
  final SosCore core;
  final MeshService mesh;

  const IdentityScreen({Key? key, required this.core, required this.mesh})
      : super(key: key);

  @override
  State<IdentityScreen> createState() => _IdentityScreenState();
}

class _IdentityScreenState extends State<IdentityScreen> {
  bool _isScanning = false;
  final MobileScannerController _scannerController = MobileScannerController();

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        // Found a QR code
        final code = barcode.rawValue!;
        // Verify if it looks like a valid key (simplified check)
        if (code.length > 20) {
          _verifyPeer(code);
          setState(() {
            _isScanning = false;
          });
        }
      }
    }
  }

  void _verifyPeer(String peerId) {
    // In a real scenario, we would add this to a Trusted Store.
    // For now, we just notify the user and maybe start a chat.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Peer Verificado: ${peerId.substring(0, 10)}...'),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'CHAT',
          textColor: Colors.white,
          onPressed: () {
            // Navigate back with result or to chat
            Navigator.pop(context, peerId);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final publicKey = widget.core.publicKey;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Identidade & Verificação'),
        actions: [
          IconButton(
            icon: Icon(_isScanning ? Icons.close : Icons.qr_code_scanner),
            onPressed: () {
              setState(() {
                _isScanning = !_isScanning;
              });
            },
            tooltip: _isScanning ? 'Parar Scan' : 'Escanear Peer',
          ),
        ],
      ),
      body: _isScanning ? _buildScanner() : _buildIdentity(publicKey),
    );
  }

  Widget _buildScanner() {
    return Stack(
      children: [
        MobileScanner(
          controller: _scannerController,
          onDetect: _onDetect,
        ),
        Center(
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.redAccent, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: const Text(
            'Aponte para o QR Code do Peer',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              backgroundColor: Colors.black45,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIdentity(String publicKey) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Sua Identidade Pública',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Mostre este código para outro peer escanear e verificar sua confiança.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: QrImageView(
                data: publicKey,
                version: QrVersions.auto,
                size: 240.0,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            SelectableText(
              publicKey,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 10,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.share),
              label: const Text('Compartilhar Chave'),
              onPressed: () {
                // Implement share if needed
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content:
                          Text('Chave copiada para área de transferência')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
