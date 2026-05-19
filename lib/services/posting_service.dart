import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/posting_model.dart';

/// onboarding for using firebase_storage
/// https://youtu.be/4RcK1yKZtBA?si=lwRN1quc6_3wo8lB

class PostingService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  /// get all postings (no status filter)
  Stream<List<PostedItem>> getAllPostings() {
    return firestore
      .collection('postings')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshots) {
        return snapshots.docs
          .map((doc) => PostedItem.fromMap(doc.data(), doc.id))
          .toList();
      });
  }
  
  /// get all available postings
  Stream<List<PostedItem>> getAvailablePostings() {
    return firestore
      .collection('postings')
      .where('status', isEqualTo: 'available')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs
          .map((doc) => PostedItem.fromMap(doc.data(), doc.id))
          .toList();
      });
  }

  /// get postings by user (the poster)
  Stream<List<PostedItem>> getUserPostings(String userId) {
    return firestore
    .collection('postings')
    .where('posterId', isEqualTo: userId)
    .orderBy('createdAt', descending: true)
    .snapshots()
    .map((snapshopt) {
      return snapshopt.docs
        .map((doc) => PostedItem.fromMap(doc.data(), doc.id))
        .toList();
    });
  }

  /// Get postings filtered by tags (for user feed)
  Stream<List<PostedItem>> getPostingByTags(List<String> tags)  {
    return firestore
      .collection('postings')
      .where('status', isEqualTo: 'available')
      .where('selectedTags', arrayContainsAny: tags)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs
          .map((doc) => PostedItem.fromMap(doc.data(), doc.id))
          .toList();
      });
  }

  /// create a new posting
  Future<PostedItem> createPosting({
    required String posterId,
    required String posterName,
    required bool posterVerified,
    required String itemName,
    required String description,
    required double price,
    required int stock,
    required File? photoFile, // the photo
    required List<String> selectedTags,
    required DateTime expirationDate,
    required double? latitude,   // ← Add these
    required double? longitude,  // ← Add these
  }) async {
    try {
      // create posting document first (w/o the photo url)
      final postingRef = firestore.collection('postings').doc();
      final postingId = postingRef.id;

      String? photoUrl;

      // upload photo to storage if provided
      if (photoFile != null) {
        final storageRef = storage.ref('postings/$postingId/photo.jpg');
        await storageRef.putFile(photoFile);
        photoUrl = await storageRef.getDownloadURL();
      }

      // now create the posting with photo url
      final now = DateTime.now();
      final posting = PostedItem(
        id: postingId, 
        posterId: posterId, 
        posterName: posterName, 
        posterVerified: posterVerified, 
        itemName: itemName, 
        description: description, 
        price: price,
        stock: stock,
        photoUrl: photoUrl,
        selectedTags: selectedTags, 
        expirationDate: expirationDate, 
        status: 'available', 
        claimedBy: null,
        latitude: latitude,      // ← Add these
        longitude: longitude,    // ← Add these
        createdAt: now, 
        updatedAt: now,
      );

      // write to firestore
      await postingRef.set(posting.toMap());

      return posting;
    } catch (e) {
      throw Exception('Failed to create posting: $e');
    }
  }

  /// update posting status
  Future<void> updatePostingStatus(
    String postingId,
    String newStatus,
    { String? claimedBy, }
  ) async {
    try {
      await firestore.collection('postings').doc(postingId).update({
        'status': newStatus,
        'claimedBy': claimedBy,
        'updatedAt': DateTime.now()
      });
    } catch (e) {
      throw Exception('Failed to update posting: $e');
    }
  }

  /// delete a posting
  Future<void> deletePosting(String postingId) async {
    try {
      // delete photo from storage if exists
      try {
        await storage.ref('postings/$postingId/photo.jpg').delete();
      } catch (e) {
        // well if photo doesnt exist, continue anyway
      }

      // delete from firestore
      await firestore.collection('postings').doc(postingId).delete();
    } catch (e) {
      throw Exception('Failed to delete posting: $e');
    }
  }

  /// get single posting by ID
  Future<PostedItem?> getPosting(String postingId) async {
    try {
      final doc = await firestore.collection('postings').doc(postingId).get();
      if (doc.exists) {
        return PostedItem.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get posting: $e');
    }
  }

  /// create a new claim for an item
  Future<void> createClaim(
    String postingId,
    String claimerId,
    String claimerName,
  ) async {
    try {
      final postingDoc = await firestore.collection('postings').doc(postingId).get();
      if (!postingDoc.exists) {
        throw Exception('Posting not found');
      }

      final posterId = postingDoc.data()?['posterId'] ?? '';

      final claimId = firestore.collection('claims').doc().id;
      final claim = Claim(
        id: claimId, 
        postingId: postingId, 
        posterId: posterId,
        claimerId: claimerId, 
        claimerName: claimerName, 
        status: 'pending', 
        claimedAt: DateTime.now(),
      );

      await firestore.collection('claims').doc(claimId).set(claim.toMap());
    } catch (e) {
      throw Exception('Failed to create claim: $e');
    }
  }

  /// get all claims for a posting
  Stream<List<Claim>> getClaimsForPosting(String postingId) {
    return firestore
      .collection('claims')
      .where('postingId', isEqualTo: postingId)
      .snapshots()
      .map((snapshot) =>
        snapshot.docs.map((doc) => Claim.fromMap(doc.data(), doc.id)).toList());
  }

  /// accept a claim and update posting status
  Future<void> acceptClaim(String claimId, String postingId, String claimerId) async {
    try {
      // update claim status
      await firestore.collection('claims').doc(claimId).update({
        'status': 'accepted',
        'resolvedAt': DateTime.now(),
      });

      // update posting status
      await firestore.collection('postings').doc(postingId).update({
        'status': 'reserved',
        'claimedBy': claimerId,
        'updatedAt': DateTime.now(),
      });

      // reject all other claims for this posting
      final otherClaims = await firestore
        .collection('claims')
        .where('postingId', isEqualTo: postingId)
        .where('id', isNotEqualTo: claimId)
        .get();
      
      for (var doc in otherClaims.docs) {
        await doc.reference.update({'status': 'rejected'});
      }
    } catch (e) {
      throw Exception('Failed to accept claim: $e');
    }
  }

  /// reject a claim
  Future<void> rejectClaim(String claimId) async {
    try {
      await firestore.collection('claims').doc(claimId).update({
        'status': 'rejected',
        'resolvedAt': DateTime.now(),
      });
    } catch (e) {
      throw Exception('Failed to reject claim: $e');
    }
  }

  /// delete a claim
  Future<void> deleteClaim(String claimId) async {
    try {
      await firestore.collection('claims').doc(claimId).delete();
    } catch (e) {
      throw Exception('Failed to delete claim: $e');
    }
  }

  /// complete a claim after QR handshake
  Future<void> completeClaim(String postingId, String claimId) async {
    try {
      await firestore.collection('claims').doc(claimId).update({
        'status': 'completed',
        'resolvedAt': DateTime.now(),
      });

      await firestore.collection('postings').doc(postingId).update({
        'status': 'completed',
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      throw Exception('Failed to complete claim: $e');
    }
  }

  /// check if user already has a pending/accepted claim for this posting
  Future<bool> userHasExistingClaim(String postingId, String claimerId) async {
    try {
      final snapshot = await firestore
        .collection('claims')
        .where('postingId', isEqualTo: postingId)
        .where('claimerId', isEqualTo: claimerId)
        .where('status', whereIn: ['pending', 'accepted'])
        .get();
      
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// get claims for current user (as the claimer)
  Stream<List<Claim>> getUserClaims(String claimerId) {
    return firestore
      .collection('claims')
      .where('claimerId', isEqualTo: claimerId)
      .snapshots()
      .map((snapshot) =>
        snapshot.docs.map((doc) => Claim.fromMap(doc.data(), doc.id)).toList());
  }

  /// get count of claims for a posting (for the "Bids" filter)
  Future<int> getClaimCount(String postingId) async {
    try {
      final snapshot = await firestore
        .collection('claims')
        .where('postingId', isEqualTo: postingId)
        .where('status', isEqualTo: 'pending')
        .get();
      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }
}