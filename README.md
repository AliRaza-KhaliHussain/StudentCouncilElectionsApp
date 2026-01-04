`README.md`** for your Online Voting App project. 

# 🗳️ Online Voting App - Student Council Elections

A Flutter app for secure online voting using Firebase Authentication, Cloud Firestore, and Provider state management. Designed for student council elections, but adaptable to other organizational elections.

---

## 📌 Features

- User Registration & Login (Voter/Admin)  
- Admin Panel to manage elections, candidates, and positions  
- Voter Dashboard to vote for multiple positions  
- Real-time Live Results using Firebase  
- Prevents duplicate voting  
- Voting history tracking  
- Offline support and error handling  

---

## 🛠️ Built With

- **Flutter**  
- **Firebase Authentication & Firestore**  
- **Provider** (State Management)  
- **fl_chart** (Graph visualization for results)  

---

## 📱 Screens

- Splash Screen  
- Login / Register / Forgot Password  
- Voter Dashboard  
- Voting Screen (Multiple Positions)  
- Live Results  
- Admin Panel (Mobile/Web)  
- Profile, History & Settings  

---

## 📁 Project Structure (Recommended)

The project follows a **Clean Architecture + Feature-based structure**, ensuring scalability, testability, and maintainability.

```text
lib/
├── core/
│   ├── config/
│   │   ├── firebase_config.dart        # Firebase initialization & setup
│   │   ├── app_routes.dart             # Named route definitions
│   │   └── app_theme.dart              # Global theme configuration
│   │
│   ├── constants/
│   │   ├── app_colors.dart             # Color palette
│   │   ├── app_strings.dart            # App text constants
│   │   └── app_sizes.dart              # Spacing & sizing constants
│   │
│   ├── utils/
│   │   ├── validators.dart             # Input validation helpers
│   │   ├── date_utils.dart             # Date & time utilities
│   │   └── blockchain_utils.dart       # Blockchain helper logic
│   │
│   └── widgets/
│       ├── loading_widget.dart         # Global loading UI
│       ├── error_widget.dart           # Error handling UI
│       └── empty_state_widget.dart     # Empty state UI
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── auth_service.dart
│   │   │   └── auth_repository.dart
│   │   ├── models/
│   │   │   └── user_model.dart
│   │   ├── viewmodels/
│   │   │   └── auth_viewmodel.dart
│   │   └── views/
│   │       ├── login_screen.dart
│   │       ├── register_screen.dart
│   │       └── widgets/
│   │           └── auth_form.dart
│
│   ├── election/
│   │   ├── data/
│   │   │   ├── election_service.dart
│   │   │   └── election_repository.dart
│   │   ├── models/
│   │   │   ├── election_model.dart
│   │   │   ├── candidate_model.dart
│   │   │   └── vote_model.dart
│   │   ├── viewmodels/
│   │   │   ├── election_viewmodel.dart
│   │   │   └── results_viewmodel.dart
│   │   └── views/
│   │       ├── election_list_screen.dart
│   │       ├── election_detail_screen.dart
│   │       ├── vote_screen.dart
│   │       └── widgets/
│   │           ├── candidate_card.dart
│   │           └── vote_button.dart
│
│   ├── blockchain/
│   │   ├── data/
│   │   │   └── blockchain_service.dart
│   │   ├── models/
│   │   │   └── block_model.dart
│   │   ├── viewmodels/
│   │   │   └── blockchain_viewmodel.dart
│   │   └── views/
│   │       └── blockchain_logs_screen.dart
│
│   ├── admin/
│   │   ├── data/
│   │   │   └── admin_service.dart
│   │   ├── viewmodels/
│   │   │   └── admin_viewmodel.dart
│   │   └── views/
│   │       ├── admin_dashboard_screen.dart
│   │       └── manage_elections_screen.dart
│
├── shared/
│   ├── widgets/
│   │   ├── app_button.dart
│   │   ├── app_textfield.dart
│   │   └── app_card.dart
│   │
│   └── providers/
│       └── app_providers.dart
│
├── firebase_options.dart
├── main.dart
└── app.dart


## 📜 Notes

* ✅ Only the **dummy Firebase config** is committed.
* ✅ Do **not commit** `google-services.json` or `GoogleService-Info.plist`.
* ✅ Contributors must set up their own Firebase project.


## 📂 Recommended Firestore Structure

```plaintext
users/{uid}
  name
  rollNo
  department
  role (voter/admin)

votes/{uid}
  {positionId: candidateId}

elections/{electionId}
  title
  status
  startTime
  endTime

positions/{id}
  name
  electionId

candidates/{id}
  name
  positionId
  department
  image
  votes
````

---

## 🎯 Example Positions by Election Type

1. **University Department Representative Elections**: President, Vice President, General Secretary, Finance Secretary, Media Coordinator, Event Organizer
2. **Nonprofit / Youth Club Elections**: Club President, Vice President, Treasurer, Secretary, Outreach Officer, Technical Head
3. **Company Internal Committee Elections**: Council Chairperson, Vice Chairperson, HR Representative, Finance Lead, Culture & Events Manager, Operations Head
4. **College Hostel Committee Elections**: Hostel President, Vice President, Mess Secretary, Sports Secretary, Maintenance Officer, Warden Representative
5. **School Class Body Elections**: Class Monitor, Assistant Monitor, Discipline Head, Academic Coordinator, Cultural Head, Sports Captain
6. **Community/Society Elections**: Society Chairman, Vice Chairman, Treasurer, Secretary, Facilities Manager, Security Incharge
7. **Religious/Temple/Church Committee Elections**: Head Priest/Chairperson, Assistant Priest/Vice Chair, Secretary, Event Manager, Treasurer, Volunteer Coordinator

---

## 🔐 Firebase Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    match /users/{userId} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow list: if true;
      allow create: if request.auth != null && request.auth.uid == userId;
      allow update: if request.auth != null &&
                    (request.auth.uid == userId || isAdmin());
      allow delete: if isAdmin();
    }

    match /elections/{electionId} {
      allow read: if isAuthenticated();
      allow create, update, delete: if isAdmin();

      match /positions/{positionId} {
        allow read: if isAuthenticated();
        allow create, update, delete: if isAdmin();

        match /candidates/{candidateId} {
          allow read: if isAuthenticated();
          allow create, update, delete: if isAdmin();
        }
      }
    }

    match /votes/{voteId} {
      allow read, create: if isAuthenticated();
    }

    match /results/{resultId} {
      allow read: if isAuthenticated();
      allow write: if isAdmin();
    }

    function isAuthenticated() {
      return request.auth != null;
    }

    function isAdmin() {
      return isAuthenticated() &&
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```

---

## ⚡ GitHub & Firebase Setup

1. Clone the repository:

```bash
git clone https://github.com/yourusername/OnlineVotingApp.git
```

2. Add your **Firebase keys locally** (do **not** commit them):

```plaintext
firebase_keys/android_google-services.json → android/app/google-services.json
firebase_keys/ios_GoogleService-Info.plist → ios/Runner/GoogleService-Info.plist
```

3. Install dependencies:

```bash
flutter pub get
```

4. Run the app:

```bash
flutter run
```

5. To generate a real `firebase_options.dart` locally:

```bash
flutterfire configure
```

> ⚠️ **Important:** Only a dummy `firebase_options.dart` is uploaded. Contributors must use their own Firebase project.

---

---

