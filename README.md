# لوكس - Luxe iOS App

منصة حجوزات صالونات التجميل — iOS App بـ SwiftUI

## هيكل المشروع

```
Luxe/
├── App/
│   └── LuxeApp.swift           ← @main، RTL، Google Sign-In init
├── Core/
│   ├── Network/
│   │   ├── APIClient.swift     ← URLSession + JWT injection + error handling
│   │   ├── APIEndpoints.swift  ← كل الـ endpoints
│   │   └── APIEndpointsAlias.swift
│   ├── Keychain/
│   │   └── KeychainHelper.swift ← حفظ/قراءة/حذف JWT
│   └── Extensions/
│       ├── Color+Luxe.swift    ← الألوان الـ brand
│       └── View+Extensions.swift
├── Models/
│   ├── User.swift
│   ├── Salon.swift             ← Salon, Service, Staff, TimeSlot, Coupon
│   ├── Booking.swift
│   ├── Review.swift
│   └── Coupon.swift
├── ViewModels/
│   ├── AuthViewModel.swift
│   ├── SalonViewModel.swift
│   └── BookingViewModel.swift
├── Views/
│   ├── Auth/
│   │   ├── LoginView.swift
│   │   └── RegisterView.swift
│   ├── Salons/
│   │   ├── HomeView.swift      ← TabView + SalonListView + SalonCard
│   │   └── SalonDetailView.swift
│   ├── Booking/
│   │   ├── BookingView.swift
│   │   ├── RescheduleView.swift
│   │   └── ReviewView.swift
│   ├── Bookings/
│   │   └── MyBookingsView.swift
│   ├── Profile/
│   │   └── ProfileView.swift
│   └── Components/
│       ├── SlotGridView.swift
│       ├── BookingCard.swift
│       ├── StarRatingView.swift
│       └── LuxeButton.swift
├── Info.plist
└── Package.swift
```

## خطوات الإعداد في Xcode

### 1. إنشاء المشروع
- أنشئ مشروع **SwiftUI App** جديد باسم `Luxe`
- Deployment Target: **iOS 16.0**
- Bundle ID: `com.luxe.app`

### 2. إضافة GoogleSignIn عبر SPM
```
File → Add Package Dependencies
URL: https://github.com/google/GoogleSignIn-iOS.git
Version: 7.0.0 أو أحدث
Products: GoogleSignIn + GoogleSignInSwift
```

### 3. Info.plist
انسخي محتوى `Info.plist` المرفق أو تأكدي من وجود:
- `GIDClientID`: Client ID الخاص بـ Google
- `CFBundleURLTypes` مع reversed client ID
- `NSAppTransportSecurity` لـ luxe-sa.com

### 4. Signing & Capabilities
- أضيفي **Keychain Sharing** Capability

### 5. الخطوط (اختياري)
لإضافة خط Tajawal:
1. حملي الخط من Google Fonts
2. اسحبيه للمشروع
3. أضيفيه في Info.plist تحت `UIAppFonts`
4. استخدميه بـ `.font(.custom("Tajawal-Regular", size: 16))`

## الميزات المُنفّذة

| الميزة | الوصف |
|--------|-------|
| ✅ RTL كامل | `.environment(\.layoutDirection, .rightToLeft)` |
| ✅ JWT Keychain | حفظ آمن للتوكن |
| ✅ Google Sign-In | تكامل كامل مع GIDSignIn SDK |
| ✅ تسجيل دخول/خروج | Email + Password |
| ✅ قائمة الصالونات | LazyVGrid مع فلتر المدن |
| ✅ تفاصيل الصالون | خدمات، موظفات، كوبونات، تقييمات |
| ✅ حجز موعد | DatePicker + SlotGrid + كوبون + نقاط |
| ✅ حجوزاتي | فلتر بالحالة، إلغاء، إعادة جدولة |
| ✅ التقييم | نجوم تفاعلية للصالون والموظفة |
| ✅ الملف الشخصي | نقاط الولاء، تغيير كلمة المرور |
| ✅ معالجة 401 | تسجيل خروج تلقائي |
| ✅ ألوان وردية/ذهبية | Brand colors كاملة |

## API Base URL
`https://luxe-sa.com/api/v1`
