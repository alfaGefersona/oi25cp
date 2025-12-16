# 🏓 oi25cp — Table Tennis Training Robot App

Mobile application developed in **Flutter** as part of the **Integration Workshop** course project.

This app works as a control interface for a **table tennis training robot**, enabling configuration, communication, and real-time interaction with the device over a network connection.

---

## 📌 Overview

**oi25cp** is a Flutter-based mobile application that:

- Connects to IoT devices via **Wi‑Fi**
- Manages required system permissions
- Communicates with the robot using **WebSocket**
- Stores configuration data locally
- Provides a simple and intuitive user interface for robot control

This project is part of an **integrated system**, combining:

- Hardware (ball‑launching table tennis training robot)
- Embedded software
- Mobile application for control and monitoring

---

## 🔌 System Architecture

The system is composed of two main components:

### 📱 Mobile Application
- Developed in **Flutter**
- Runs on Android and iOS
- Responsible for user interaction and control logic
- Communicates with the robot via **WebSocket over Wi-Fi**

### 🤖 Embedded System (ESP32)
- Firmware runs on an **ESP32 microcontroller**
- Controls motors and actuators of the table tennis robot
- Hosts a **WebSocket server**
- Connects to the mobile app via local Wi-Fi network
- Processes commands and sends real-time status updates

### Communication Flow

Flutter App  
→ Wi-Fi  
→ WebSocket  
→ **ESP32 (Robot Controller)**


## 🧠 Main Features

- 📶 Wi‑Fi connectivity with IoT devices
- 🔐 System permission management
- 🔄 Real‑time communication via WebSocket
- 💾 Local data persistence using SharedPreferences
- 📱 Cross‑platform mobile UI (Android / iOS)

---

## 🧱 Technologies Used

- **Flutter** (SDK)
- **Dart** (>= 3.9.2)
- **WiFi IoT** (`wifi_iot`)
- **WebSocket** (`web_socket_channel`)
- **Shared Preferences**
- **Permission Handler**
- **Material Design**

---

## 📂 Project Structure

```text
oi25cp/
├── android/              # Android configuration
├── ios/                  # iOS configuration
├── lib/                  # Flutter source code
│   ├── main.dart         # Application entry point
│   ├── screens/          # Application screens
│   ├── services/         # Network and business logic
│   ├── widgets/          # Reusable UI components
│   └── utils/            # Utility functions
├── test/                 # Automated tests
├── pubspec.yaml          # Dependencies and configuration
└── README.md             # Project documentation
```

> **Note:** The internal structure may evolve as the project grows.

---

## 🚀 How to Run the Project

### 1️⃣ Prerequisites

- Flutter installed  
  https://docs.flutter.dev/get-started/install
- Android Studio or VS Code
- Android emulator or physical device
- Git

### 2️⃣ Clone the repository

```bash
git clone https://github.com/alfaGefersona/oi25cp.git
cd oi25cp
```

### 3️⃣ Install dependencies

```bash
flutter pub get
```

### 4️⃣ Run the application

```bash
flutter run
```

---

## ⚙️ Main Dependencies

Excerpt from `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  app_settings: ^5.1.1
  wifi_iot: ^0.3.19
  permission_handler: ^11.3.0
  web_socket_channel: ^3.0.1
  shared_preferences: ^2.2.2
```

These libraries enable:

- Access to system settings
- Direct Wi‑Fi connection to the robot
- Real‑time communication
- Local data persistence

---

## 🔌 Communication Architecture (Summary)

```text
Flutter App
   │
   ├── Wi‑Fi IoT
   │
   ├── WebSocket
   │
   ▼
Table Tennis Training Robot
```

The application acts as a client, sending commands and receiving real‑time responses from the robot.

---

## 🧪 Testing

To run automated tests:

```bash
flutter test
```

---

## 📦 Production Build

### Android APK

```bash
flutter build apk
```

### Android App Bundle (Play Store)

```bash
flutter build appbundle
```

---

## 🎓 Academic Context

This project was developed as part of the **Integration Workshop** course, with the objective of applying concepts such as:

- Embedded systems
- Network communication
- Hardware and software integration
- Cross‑platform mobile development

---

## 👨‍💻 Authors

Developed by students of the **Integration Workshop** course.  
Repository maintained by **alfaGefersona**.

---

## 📄 License

This project is intended for **academic and educational use only**.  
Please contact the author for commercial use or redistribution.
