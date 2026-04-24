# Cursor / agent handoff (güncel, kısa)

**Proje:** StudySync — kampüs çalışma alanı + rezervasyon + companion. Ana ürün: **Flutter** (`mobile_flutter/`). API: **Spring Boot 3.3 / Java 21** (`backend_java/`). İsteğe bağlı **React/Vite referans** (`src/`, Figma hizası; mobil runtime bunu kullanmaz). **API sözleşmesi:** `docs/api-contract-v1.md` — path’ler `/api/v1`; korumalı uçlarda `Authorization: Bearer <access>`.

**Klasör / Git notu:** Cursor’da sık açılan klasör adı farklı olabiliyor; GitHub clone’u genelde `STUDYSYNC-IMPLEMENTATION` kökünde. Değişiklikleri push ederken doğru kopya üzerinde çalışıldığından emin ol.

**Mobil taban URL:** `mobile_flutter/lib/core/config/app_config.dart`  
- Android emülatör: `http://10.0.2.2:8080/api/v1`  
- Masaüstü/iOS sim: `http://localhost:8080/api/v1`  
- Fiziksel cihaz: `--dart-define=API_BASE=http://<BILGISAYAR_LAN>:8080/api/v1`

**Backend (özet):** `application.yml` — H2 in-memory, `ddl-auto: update`, port 8080.  
- `SecurityConfig`: **Herkese açık** yalnızca `GET/POST /api/v1/auth/**`, `GET /api/v1/health`, `GET /api/v1/reference/**`, H2 console, `/error`. **Diğer tüm `/api/v1/**` istekler JWT ister** (`JwtAuthenticationFilter` + `JwtTokenProvider`).  
- **Login / Register:** Gerçek **JWT** (JJWT) + **BCrypt**; `AuthService` + `UserAccountRepository`. (Eski “stub token” dönemi bitti.)  
- **Refresh:** `POST /api/v1/auth/refresh` var; `AuthService.refresh` içinde hâlâ **TODO** (repository + token rotation) — çağrı şu an hata/unsupported olabilir.  
- E-posta doğrulama: **backend’de henüz yok**; mobildeki doğrulama adımı demo/UX.  
- Rezervasyon, dashboard, check-in vb. servis kısımları kısmen tam; ayrıntı `IMPLEMENTATION_STATUS.md` ve kök `README.md` “Implementation Status” bölümünde.

**Mobil tarafta (özet, 2026):** `AuthSession` + `ApiClient` interceptor; `BottomNavShell` + **IndexedStack** (sekme state kalıcı). **ThemeModeController** (açık/koyu). **AiStudyController** (yerel “AI” önerileri, Home → Reserve prefill). QR check-in / bazı history satırları **demo** mantığı. Kayıt’ta 409 (e-posta mevcut) → otomatik giriş denemesi (şifre uyuyorsa home).

**Sonraki mantıklı backend/mobile işler:** E-posta doğrulama; refresh token depolama + `refresh` tamamlama; `flutter_secure_storage`; PostgreSQL profili; kalan uçların sözleşmeyle tam hizası.

**Uzun kronoloji / eski madde listesi:** `IMPLEMENTATION_STATUS.md` (güncelliği kısmi olabilir; çelişkide bu dosya + `README` öncelikli sayılsın).

---

## Demo / çalıştırma: donmalar ve emülatör (agent notu)

Bunu kısaca “stabilite” diye tut: sorun genelde yalnızca Flutter değil; **Windows + emülatör GPU + bellek** birlikte.

**Ne yapmaya çalışıyoruz (özet):**
- Önce **backend** açık olsun (`.\mvnw.cmd spring-boot:run`), sonra emülatör, sonra `flutter run` — böylece ağ/timeout yükü yarıda kesilmez.
- Emülatör **çöküyorsa / siyah ekran** → açık `qemu`/emülatör süreçlerini kapat, AVD’yi **Cold Boot** veya farklı **GPU** ile aç: önce `host`, olmazsa `swiftshader_indirect` (README’deki “Stable Run” + “Troubleshooting” akışı).
- **PowerShell**’de `&&` yerine `;` kullan; Maven için repo içinde `.\mvnw.cmd` kullan.
- Uygulama tarafında tab geçişinde state kaybı ve gereksiz rebuild **IndexedStack** ve daha hafif `onChanged` ile azaltıldı; demo için ağır döngü (ardışık hot restart) yapma.

**Detay:** kök `README.md` — *Stable Run Guide*, *Troubleshooting (Freeze / Black Screen)*, *Demo Cheat Sheet*.

**Agent’a hatırlatma:** Kullanıcı “donma olmasın / demo” dediğinde önce bu dosyayı + README’deki sırayı uygula; yeni “performans sihri” ekleme, önce emülatör/ortamı sabitle.
