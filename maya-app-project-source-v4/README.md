# Maya (માયા) — Production Software Suite for Xiaomi Redmi (MIUI / HyperOS)

Maya is an AI voice assistant designed specifically for Gujarati elders on Xiaomi Redmi devices.

## Repository Structure

- `lib/` — Flutter Application Source Code (`main.dart`, `xiaomi_setup.dart`, `ota_updater.dart`, `whatsapp_service.dart`)
- `android/` — Native Android Kotlin Bridge (`MainActivity.kt`, `MayaXiaomiService.kt`, `BootReceiver.kt`, `AndroidManifest.xml`)
- `backend/` — FastAPI Server, Database Schema (`models.py`), and ORM models
- `Dockerfile` & `docker-compose.yml` — Containerization setup for production deployment
- `.github/workflows/deploy.yml` — Automated GitHub Actions CI/CD Pipeline for APK building

## How to Build & Deploy

1. **Local Build**:
   ```bash
   flutter pub get
   flutter build apk --release
   ```

2. **Automated GitHub Actions Build**:
   Push a release tag to GitHub to trigger the automated build:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```
