# 🚚 FaiExpress – Smart Expedition & Delivery Platform

**FaiExpress** is a multi-service logistics application designed to simplify the delivery of **goods**, **food**, and **passengers**. Built with Flutter and powered by a Golang backend, this app delivers a seamless experience for customers, couriers, and administrators.

---

## 🌟 Key Features

### 👤 Customer Features
- 🔐 Secure registration & login
- 📦 Order form for goods & food delivery
- 🧍 Passenger delivery with direct location selection
- 🗺️ Pickup and drop-off location using interactive map (OpenStreetMap)
- 👷 Select available couriers
- ✅ Confirm orders and track status
- 🛰️ Live tracking & chat *(Coming Soon)*

### 🛵 Courier Features
- 📥 Real-time order notifications
- 📋 View delivery details
- ⏳ Update delivery status
- 💬 In-app chat with customer *(Planned)*

### 🧑‍💼 Admin Features
- 👤 Manage couriers and customers
- 📊 Monitor active and historical orders
- 🔧 Control system operations via dashboard

---

## 🧰 Tech Stack

| Component   | Technology          |
|------------|----------------------|
| Frontend    | Flutter              |
| Backend     | Golang               |
| Database    | PostgreSQL           |
| Map         | FlutterMap + OSM     |
| Auth        | JWT-based Login      |
| State Mgmt  | BLoC (Flutter)       |

---

## 🗂️ Project Structure

📦 fai_express/
├── lib/
│ ├── blocs/
│ ├── models/
│ ├── screens/
│ ├── services/
│ └── main.dart
├── backend/
│ ├── controllers/
│ ├── models/
│ ├── routes/
│ └── main.go


---

## 🚧 Development Progress

- ✅ Goods & food order forms
- ✅ Passenger service with direct map
- ✅ Courier selection & order confirmation
- ✅ Role-based login (Admin, Courier, Customer)
- ✅ Golang backend with RESTful API
- 🔄 Live tracking system *(In Progress)*
- 🔄 In-app chat *(Coming Soon)*
- 🔄 Push notification *(Planned)*

---

## 🚀 Getting Started

### ▶️ Run Backend (Golang)
```bash
cd backend
go run main.go
```

▶️ Run Frontend (Flutter)
```bash
cd misi_paket
flutter run
```
Make sure the backend is running and accessible on http://localhost:8080 or your deployment host.

---

## 🤝 Contributing
We welcome contributions! Please open an issue or pull request if you have ideas or improvements. Let's build FaiExpress together 🚀

## 👥 No Team, Solo Levelling by
Ridho Mubarok – Mobile Developer & System Architect

