<div align="center">
  <img src="assets/rumour.png" alt="Rumour Logo" width="150" />
  
  # Rumour
  
  **Anonymous Room-Code Chat App**

  [![Web Link](https://img.shields.io/badge/Web_App-Play_Now-blue?style=for-the-badge&logo=vercel)](https://rumour-seven.vercel.app//)
  
</div>

## 🌟 What is Rumour?

Rumour is an anonymous, room-based chat application built with Flutter. It allows users to quickly join or create chat rooms using a unique code, ensuring privacy and seamless real-time communication. Connect instantly, chat freely, and stay anonymous!

### ✨ Key Features
- **Anonymous Chat:** No sign-up or personal details required.
- **Room-Code Access:** Simple pin to join private rooms.
- **Real-time Messaging:** Powered by Firebase Cloud Firestore.
- **Cross-Platform:** Available on the Web, Android, and iOS.

## 🚀 How to Run Locally

Follow these steps to run the app on your local machine:

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Dart](https://dart.dev/get-dart)
- An IDE like VS Code or Android Studio

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/abhayanigam/Rumour.git
   cd Rumour
   ```

2. **Configure Environment Variables:**
   Create a `.env.json` file in the root of the project to store your Firebase configuration keys:
   ```json
   {
     "FIREBASE_API_KEY_ANDROID": "your_api_key",
     "FIREBASE_API_KEY_IOS": "your_api_key",
     "FIREBASE_API_KEY_WEB": "your_api_key",
     "FIREBASE_API_KEY_MACOS": "your_api_key",
     "FIREBASE_APP_ID_ANDROID": "your_app_id",
     "FIREBASE_APP_ID_IOS": "your_app_id",
     "FIREBASE_APP_ID_WEB": "your_app_id",
     "FIREBASE_APP_ID_MACOS": "your_app_id",
     "FIREBASE_MESSAGING_SENDER_ID": "your_sender_id",
     "FIREBASE_PROJECT_ID": "your_project_id",
     "FIREBASE_STORAGE_BUCKET": "your_storage_bucket",
     "FIREBASE_AUTH_DOMAIN": "your_auth_domain",
     "FIREBASE_IOS_BUNDLE_ID": "your_bundle_id",
     "FIREBASE_MACOS_BUNDLE_ID": "your_bundle_id"
   }
   ```

3. **Install dependencies:**
   ```bash
   flutter pub get
   ```

4. **Run the app:**
   ```bash
   flutter run
   ```
   *To run specifically for web:*
   ```bash
   flutter run -d chrome
   ```

## 🌐 Web App

Experience Rumour without any installation! Just visit the web app here:

👉 **[Launch Rumour Web App](https://rumour-j2rau5ci8-abhaya-nigams-projects.vercel.app/)**

---

<div align="center">
  <i>Built with 💙 using Flutter & Firebase</i>
</div>
