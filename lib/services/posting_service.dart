import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/posting_model.dart';

/// onboarding for using firebase_storage
/// https://youtu.be/4RcK1yKZtBA?si=lwRN1quc6_3wo8lB

class PostingService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

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
      .where('status', isEqualTo: 'avalailble')
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
    required File? photoFile, // the photo
    required List<String> selectedTags,
    required DateTime expirationDate,
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
        photoUrl: photoUrl,
        selectedTags: selectedTags, 
        expirationDate: expirationDate, 
        status: 'available', 
        claimedBy: null,
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
    } catch (e) {
      throw Exception('Failed to get posting: $e');
    }
  }
}