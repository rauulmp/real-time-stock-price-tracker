# 📈 Real-Time Stock Price Tracker

A high-performance iOS application built with **SwiftUI** and **Swift Concurrency** that tracks live stock prices via WebSockets. Designed with scalability, robustness, and a fluid user experience as core principles.

![Swift](https://img.shields.io/badge/Swift-6-orange.svg)
![iOS](https://img.shields.io/badge/iOS-18.0%2B-blue.svg)
![Architecture](https://img.shields.io/badge/Architecture-Clean_Store_(MV)--Observable-green.svg)

---

## 🚀 Core Features

- **Live Price Tracking:** Real-time updates for a scrollable list of 25 stock symbols.
- **WebSocket Echo Integration:** Bidirectional connection with `wss://ws.postman-echo.com/raw` to simulate real market data flow.
- **Advanced State Management:** Granular handling of connection states (*Connecting, Connected, Disconnected*).
- **Dynamic Sorting:** High-performance sorting by Price or Price Change with smooth UI animations.
- **Deep Linking & Details:** Detailed secondary screen with synchronized real-time metrics and symbol descriptions.
- **Network Resilience:** **Exponential Backoff** strategy with Jitter for reliable automatic reconnections.
- **Adaptive UI:** Full support for Light and Dark Mode using semantic colors and standard system materials for a native look and feel.

---

## 🏗️ Architecture & Technical Decisions

The project follows a **Clean Store (Observation-based)** architecture, prioritizing separation of concerns and thread safety.



### 1. Data Layer (Infrastructure)
- **Actor-based Service:** `StockWebSocketService` is implemented as an `actor`. This ensures that socket handling and connection state are isolated from concurrency issues (*data races*).
- **Asynchronous Streams:** `AsyncStream` is used to expose price updates and service status, allowing for efficient, reactive consumption.
- **DTOs & Mappers:** Strict separation between raw server data and domain models via `PriceUpdateMapper`.

### 2. Domain Layer (Business Logic)
- **Immutable Models:** Models like `Stock` and `PriceUpdate` are `Sendable` and lightweight structures.
- **Factory & Seed System:** Controlled data generation to ensure UI consistency during the initial app launch.

### 3. Presentation Layer (UI)
- **@Observable Store:** A centralized `StocksStore` managing UI logic on the `@MainActor`.
- **UI Throttling:** Price updates are buffered and applied to the UI at intervals to prevent main-thread bottlenecks during high-frequency data bursts.
- **SwiftUI Modifiers:** Custom ViewModifiers (e.g., `CardModifier`) for a scalable and maintainable UI design system.

---

## 🛠️ Resilience & Scalability

As a "ready-to-launch" solution, the following were implemented:
- **Lifecycle Management:** The connection automatically pauses when the app enters the *background* and resumes when *active*, optimizing battery and data usage.
- **Smart Reconnection:**
  $$Delay = \min(30s, 1s \times 2^{attempt}) \times Jitter(0.8, 1.2)$$
  This formula prevents server hammering during mass outages.
- **Localization:** Full support for multi-regional deployment using `LocalizedStringResource` and String Catalogs.

---

## 🧪 Testing Strategy

The project implements a multi-layered testing strategy designed for reliability and CI/CD automation, leveraging the modern **Swift Testing** framework and **XCUITest**.

### 1. Unit & Integration Testing (Swift Testing)
Using the latest **Swift Testing** framework, the suite focuses on state integrity and asynchronous data flow:

* **State Machine Validation:** Ensures `StocksStore` transitions correctly between `.loading`, `.active`, `.paused`, and `.error` states.
* **Asynchronous Mocking:** A `MockStockWebSocketService` uses `AsyncStream` continuations to simulate real-time price feeds, connection status changes, and network errors.
* **Throttling Logic:** A critical test (`throttling_batches_multiple_updates`) verifies that high-frequency WebSocket messages are correctly batched, ensuring the UI remains performant and only renders the latest data within the throttle window.
* **Sorting Algorithms:** Comprehensive tests for price and change-based sorting, including ascending/descending toggle logic.

### 2. UI Testing (XCUITest)
The UI tests ensure a seamless user journey and localized-agnostic reliability:

* **Robust State Verification:** Instead of flaky timeouts, tests use `NSPredicate` and `expectations` to wait for dynamic label changes (e.g., the Start/Stop connection toggle).
* **Navigation & Interaction:** Validates the full drill-down flow from the main list to the `StockDetailView` and the correct dismissal of the sorting menu.
* **Accessibility Driven:** Elements are accessed via `accessibilityIdentifier`, allowing tests to run consistently across different locales and languages.

### 3. Thread Safety & Concurrency
* **Complete Concurrency Checking:** The project is compiled with **Strict Concurrency** set to **Complete**. This ensures that the interaction between the `actor-based` service and the `@MainActor` store is free of data races at compile time.

---

## 📦 Installation

1. Clone the repository:
   ```bash
   git clone [https://github.com/rauulmp/real-time-stock-price-tracker.git](https://github.com/rauulmp/real-time-stock-price-tracker.git)

2. Open RealTimeStockPriceTracker.xcodeproj.
3. Select a simulator with iOS 18.0+.
4. Run! (Cmd + R).

   
