# Teza Administration Portal (Flutter Web)

This is the official administrative dashboard for the **Teza** platform, built using Flutter Web. It provides operational staff and platform owners full control over deliveries, riders, merchants, user access roles, and manual dispatch overrides.

---

## 🏗️ Architecture & Project Structure

The project follows a modular, layer-separated architecture to ensure scalability, ease of collaboration, and code maintainability:

```text
teza_admin/
├── lib/
│   ├── main.dart            # Application entrypoint & MultiProvider setup
│   ├── models/              # Type-safe Dart representations of API payloads
│   │   ├── user.dart
│   │   ├── rider.dart
│   │   ├── merchant.dart
│   │   ├── delivery.dart
│   │   ├── offer.dart
│   │   ├── history.dart
│   │   └── ranked_rider.dart
│   ├── services/            # Stateless network client layer
│   │   └── api_service.dart # Handles HTTP calls to Spring Boot backend
│   ├── providers/           # Reactive state management (ChangeNotifier)
│   │   ├── auth_provider.dart
│   │   └── dashboard_provider.dart
│   └── views/               # UI Layer (Screens & Glassmorphic components)
│       ├── login_screen.dart
│       ├── dashboard_screen.dart
│       └── panes/           # Sidebar container pages
│           ├── overview_pane.dart
│           ├── users_pane.dart
│           ├── riders_pane.dart
│           ├── merchants_pane.dart
│           └── deliveries_pane.dart
```

---

## ⚡ State Management Pattern

We use the **Provider** package for state management. State is split into two central providers wired up at the root level using `MultiProvider`:

### 1. `AuthProvider`
- **Purpose**: Controls user login states, access tokens, and administrative roles.
- **Permissions Gate**: Exposes properties to check user capabilities. Specifically:
  - `isSuperAdmin` (Full read/write/delete capabilities)
  - `isSupportAdmin` (Global view/edit capability, but cannot perform delete actions)
  - `canDelete` (Enforces action locks; only returns true for `SUPER_ADMIN` profiles)

### 2. `DashboardProvider`
- **Purpose**: Acts as the data manager for the administration panels.
- **Actions**: Handles bulk fetching of resources in parallel, role modification, approving or rejecting onboarding riders, forced delivery status overrides, fetching ranked candidates, and manual offer dispatches.

---

## 🔒 Security & Role-Based Actions

Collaborators must strictly respect access privileges between `SUPER_ADMIN` and `SUPPORT_ADMIN` roles. The backend enforces these boundaries, and the UI should prevent disabled states:

* **Deletions**: Any delete action (on users, riders, merchants, or deliveries) is restricted to `SUPER_ADMIN` accounts.
* **UI Lock**: Always check `auth.canDelete` in the view files to conditionally enable, hide, or wrap deletion options inside warning tooltips. E.g.:
  ```dart
  if (authProvider.canDelete) {
    // Show delete button
  } else {
    // Show disabled delete button with a supportive tooltip
  }
  ```

---

## 🌐 Network Layer (`ApiService`)

The network layer is built over the `http` package inside [api_service.dart](file:///Users/davisdev/IdeaProjects/teza/teza_admin/lib/services/api_service.dart).
- **Base URL**: Defaults to local development `http://localhost:8080`.
- **JWT Authorization**: The bearer token is saved in memory by `AuthProvider` and injected automatically into the headers of authenticated network calls.

---

## 💅 Styling Guide

The portal employs a **premium dark theme** with custom glassmorphism. Guidelines for visual changes:
- **Typography**: Uses `GoogleFonts.outfit` for key headers and `GoogleFonts.inter` for tables, inputs, and paragraphs.
- **Color Palette**: Dark background (`0xFF0A0A12`), card colors (`0xFF111122`), primary accent (`0xFF6C63FF`), status green (`0xFF10AC84`), warnings (`0xFFFF9F43`), and errors (`0xFFFF5252`).
- **Glassmorphism**: Use container boxes with semi-transparent white overlays (`Colors.white.withOpacity(0.04)`), frosted background blurs (`BackdropFilter(filter: ImageFilter.blur(...))`), and thin borders (`Border.all(color: Colors.white.withOpacity(0.08))`).

---

## 🚀 Getting Started (Collaborator Commands)

### 1. Resolve Dependencies
Make sure you have Flutter SDK installed (tested on `v3.38.9`). Run:
```bash
flutter pub get
```

### 2. Run Locally in Development
To run in Chrome for web debugging:
```bash
flutter run -d chrome
```

### 3. Build Production Bundle
To build the optimized static asset files (output targeting `build/web/`):
```bash
flutter build web
```
