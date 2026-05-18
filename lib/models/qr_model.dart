import 'dart:convert';

/// Represents the data encoded inside the claiming QR code.
/// The QR encodes this as a JSON string.
class QrModel {
  final String itemID;
  final String claimingID;
  final String ownerUID;
  final String claimerUID;
  final DateTime expiresAt;

  const QrModel({
    required this.itemID,
    required this.claimingID,
    required this.ownerUID,
    required this.claimerUID,
    required this.expiresAt,
  });

  // ── Serialisation ──────────────────────────────────────────────

  factory QrModel.fromJson(Map<String, dynamic> json) {
    return QrModel(
      itemID: json['itemID'] as String,
      claimingID: json['claimingID'] as String,
      ownerUID: json['ownerUID'] as String,
      claimerUID: json['claimerUID'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'itemID': itemID,
    'claimingID': claimingID,
    'ownerUID': ownerUID,
    'claimerUID': claimerUID,
    'expiresAt': expiresAt.toIso8601String(),
  };

  // ── Encode / decode from raw QR string ────────────────────────

  /// Converts the model to the JSON string that gets embedded in the QR.
  String toQrString() => jsonEncode(toJson());

  /// Parses the raw string scanned from the QR.
  /// Returns null if the string is not a valid claiming payload.
  static QrModel? tryParse(String raw) {
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return QrModel.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  // ── Helpers ───────────────────────────────────────────────────

  /// True if the QR has not expired yet.
  bool get isValid => DateTime.now().isBefore(expiresAt);

  @override
  String toString() =>
      'ClaimingQrModel(itemID: $itemID, claimingID: $claimingID, '
      'ownerUID: $ownerUID, claimerUID: $claimerUID, expiresAt: $expiresAt)';
}
