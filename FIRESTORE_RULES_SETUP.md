# 🔥 FIRESTORE SECURITY RULES SETUP

## The Error You're Getting:

```
[cloud_firestore/permission-denied] The caller does not have permission to execute the specified operation.
```

This means your Firestore database doesn't have the proper security rules set up.

## 🚀 Quick Fix - Option 1: Firebase Console (Recommended)

1. **Go to Firebase Console**: https://console.firebase.google.com/
2. **Select your project**: `app-sticky-note`
3. **Navigate to Firestore Database**
4. **Click on "Rules" tab**
5. **Replace the existing rules with:**

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow authenticated users to read and write their own data
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Temporary: Allow all authenticated users to read/write (for testing)
    // Remove this rule in production
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

6. **Click "Publish"**

## 🚀 Option 2: Firebase CLI (If you have it set up)

Run these commands in your terminal:

```bash
cd /Users/hanjinsung/Desktop/Repository/app_sticky_note
firebase login
firebase use app-sticky-note
firebase deploy --only firestore:rules
```

## 🔒 Production Rules (Use Later)

Once everything is working, replace with these more secure rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;

      // Users can read and write their own categories
      match /categories/{categoryId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }

      // Users can read and write their own notes
      match /notes/{noteId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

## ✅ After Setting Up Rules:

1. **Restart your Flutter app**
2. **Login with your account**
3. **Try accessing "Manage Categories"**
4. **The categories should now load and you can add new ones**

## 🧪 Testing:

Once the rules are deployed:

- Login to your app
- Go to Menu → Manage Categories
- Try adding a new category
- Check your Firestore console to see the data

The error should be resolved and your categories will be stored in Firestore under:

```
users/{your-user-id}/categories/{category-id}
```
