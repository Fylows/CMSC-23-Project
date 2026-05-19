import 'package:cloud_firestore/cloud_firestore.dart';
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
    if (_meetupDateTime == null) return; // safety guard
    setState(() => _isLoading = true);
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.payload.chatId)
        .update({
          'meetupTime': Timestamp.fromDate(_meetupDateTime!),
          'claimed': true,
        });
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
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasMeetup = _meetupDateTime != null;

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

              // ── Meetup picker ──
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Set Meetup Time',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  hasMeetup
                      // ── Locked display once set ──
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.lock_rounded,
                                size: 16,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _formatMeetup(_meetupDateTime!),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      // ── Tap to set ──
                      : OutlinedButton.icon(
                          onPressed: _isLoading ? null : _pickMeetupDateTime,
                          icon: const Icon(Icons.calendar_month_rounded),
                          label: const Text('Choose date & time'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            side: BorderSide(color: colorScheme.outline),
                          ),
                        ),
                  if (!hasMeetup) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Required before confirming',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ),

              const Spacer(),
              // ── Buttons ──
              Row(
                children: [
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
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      // disabled until meetup is set
                      onPressed: _isLoading || !hasMeetup ? null : _onConfirm,
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

  DateTime? _meetupDateTime; // add this to your state

  Future<void> _pickMeetupDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(hours: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null || !mounted) return;

    setState(() {
      _meetupDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  String _formatMeetup(DateTime dt) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour < 12 ? 'AM' : 'PM';
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year} • $hour:$minute $ampm';
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
