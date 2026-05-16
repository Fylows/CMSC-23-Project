# Firestore Database Schema

> NOTE: the [indexed] parts are the ones that are important for the app search and filtering logic. You guys can modify it if you want

## Collections Structure

### `users/{uid}`
User profile data

**Fields:**
- `uid` (string) - Firebase Auth UID [indexed]
- `email` (string) [indexed]
- `displayName` (string)
- `username` (string)
- `firstName` (string)
- `lastName` (string)
- `dateOfBirth` (timestamp)
- `selectedTags` (array<string>) - dietary/preference tags [indexed]
- `profilePictureUrl` (string, nullable)
- `isVerified` (boolean) - verified after selfie upload
- `verificationSelfieUrl` (string, nullable)
- `contributorScore` (number) - starts at 0
- `createdAt` (timestamp, server-set)
- `updatedAt` (timestamp, server-set)

**Example Document:**
```json
{
  "uid": "user123",
  "email": "juan@up.edu.ph",
  "firstName": "Juan",
  "lastName": "Dela Cruz",
  "dateOfBirth": Timestamp(2003, 5, 15),
  "selectedTags": ["vegan", "halal", "home-cooked"],
  "profilePictureUrl": null,
  "isVerified": false,
  "verificationSelfieUrl": null,
  "contributorScore": 0,
  "createdAt": Timestamp(2026, 5, 17, 10, 30, 0),
  "updatedAt": Timestamp(2026, 5, 17, 10, 30, 0)
}
```

---

### `postings/{postingId}`
Posted surplus items

**Fields:**

- `id` (string) - document ID
- `posterId` (string) [indexed] - reference to user uid
- `posterName` (string) - denormalized from user
- `posterVerified` (boolean) - denormalized from user
- `itemNam`e (string) [indexed]
- `description` (string)
- `photoUrl` (string, nullable)
- `selectedTags` (array<string>) [indexed] - tags matching this item
- `expirationDate` (timestamp) [indexed]
- `status` (string) [indexed] - 'available' | 'reserved' | 'completed' | 'cancelled'
- `claimedBy` (string, nullable) - uid of claimer
- `createdAt` (timestamp) [indexed]
- `updatedAt` (timestamp)

**Example Document:**
```json
{
  "id": "posting456",
  "posterId": "user123",
  "posterName": "Juan Dela Cruz",
  "posterVerified": false,
  "itemName": "3 Extra Eggs",
  "description": "Fresh eggs from my backyard, expires May 20",
  "photoUrl": "https://some-valid-url.com/postings/posting456/photo.jpg",
  "selectedTags": ["healthy", "raw ingredients"],
  "expirationDate": Timestamp(2026, 5, 20),
  "status": "available",
  "claimedBy": null,
  "createdAt": Timestamp(2026, 5, 17, 14, 0, 0),
  "updatedAt": Timestamp(2026, 5, 17, 14, 0, 0)
}
```

---

### `claims/{claimId}`
Claims/requests on posted items

**Fields:**

- `id` (string) - document ID
- `postingId` (string) [indexed] - reference to posting
- `posterId` (string) [indexed] - reference to poster uid
- `claimerId` (string) [indexed] - reference to claimer uid
- `claimerName` (string) - denormalized from user
- `status` (string) [indexed] - 'pending' | 'accepted' | 'rejected' | 'completed'
- `claimedAt` (timestamp)
- `resolvedAt` (timestamp, nullable) - when claim was accepted/rejected/completed

**Example Document:**

```json
{
  "id": "claim789",
  "postingId": "posting456",
  "posterId": "user123",
  "claimerId": "user999",
  "claimerName": "Maria Santos",
  "status": "pending",
  "claimedAt": Timestamp(2026, 5, 17, 15, 30, 0),
  "resolvedAt": null
}
```

--- 

### Security Rules
For the security rules in the firestore database

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Users collection - users can only read/write their own data
    match /users/{uid} {
      allow read: if request.auth.uid == uid;
      allow create: if request.auth.uid == uid && request.auth.token.email_verified == false;
      allow update: if request.auth.uid == uid;
      allow delete: if request.auth.uid == uid;
    }
    
    // Postings collection - read public, write if owner
    match /postings/{postingId} {
      allow read: if true; // public
      allow create: if request.auth != null;
      allow update: if request.auth.uid == resource.data.posterId;
      allow delete: if request.auth.uid == resource.data.posterId;
    }
    
    // Claims collection - read if involved, write if involved
    match /claims/{claimId} {
      allow read: if request.auth.uid == resource.data.posterId || 
                     request.auth.uid == resource.data.claimerId;
      allow create: if request.auth.uid == request.resource.data.claimerId;
      allow update: if request.auth.uid == resource.data.posterId;
      allow delete: if request.auth.uid == resource.data.posterId;
    }
  }
}
```