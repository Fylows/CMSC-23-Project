import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elbi_eats/screens/messaging/confirm_claim_page.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:elbi_eats/providers/qr/qr_provider.dart';

/// Full-screen QR scanner. On a valid scan it navigates to [ConfirmClaimingScreen].
/// Add to pubspec.yaml:  mobile_scanner: ^5.0.0
class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  final QrProvider _handler = QrProvider();

  bool _processing = false; // prevents duplicate navigations

  // ── Handle scanned barcode ─────────────────────────────────────

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_processing) return;

    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null) return;

    setState(() => _processing = true);
    await _controller.stop();

    final (:model, :error) = _handler.parseAndValidate(raw);

    if (!mounted) return;

    if (error != null) {
      _showError(error);
      return;
    }

    // Navigate to the confirm screen and wait for the result
    final confirmed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ConfirmClaimingScreen(payload: model!, handler: _handler),
      ),
    );

    if (!mounted) return;

    if (confirmed == true) {
      Navigator.pop(context, true);
    } else {
      // User cancelled — resume the scanner
      setState(() => _processing = false);
      await _controller.start();
    }
  }

  // ── Error banner ───────────────────────────────────────────────

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
    setState(() => _processing = false);
    _controller.start();
  }

  // ── Build ──────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('Scan QR Code'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => _controller.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // ── Camera feed ──
          MobileScanner(controller: _controller, onDetect: _onDetect),

          // ── Scan overlay ──
          _ScanOverlay(),

          // ── Loading indicator while processing ──
          if (_processing)
            const Center(child: CircularProgressIndicator(color: Colors.white)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// ── Scan overlay ────────────────────────────────────────────────────

class _ScanOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Cutout frame
        Center(
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Point the camera at the QR code',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ],
    );
  }
}
