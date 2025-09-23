# 🪙 Crypto Portfolio Tracker (Flutter + ObjectBox + Provider + get_it)

A Flutter application that allows users to **build and manage a crypto portfolio** with live price tracking.  
Supports **local persistence** (ObjectBox), **state management** (Provider), and **dependency injection** (get_it).  
Includes **searchable coin list**, **portfolio tracking**, **real-time price updates**, and **visual indicators for price changes**.

---

## 🚀 App Setup Steps

### 1. Clone the repo
```bash
git clone https://github.com/Devesh190/knovator_task.git
cd knovator_task

flutter pub get

flutter pub run build_runner build --delete-conflicting-outputs

flutter run
```


## 🏗 Architectural Choices

The app follows a **Clean Architecture inspired layered approach**:

### 🔹 Data Layer
- **ApiService** → Handles all CoinGecko API calls (prices, markets, coin list).  
- **ObjectBox** → Local database for coins and holdings, optimized for speed and offline persistence.  
- **Repositories** → Bridge between API and DB, providing clean methods for the rest of the app.  

### 🔹 Domain / State Layer
- **PortfolioProvider** (using `Provider`) → Core state manager handling portfolio business logic, auto-refresh, and sorting.  
- **get_it** → Dependency injection to register and resolve services, repositories, and providers. Keeps code modular and testable.  

### 🔹 UI Layer
- **PortfolioScreen** → Displays holdings, their value, total portfolio value, with pull-to-refresh and sorting options.  
- **AllCoinsScreen** → Allows browsing and searching all coins, with current price, ↑/↓ indicators, and quantity adjustment via +/− buttons.  
- **SummarySheet** → Bottom sheet showing all selected coins, their quantities, values, and the total portfolio value before saving.  

---

### ⚡ Why These Choices?

- **ObjectBox**  
  Chosen for its speed and ability to handle thousands of coins efficiently with indexed queries, making offline access fast.  

- **Provider**  
  Lightweight and widely used state management solution. Easy to explain in interviews and integrates well with `ChangeNotifier`.  

- **get_it**  
  Ensures proper separation of concerns by decoupling construction from usage. Makes the app more modular, scalable, and testable.  


## 📦 Third-party Libraries

- **[provider: ^6.1.5+1](https://pub.dev/packages/provider)**  
  → State management with `ChangeNotifier` and `Consumer`.  

- **[get_it: ^8.2.0](https://pub.dev/packages/get_it)**  
  → Dependency injection, keeping app components decoupled and testable.  

- **[http: ^1.2.0](https://pub.dev/packages/http)**  
  → For REST API calls (CoinGecko integration).  

- **[objectbox: ^4.1.0](https://pub.dev/packages/objectbox)**  
  → High-performance local database for storing coins and holdings.  

- **[objectbox_flutter_libs: ^4.1.0](https://pub.dev/packages/objectbox_flutter_libs)**  
  → Provides native libraries required for ObjectBox to run in Flutter apps.  

- **[intl: ^0.20.2](https://pub.dev/packages/intl)**  
  → Used for number, date, and currency formatting.  

- **[flutter_svg: ^2.0.10](https://pub.dev/packages/flutter_svg)**  
  → Renders SVG logos for splash screen.  
