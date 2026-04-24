# ☀️ Shams Platform | منصة شمس
> **The first specialized solar energy community platform in Yemen.**

---

## 📖 Overview | نبذة عن المشروع
**Shams Platform** is a mobile application designed to bridge the gap between solar energy technicians, workshops, and customers in Yemen. It focuses on building a trusted ecosystem through verified professional identities and high-quality service documentation.

---

## 🚀 Key Features | المميزات الرئيسية
- **🛡️ Verified Identity:** Strict verification process for technicians and workshops to ensure reliability.
- **🛠️ Workshop Hub:** A dedicated space for technicians to showcase their expertise, specialized services, and contact info.
- **📱 Technical Feed:** A social timeline for sharing project documentation (Before & After), tips, and solar insights.
- **💬 Direct Service Requests:** Seamless communication between customers and technical workshops.
- **📍 Location-Based Search:** Find the nearest qualified technician based on Yemeni governorates.

---

## 🛠️ Tech Stack | التقنيات المستخدمة
- **Frontend:** [Flutter](https://flutter.dev/) (Multi-platform)
- **Backend:** [Supabase](https://supabase.com/) (PostgreSQL + Auth + Storage)
- **State Management:** Provider / GetX
- **Fonts:** Tajawal (via Google Fonts)
- **Architecture:** MVC (Model-View-Controller)

---

## 📂 Project Structure (MVC) | هيكلية المشروع
```text
lib/
├── controllers/    # Business logic & State management
├── models/         # Data models & Serialization
├── views/          # UI Screens (Screens & Layouts)
├── widgets/        # Reusable UI components (Buttons, Cards, etc.)
├── services/       # External APIs & Supabase integration
└── utils/          # App constants, Theme data, & Helpers
