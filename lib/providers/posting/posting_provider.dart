import 'package:flutter/material.dart';
import 'dart:io';
import '../../models/posting_model.dart';
import '../../models/user/user_model.dart';
import '../../services/posting_service.dart';
import '../message/message_provider.dart';

class PostingProvider extends ChangeNotifier {
  final PostingService postingService = PostingService();
  final MessageProvider messageProvider = MessageProvider();

  // available postings (for the home feed)
  List<PostedItem> availablePostings = [];

  // user's own postings
  List<PostedItem> userPostings = [];

  // list of claims of a user
  List<Claim> myClaims = [];

  // state tracking
  bool isLoading = false;
  String? errorMessage;

  // streams
  late Stream<List<PostedItem>> availablePostingsStream;

  /// get ALL postings stream
  Stream<List<PostedItem>> getAllPostingsStream() {
    return postingService.getAllPostings();
  }

  /// get available postings stream
  Stream<List<PostedItem>> getAvailablePostingsStream() {
    return postingService.getAvailablePostings();
  }

  /// get user's postings stream
  Stream<List<PostedItem>> getUserPostingsStream(String userId) {
    return postingService.getUserPostings(userId);
  }

  /// get filtered postings by user's tags
  Stream<List<PostedItem>> getPersonalizedFeed(List<String> userTags) {
    if (userTags.isEmpty) {
      return postingService.getAvailablePostings();
    }
    return postingService.getPostingByTags(userTags);
  }

  /// create a new posting
  Future<void> createPosting({
    required User currentUser,
    required String itemName,
    required String description,
    required double price,
    required int stock,
    required File? photoFile,
    required List<String> selectedTags,
    required DateTime expirationDate,
  }) async {
    setLoading(true);
    clearError();

    try {
      // fetch full name from firestore users collection
      final userDoc = await postingService.firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();

      final firstName =
          userDoc.data()?['firstname'] ??
          userDoc.data()?['firstName'] ??
          'Anonymous';
      final lastName = userDoc.data()?['lastName'] ?? '';
      final fullName = '$firstName $lastName'.trim();

      final posting = await postingService.createPosting(
        posterId: currentUser.uid,
        posterName: fullName,
        posterVerified: currentUser.isVerified,
        itemName: itemName,
        description: description,
        price: price,
        stock: stock,
        photoFile: photoFile,
        selectedTags: selectedTags,
        expirationDate: expirationDate,
      );

      // add to local list
      userPostings.insert(0, posting);
      notifyListeners();
    } catch (e) {
      setError('Failed to create posting: ${e.toString()}');
      rethrow; // send error to UI
    } finally {
      setLoading(false);
    }
  }

  /// update a posting status
  Future<void> updatePostingStatus(
    String postingId,
    String newStatus, {
    String? claimedBy,
  }) async {
    setLoading(true);
    clearError();

    try {
      await postingService.updatePostingStatus(
        postingId,
        newStatus,
        claimedBy: claimedBy,
      );

      // update local list
      final index = userPostings.indexWhere((p) => p.id == postingId);
      if (index != -1) {
        userPostings[index] = userPostings[index].copyWith(
          status: newStatus,
          claimedBy: claimedBy,
          updatedAt: DateTime.now(),
        );
        notifyListeners();
      }
    } catch (e) {
      setError('Failed to update posting: ${e.toString()}');
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  /// delete a posting
  Future<void> deletePosting(String postingId) async {
    setLoading(true);
    clearError();

    try {
      await postingService.deletePosting(postingId);
      await messageProvider.deleteChatsForItem(postingId);
      // remove from local list
      userPostings.removeWhere((p) => p.id == postingId);
      notifyListeners();
    } catch (e) {
      setError('Failed to delete posting: ${e.toString()}');
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  /// create a claim
  Future<void> createClaim(
    String postingId,
    String claimerId,
    String claimerName,
  ) async {
    try {
      await postingService.createClaim(postingId, claimerId, claimerName);
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// accept a claim
  Future<void> acceptClaim(
    String claimId,
    String postingId,
    String claimerId,
  ) async {
    try {
      isLoading = true;
      notifyListeners();

      await postingService.acceptClaim(claimId, postingId, claimerId);

      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  /// complete a claim
  Future<void> completeClaim(String postingId, String claimId) async {
    try {
      isLoading = true;
      notifyListeners();

      await postingService.completeClaim(postingId, claimId);

      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  /// reject a claim
  Future<void> rejectClaim(String claimId) async {
    try {
      await postingService.rejectClaim(claimId);
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// delete a claim
  Future<void> deleteClaim(String claimId) async {
    try {
      await postingService.deleteClaim(claimId);
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Stream<List<Claim>> getUserClaimsStream(String claimerId) {
    return postingService.getUserClaims(claimerId);
  }

  Stream<List<Claim>> getClaimsForPostingStream(String postingId) {
    return postingService.getClaimsForPosting(postingId);
  }

  Future<bool> userHasExistingClaim(String postingId, String claimerId) async {
    try {
      return await postingService.userHasExistingClaim(postingId, claimerId);
    } catch (e) {
      return false;
    }
  }

  // ========== HELPER METHODS =======
  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void setError(String message) {
    errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    errorMessage = null;
  }
}
