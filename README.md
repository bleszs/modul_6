# modul_6

ToDo adalah aplikasi latihan Flutter dan Firebase untuk praktikum IKLC.

## Build rilis Android

Gunakan Flutter 3.35.7 dan JDK 17. Letakkan konfigurasi Firebase untuk `com.example.modul_6` di `android/app/google-services.json`. Gradle membaca konfigurasi signing dari `android/key.properties` dan mencari keystore relatif terhadap `android/app`.

```bash
flutter pub get
flutter build apk --release --no-pub
```

APK tersedia di `build/app/outputs/flutter-apk/app-release.apk`. Untuk membuat ulang aset Android setelah gambar diubah, jalankan `dart run flutter_launcher_icons` dan `dart run flutter_native_splash:create`.

## GitHub Actions

Workflow **Build and Release APK** menggunakan secrets berikut.

| Secret | Isi |
| --- | --- |
| `KEYSTORE_BASE64` | Isi `android/app/upload-keystore.jks` dalam Base64 |
| `STORE_PASSWORD` | Password keystore dari `android/key.properties` |
| `KEY_PASSWORD` | Password key dari `android/key.properties` |
| `KEY_ALIAS` | Alias key dari `android/key.properties` |
| `GOOGLE_SERVICES_JSON_BASE64` | Isi `android/app/google-services.json` dalam Base64 |

Jalankan workflow secara manual untuk membuat artefak APK. Push tag seperti `v1.0.0` untuk memasang APK pada GitHub Releases.
