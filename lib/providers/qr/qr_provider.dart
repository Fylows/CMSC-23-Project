import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:elbi_eats/models/qr_model.dart';

/// Result returned after attempting to confirm a claiming.
enum ConfirmResult { success, alreadyCompleted, unauthorized, error }

class QrProvider {
  QrProvider({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _db = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  // ── QR Generation (called by the owner in the chat screen) ────

  /// Builds the [ClaimingQrModel] that gets encoded into the QR widget.
  /// [validForMinutes] controls how long the QR stays usable.
  QrModel generatePayload({
    required String itemID,
    required String claimingID,
    required String ownerUID,
    required String claimerUID,
    int validForMinutes = 15,
  }) {
    return QrModel(
      itemID: itemID,
      claimingID: claimingID,
      ownerUID: ownerUID,
      claimerUID: claimerUID,
      expiresAt: DateTime.now().add(Duration(minutes: validForMinutes)),
    );
  }

  // ── QR Scanning validation ─────────────────────────────────────

  /// Parses and validates a raw QR string.
  ///
  /// Returns the [QrModel] on success, or a descriptive error string.
  ({QrModel? model, String? error}) parseAndValidate(String raw) {
    // 1. Parse JSON
    final model = QrModel.tryParse(raw);
    if (model == null) {
      return (model: null, error: 'Invalid QR code. Please try again.');
    }

    // 2. Expiry check
    if (!model.isValid) {
      return (
        model: null,
        error: 'This QR code has expired. Ask the owner to generate a new one.',
      );
    }

    // 3. Logged-in user must be the intended claimer
    final currentUID = _auth.currentUser?.uid;
    if (currentUID == null) {
      return (model: null, error: 'You must be logged in to claim an item.');
    }
    if (currentUID != model.claimerUID) {
      return (
        model: null,
        error: 'This QR code is not meant for your account.',
      );
    }

    return (model: model, error: null);
  }

  // ── Firebase Confirmation ──────────────────────────────────────

  /// Atomically marks both the item post and claiming post as "completed".
  ///
  /// Performs extra safety checks before writing:
  /// - Both documents must still be "pending"
  /// - The current user must be the claimer
  Future<ConfirmResult> confirmClaiming(QrModel payload) async {
    try {
      final itemRef = _db.collection('postings').doc(payload.itemID);
      final claimingRef = _db.collection('claims').doc(payload.claimingID);

      // Run inside a transaction so we can read-then-write safely
      await _db.runTransaction((tx) async {
        final itemSnap = await tx.get(itemRef);
        final claimingSnap = await tx.get(claimingRef);

        // Guard: documents must exist
        if (!itemSnap.exists || !claimingSnap.exists) {
          throw _AppException('Documents not found.');
        }

        // Guard: must still be pending (prevent double-confirm)
        final itemStatus = itemSnap.data()?['status'] as String?;
        final claimingStatus = claimingSnap.data()?['status'] as String?;

        if (itemStatus == 'completed' || claimingStatus == 'completed') {
          throw _AlreadyCompletedException();
        }

        // Guard: claimerUID in the document must match the current user
        final storedClaimerUID = claimingSnap.data()?['claimerUID'] as String?;
        final currentUID = _auth.currentUser?.uid;
        if (storedClaimerUID != currentUID) {
          throw _UnauthorizedException();
        }

        tx.update(itemRef, {'status': 'completed'});

        tx.update(claimingRef, {'status': 'completed'});
      });

      return ConfirmResult.success;
    } on _AlreadyCompletedException {
      return ConfirmResult.alreadyCompleted;
    } on _UnauthorizedException {
      return ConfirmResult.unauthorized;
    } catch (_) {
      return ConfirmResult.error;
    }
  }
}

// ── Internal exception types ──────────────────────────────────────

class _AppException implements Exception {
  _AppException(this.message);
  final String message;
}

class _AlreadyCompletedException implements Exception {}

class _UnauthorizedException implements Exception {}
