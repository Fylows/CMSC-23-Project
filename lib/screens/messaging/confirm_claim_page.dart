import 'package:flutter/material.dart';

import 'package:elbi_eats/providers/qr/qr_provider.dart';
import 'package:elbi_eats/models/qr_model.dart';

/// Shown immediately after a valid QR is scanned.
/// Displays transaction details and lets the claimer confirm or cancel.
class ConfirmClaimingScreen extends StatefulWidget {
  const ConfirmClaimingScreen({
    super.key,
    required this.payload,
    required this.handler,
  });

  final QrModel payload;
  final QrProvider handler;

  @override
  State<ConfirmClaimingScreen> createState() => _ConfirmClaimingScreenState();
}

class _ConfirmClaimingScreenState extends State<ConfirmClaimingScreen> {
  bool _isLoading = false;

  // ── Confirm ────────────────────────────────────────────────────

  Future<void> _onConfirm() async {
    setState(() => _isLoading = true);

    final result = await widget.handler.confirmClaiming(widget.payload);

    if (!mounted) return;
    setState(() => _isLoading = false);

    switch (result) {
      case ConfirmResult.success:
        _showSuccess();

      case ConfirmResult.alreadyCompleted:
        _showError('This item has already been claimed.');

      case ConfirmResult.unauthorized:
        _showError('You are not authorised to confirm this claim.');

      case ConfirmResult.error:
        _showError('Something went wrong. Please try again.');
    }
  }

  // ── Cancel ─────────────────────────────────────────────────────

  void _onCancel() => Navigator.pop(context, false);

  // ── Dialogs ────────────────────────────────────────────────────

  void _showSuccess() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Item claimed!'),
        content: const Text(
          'The item and claiming post have been marked as completed.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // close dialog
              Navigator.of(context).pop(true); // return true = confirmed
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Unable to confirm'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _isLoading ? null : _onCancel,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),

              // ── Icon ──
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.qr_code_2_rounded,
                  size: 36,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'QR CLAIMING',
                style: theme.textTheme.labelSmall?.copyWith(
                  letterSpacing: 1.8,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 28),

              // ── Question ──
              Text(
                'Do you want to confirm\nthis transaction?',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 28),

              const Spacer(),

              // ── Buttons ──
              Row(
                children: [
                  // No
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : _onCancel,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('No', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Yes
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: _isLoading ? null : _onConfirm,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Yes, confirm',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  /// Shortens a Firebase UID for display: "abc12...xyz99"
  String _shortenUID(String uid) {
    if (uid.length <= 12) return uid;
    return '${uid.substring(0, 5)}...${uid.substring(uid.length - 5)}';
  }
}

// ── Detail row widget ──────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
